import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartService {
  CartService._();
  static final CartService instance = CartService._();
  final Map<String, Map<String, dynamic>> items = {};
  void add(String id, Map<String, dynamic> product) {
    final existing = items[id];
    items[id] = {...product, 'quantity': (existing?['quantity'] as int? ?? 0) + 1};
  }
  void change(String id, int delta) {
    final item = items[id];
    if (item == null) return;
    final quantity = (item['quantity'] as int) + delta;
    if (quantity <= 0) { items.remove(id); } else { item['quantity'] = quantity; }
  }
  double get total => items.values.fold<double>(0.0, (sum, item) => sum + ((item['price'] as num).toDouble() * (item['quantity'] as int)));
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Shop products'), actions: [
      IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())).then((_) => setState(() {})), icon: Badge(label: Text(CartService.instance.items.length.toString()), child: const Icon(Icons.shopping_cart_outlined))),
    ]),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db.collection('products').where('status', isEqualTo: 'active').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Could not load products: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final products = snapshot.data!.docs;
        if (products.isEmpty) return const Center(child: Text('No products available yet.'));
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
                onPressed: stock > 0 ? () {
                  CartService.instance.add(doc.id, p);
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
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _address = TextEditingController();
  bool _busy = false;
  @override
  void dispose() { _address.dispose(); super.dispose(); }

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in before placing an order.')));
      return;
    }
    if (_address.text.trim().isEmpty || CartService.instance.items.isEmpty) return;
    setState(() => _busy = true);
    try {
      final cart = CartService.instance;
      final lines = cart.items.entries.map((entry) => {
        'productId': entry.key,
        'title': entry.value['title'],
        'unitPrice': entry.value['price'],
        'quantity': entry.value['quantity'],
        'lineTotal': (entry.value['price'] as num) * (entry.value['quantity'] as int),
      }).toList();
      await FirebaseFirestore.instance.collection('orders').add({
        'customerUid': user.uid,
        'items': lines,
        'total': cart.total,
        'deliveryAddress': _address.text.trim(),
        'status': 'pending',
        'paymentMethod': 'cash_on_delivery',
        'paymentStatus': 'unpaid',
        'createdAt': FieldValue.serverTimestamp(),
      });
      cart.items.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed. Pay cash on delivery.')));
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
      appBar: AppBar(title: const Text('Your cart')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (cart.items.isEmpty) const Padding(padding: EdgeInsets.all(30), child: Text('Your cart is empty.', textAlign: TextAlign.center)),
        ...cart.items.entries.map((entry) {
          final p = entry.value;
          return Card(child: ListTile(
            title: Text(p['title']?.toString() ?? 'Product'),
            subtitle: Text('BDT ${p['price']} × ${p['quantity']}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(onPressed: () => setState(() => cart.change(entry.key, -1)), icon: const Icon(Icons.remove_circle_outline)),
              IconButton(onPressed: () => setState(() => cart.change(entry.key, 1)), icon: const Icon(Icons.add_circle_outline)),
            ]),
          ));
        }),
        if (cart.items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Total: BDT ${cart.total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(controller: _address, maxLines: 3, decoration: const InputDecoration(labelText: 'Delivery address', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          FilledButton(onPressed: _busy ? null : _placeOrder, child: _busy ? const CircularProgressIndicator() : const Text('Place order • Cash on delivery')),
        ],
      ]),
    );
  }
}
