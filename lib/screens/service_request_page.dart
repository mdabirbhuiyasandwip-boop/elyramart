import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceRequestPage extends StatefulWidget {
  const ServiceRequestPage({
    super.key,
    required this.service,
    this.english = true,
  });
  final String service;
  final bool english;

  @override
  State<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  final _details = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  bool _busy = false;

  bool get _en => widget.english;

  @override
  void dispose() {
    _details.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_en
            ? 'Please sign in before requesting a service.'
            : 'সার্ভিস নিতে আগে লগইন করুন।'),
      ));
      return;
    }
    if (_details.text.trim().length < 5 ||
        _address.text.trim().length < 6 ||
        _phone.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_en
            ? 'Enter service details, address and phone number.'
            : 'কাজের বিবরণ, ঠিকানা ও ফোন নম্বর লিখুন।'),
      ));
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance.collection('serviceRequests').add({
        'customerUid': user.uid,
        'service': widget.service,
        'details': _details.text.trim(),
        'address': _address.text.trim(),
        'phone': _phone.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_en
            ? 'Service request submitted. Elyramart will contact you.'
            : 'সার্ভিস অনুরোধ জমা হয়েছে। এলিরামার্ট যোগাযোগ করবে।'),
      ));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_en
              ? 'Could not submit request: $e'
              : 'অনুরোধ জমা হয়নি: $e'),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.service)),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              _en ? 'Request ${widget.service}' : '${widget.service} অনুরোধ',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _details,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: _en
                    ? 'Describe the problem or work needed'
                    : 'সমস্যা বা প্রয়োজনীয় কাজের বিবরণ',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: _en ? 'Contact phone' : 'যোগাযোগের ফোন নম্বর',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _en ? 'Service address' : 'সার্ভিসের ঠিকানা',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const CircularProgressIndicator()
                  : Text(_en ? 'Submit service request' : 'সার্ভিস অনুরোধ জমা দিন'),
            ),
          ],
        ),
      );
}
