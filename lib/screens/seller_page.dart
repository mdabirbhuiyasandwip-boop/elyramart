import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SellerPage extends StatefulWidget {
  const SellerPage({super.key});
  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  final _db = FirebaseFirestore.instance;
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '1');
  bool _busy = false;

  @override
  void dispose() { _name.dispose(); _category.dispose(); _price.dispose(); _stock.dispose(); super.dispose(); }

  Future<void> _addProduct() async {
    final user = FirebaseAuth.instance.currentUser!;
    final price = double.tryParse(_price.text.trim());
    final stock = int.tryParse(_stock.text.trim());
    if (_name.text.trim().isEmpty || _category.text.trim().isEmpty || price == null || price <= 0 || stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid product details.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await _db.collection('products').add({
        'title': _name.text.trim(), 'category': _category.text.trim(),
        'price': price, 'stock': stock, 'sellerUid': user.uid,
        'status': 'pending', 'createdAt': FieldValue.serverTimestamp(),
      });
      _name.clear(); _category.clear(); _price.clear(); _stock.text = '1';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product submitted for admin approval.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit product: $e')));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Seller dashboard')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Text('Add a product', style: Theme.of(context).textTheme.titleLarge),
      TextField(controller: _name, decoration: const InputDecoration(labelText: 'Product name')),
      TextField(controller: _category, decoration: const InputDecoration(labelText: 'Category')),
      TextField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price (BDT)')),
      TextField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock quantity')),
      const SizedBox(height: 12),
      FilledButton(onPressed: _busy ? null : _addProduct, child: _busy ? const CircularProgressIndicator() : const Text('Submit for approval')),
      const SizedBox(height: 24),
      Text('My products', style: Theme.of(context).textTheme.titleLarge),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('products').where('sellerUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Could not load products: ${snapshot.error}');
          if (!snapshot.hasData) return const LinearProgressIndicator();
          if (snapshot.data!.docs.isEmpty) return const ListTile(title: Text('No submitted products yet.'));
          return Column(children: snapshot.data!.docs.map((doc) {
            final p = doc.data();
            return ListTile(title: Text(p['title']?.toString() ?? 'Product'), subtitle: Text('Status: ${p['status'] ?? 'pending'}'));
          }).toList());
        },
      ),
    ]),
  );
}
