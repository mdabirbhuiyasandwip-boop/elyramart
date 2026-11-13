import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _db = FirebaseFirestore.instance;
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _category = TextEditingController();
  final _stock = TextEditingController(text: '1');
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose(); _price.dispose(); _category.dispose(); _stock.dispose();
    super.dispose();
  }

  Future<void> _addProduct() async {
    final price = double.tryParse(_price.text.trim());
    final stock = int.tryParse(_stock.text.trim());
    if (_title.text.trim().isEmpty || _category.text.trim().isEmpty || price == null || price <= 0 || stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid product details.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await _db.collection('products').add({
        'title': _title.text.trim(),
        'category': _category.text.trim(),
        'price': price,
        'stock': stock,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _title.clear(); _price.clear(); _category.clear(); _stock.text = '1';
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save product: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showAddProduct() async {
    await showDialog<void>(context: context, builder: (context) => AlertDialog(
      title: const Text('Add product'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'Product name')),
        TextField(controller: _category, decoration: const InputDecoration(labelText: 'Category')),
        TextField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price (BDT)')),
        TextField(controller: _stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock quantity')),
      ])),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _addProduct, child: _saving ? const CircularProgressIndicator() : const Text('Save product')),
      ],
    ));
  }

  Future<void> _approveSeller(String uid) async {
    final batch = _db.batch();
    batch.update(_db.collection('sellerApplications').doc(uid), {'status': 'approved', 'reviewedAt': FieldValue.serverTimestamp()});
    batch.set(_db.collection('users').doc(uid), {'role': 'seller', 'sellerApprovedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> _rejectSeller(String uid) async {
    await _db.collection('sellerApplications').doc(uid).update({'status': 'rejected', 'reviewedAt': FieldValue.serverTimestamp()});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Elyramart Admin')),
    floatingActionButton: FloatingActionButton.extended(onPressed: _showAddProduct, icon: const Icon(Icons.add), label: const Text('Add product')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Text('Seller applications', style: Theme.of(context).textTheme.titleLarge),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('sellerApplications').where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Seller applications error: ${snapshot.error}');
          if (!snapshot.hasData) return const LinearProgressIndicator();
          if (snapshot.data!.docs.isEmpty) return const ListTile(title: Text('No pending applications'));
          return Column(children: snapshot.data!.docs.map((doc) {
            final data = doc.data();
            return Card(child: ListTile(
              title: Text(data['shopName']?.toString() ?? 'Seller'),
              subtitle: Text('${data['phone'] ?? ''} • ${data['address'] ?? ''}'),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                onSelected: (v) async {
                  try { if (v == 'approve') { await _approveSeller(doc.id); } else { await _rejectSeller(doc.id); } }
                  catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
                },
                itemBuilder: (_) => const [PopupMenuItem(value: 'approve', child: Text('Approve')), PopupMenuItem(value: 'reject', child: Text('Reject'))],
              ),
            ));
          }).toList());
        },
      ),
      const SizedBox(height: 20),
      Text('Products', style: Theme.of(context).textTheme.titleLarge),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('products').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Products error: ${snapshot.error}');
          if (!snapshot.hasData) return const LinearProgressIndicator();
          if (snapshot.data!.docs.isEmpty) return const ListTile(title: Text('No products added yet'));
          return Column(children: snapshot.data!.docs.map((doc) {
            final p = doc.data();
            return Card(child: ListTile(
              title: Text(p['title']?.toString() ?? 'Product'),
              subtitle: Text('${p['category'] ?? ''} • BDT ${p['price'] ?? 0} • Stock: ${p['stock'] ?? 0}'),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => doc.reference.delete()),
            ));
          }).toList());
        },
      ),
      const SizedBox(height: 20),
      Text('Recent orders', style: Theme.of(context).textTheme.titleLarge),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _db.collection('orders').orderBy('createdAt', descending: true).limit(30).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Orders error: ${snapshot.error}');
          if (!snapshot.hasData) return const LinearProgressIndicator();
          if (snapshot.data!.docs.isEmpty) return const ListTile(title: Text('No orders yet'));
          return Column(children: snapshot.data!.docs.map((doc) {
            final o = doc.data();
            return Card(child: ListTile(
              title: Text('Order ${doc.id.substring(0, 6)}'),
              subtitle: Text('Status: ${o['status'] ?? 'pending'} • Total: BDT ${o['total'] ?? 0}'),
              trailing: PopupMenuButton<String>(
                tooltip: 'Update order status',
                onSelected: (status) async {
                  try {
                    await doc.reference.update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'confirmed', child: Text('Confirm')),
                  PopupMenuItem(value: 'processing', child: Text('Processing')),
                  PopupMenuItem(value: 'out_for_delivery', child: Text('Out for delivery')),
                  PopupMenuItem(value: 'delivered', child: Text('Delivered')),
                  PopupMenuItem(value: 'cancelled', child: Text('Cancel order')),
                ],
              ),
            ));
          }).toList());
        },
      ),
      const SizedBox(height: 80),
    ]),
  );
}
