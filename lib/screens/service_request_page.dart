import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceRequestPage extends StatefulWidget {
  const ServiceRequestPage({super.key, required this.service});
  final String service;
  @override
  State<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  final _details = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  bool _busy = false;
  @override
  void dispose() { _details.dispose(); _address.dispose(); _phone.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in before requesting a service.')));
      return;
    }
    if (_details.text.trim().length < 5 || _address.text.trim().length < 6 || _phone.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter service details, address and phone number.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance.collection('serviceRequests').add({
        'customerUid': user.uid, 'service': widget.service,
        'details': _details.text.trim(), 'address': _address.text.trim(),
        'phone': _phone.text.trim(), 'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service request submitted. Elyramart will contact you.')));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit request: $e')));
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.service)),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Text('Request ${widget.service}', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      TextField(controller: _details, maxLines: 4, decoration: const InputDecoration(labelText: 'Describe the problem or work needed', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Contact phone', border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(controller: _address, maxLines: 3, decoration: const InputDecoration(labelText: 'Service address', border: OutlineInputBorder())),
      const SizedBox(height: 18),
      FilledButton(onPressed: _busy ? null : _submit, child: _busy ? const CircularProgressIndicator() : const Text('Submit service request')),
    ]),
  );
}
