import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartService {
  CartService._();
  static final CartService instance = CartService._();
  static const _key = 'elyramart_cart_v1';
  final Map<String, Map<String, dynamic>> items = {};
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final value = Map<String, dynamic>.from(entry.value as Map);
          value['quantity'] = (value['quantity'] as num?)?.toInt() ?? 1;
          items[entry.key] = value;
        }
      } catch (_) {
        await prefs.remove(_key);
      }
    }
    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items));
  }

  Future<void> add(String id, Map<String, dynamic> product) async {
    await load();
    final existing = items[id];
    items[id] = {
      'title': product['title']?.toString() ?? 'Product',
      'category': product['category']?.toString() ?? '',
      'price': (product['price'] as num).toDouble(),
      'stock': (product['stock'] as num?)?.toInt() ?? 0,
      'quantity': (existing?['quantity'] as int? ?? 0) + 1,
    };
    await _save();
  }

  Future<void> change(String id, int delta) async {
    await load();
    final item = items[id];
    if (item == null) return;
    final quantity = (item['quantity'] as int) + delta;
    if (quantity <= 0) { items.remove(id); } else { item['quantity'] = quantity; }
    await _save();
  }

  Future<void> clear() async {
    items.clear();
    await _save();
  }

  double get total => items.values.fold<double>(0.0, (sum, item) => sum + ((item['price'] as num).toDouble() * (item['quantity'] as int)));
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, this.category, this.english = true});
  final String? category;
  final bool english;
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _db = FirebaseFirestore.instance;
  bool _cartLoaded = false;

  @override
  void initState() {
    super.initState();
    CartService.instance.load().then((_) { if (mounted) setState(() => _cartLoaded = true); });
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.english ? 'Shop products' : 'পণ্য কিনুন'), actions: [
      IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage(english: widget.english))).then((_) => setState(() {})), icon: Badge(label: Text(CartService.instance.items.length.toString()), child: const Icon(Icons.shopping_cart_outlined))),
    ]),
    body: !_cartLoaded ? const Center(child: CircularProgressIndicator()) : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('products').where('status', isEqualTo: 'active').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Could not load products: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final allProducts = snapshot.data!.docs;
        final selected = widget.category?.toLowerCase();
        final products = selected == null ? allProducts : allProducts.where((doc) {
          final value = (doc.data()['category'] ?? '').toString().toLowerCase();
          return value == selected || (selected == 'beauty' && (value == 'beauty & care' || value == 'cosmetics'));
        }).toList();
        if (products.isEmpty) return Center(child: Text(widget.english ? 'No products available in this category yet.' : 'এই ক্যাটাগরিতে এখনো কোনো পণ্য নেই।'));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final doc = products[index];
            final p = doc.data();
            final stock = (p['stock'] as num?)?.toInt() ?? 0;
            return Card(child: ListTile(
              title: Text(p['title']?.toString() ?? 'Product'),
              subtitle: Text('${p['category'] ?? ''} • BDT ${p['price'] ?? 0} • Stock: $stock'),
              trailing: FilledButton(
                onPressed: stock > 0 ? () async {
                  await CartService.instance.add(doc.id, p);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                  setState(() {});
                } : null,
                child: const Text('Add'),
              ),
            ));
          },
        );
      },
    ),
  );
}

class CartPage extends StatefulWidget {
  const CartPage({super.key, this.english = true});
  final bool english;
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _address = TextEditingController();
  final _phone = TextEditingController();
  bool _busy = false;
  bool _cartLoaded = false;
  @override
  void initState() {
    super.initState();
    CartService.instance.load().then((_) { if (mounted) setState(() => _cartLoaded = true); });
  }
  @override
  void dispose() { _address.dispose(); _phone.dispose(); super.dispose(); }

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.english ? 'Please sign in before placing an order.' : 'অর্ডার করতে আগে লগইন করুন।')));
      return;
    }
    if (_address.text.trim().length < 6 || _phone.text.trim().length < 6 || CartService.instance.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.english ? 'Enter a valid phone number and delivery address.' : 'সঠিক ফোন নম্বর ও ঠিকানা লিখুন।')));
      return;
    }
    setState(() => _busy = true);
    try {
      final cart = CartService.instance;
      final callable = FirebaseFunctions.instanceFor(region: 'asia-south1').httpsCallable('placeOrder');
      await callable.call({
        'items': cart.items.entries.map((entry) => {
          'productId': entry.key,
          'quantity': entry.value['quantity'],
        }).toList(),
        'phone': _phone.text.trim(),
        'deliveryAddress': _address.text.trim(),
      });
      await cart.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.english ? 'Order placed. Pay cash on delivery.' : 'অর্ডার সম্পন্ন হয়েছে। পণ্য পেয়ে টাকা দিন।')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    return Scaffold(
      appBar: AppBar(title: Text(widget.english ? 'Your cart' : 'আপনার কার্ট')),
      body: !_cartLoaded ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(16), children: [
        if (cart.items.isEmpty) Padding(padding: const EdgeInsets.all(30), child: Text(widget.english ? 'Your cart is empty.' : 'আপনার কার্ট খালি।', textAlign: TextAlign.center)),
        ...cart.items.entries.map((entry) {
          final p = entry.value;
          return Card(child: ListTile(
            title: Text(p['title']?.toString() ?? 'Product'),
            subtitle: Text('BDT ${p['price']} × ${p['quantity']}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(onPressed: () async { await cart.change(entry.key, -1); if (mounted) setState(() {}); }, icon: const Icon(Icons.remove_circle_outline)),
              IconButton(onPressed: () async { await cart.change(entry.key, 1); if (mounted) setState(() {}); }, icon: const Icon(Icons.add_circle_outline)),
            ]),
          ));
        }),
        if (cart.items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('${widget.english ? 'Total' : 'সর্বমোট'}: BDT ${cart.total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: widget.english ? 'Contact phone' : 'যোগাযোগের ফোন নম্বর', border: const OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _address, maxLines: 3, decoration: InputDecoration(labelText: widget.english ? 'Delivery address' : 'ডেলিভারি ঠিকানা', border: const OutlineInputBorder())),
          const SizedBox(height: 16),
          FilledButton(onPressed: _busy ? null : _placeOrder, child: _busy ? const CircularProgressIndicator() : Text(widget.english ? 'Place order • Cash on delivery' : 'অর্ডার করুন • ক্যাশ অন ডেলিভারি')),
        ],
      ]),
    );
  }
}
