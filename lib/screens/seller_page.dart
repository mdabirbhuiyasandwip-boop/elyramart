import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final _picker = ImagePicker();
  XFile? _image;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (picked != null && mounted) setState(() => _image = picked);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select image: $e')),
        );
      }
    }
  }

  Future<String> _uploadImage(String uid) async {
    final file = _image;
    if (file == null) return '';
    final ref = FirebaseStorage.instance
        .ref()
        .child('product-images')
        .child(uid)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putFile(
      File(file.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return task.ref.getDownloadURL();
  }

  Future<void> _addProduct() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final price = double.tryParse(_price.text.trim());
    final stock = int.tryParse(_stock.text.trim());
    if (_name.text.trim().length < 2 ||
        _category.text.trim().isEmpty ||
        price == null ||
        !price.isFinite ||
        price <= 0 ||
        stock == null ||
        stock < 0 ||
        stock > 100000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid product details.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final imageUrl = await _uploadImage(user.uid);
      await _db.collection('products').add({
        'title': _name.text.trim(),
        'category': _category.text.trim(),
        'price': price,
        'stock': stock,
        'sellerUid': user.uid,
        'imageUrl': imageUrl.isEmpty ? null : imageUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      _name.clear();
      _category.clear();
      _price.clear();
      _stock.text = '1';
      if (mounted) {
        setState(() => _image = null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product submitted for admin approval.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Seller dashboard')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Add a product', style: Theme.of(context).textTheme.titleLarge),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Product name')),
            TextField(controller: _category, decoration: const InputDecoration(labelText: 'Category')),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Price (BDT)'),
            ),
            TextField(
              controller: _stock,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock quantity'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _pickImage,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(_image == null ? 'Choose product photo (optional)' : 'Change product photo'),
            ),
            if (_image != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(_image!.path), height: 170, fit: BoxFit.cover),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy ? null : _addProduct,
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit for approval'),
            ),
            const SizedBox(height: 24),
            Text('My products', style: Theme.of(context).textTheme.titleLarge),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db
                  .collection('products')
                  .where('sellerUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Could not load products: ${snapshot.error}');
                if (!snapshot.hasData) return const LinearProgressIndicator();
                if (snapshot.data!.docs.isEmpty) {
                  return const ListTile(title: Text('No submitted products yet.'));
                }
                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final p = doc.data();
                    final imageUrl = p['imageUrl']?.toString() ?? '';
                    return Card(
                      child: ListTile(
                        leading: imageUrl.isEmpty
                            ? const CircleAvatar(child: Icon(Icons.inventory_2_outlined))
                            : Image.network(imageUrl, width: 52, height: 52, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const CircleAvatar(child: Icon(Icons.broken_image_outlined))),
                        title: Text(p['title']?.toString() ?? 'Product'),
                        subtitle: Text('BDT ${p['price'] ?? 0} • Status: ${p['status'] ?? 'pending'}'),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      );
}
