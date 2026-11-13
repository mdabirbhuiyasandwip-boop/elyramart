import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show IdTokenResult;
import '../services/auth_service.dart';
import 'admin_page.dart';
import 'seller_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _auth = AuthService();
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String _message = '';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _busy = true; _message = ''; });
    try {
      if (_register) {
        await _auth.registerCustomer(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          phone: _phone.text,
        );
      } else {
        await _auth.signIn(email: _email.text, password: _password.text);
      }
      if (!mounted) return;
      setState(() => _message = 'Signed in successfully.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sellerApplication() async {
    final shop = TextEditingController();
    final phone = TextEditingController();
    final address = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seller application'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: shop, decoration: const InputDecoration(labelText: 'Shop / business name')),
          TextField(controller: phone, decoration: const InputDecoration(labelText: 'Contact number'), keyboardType: TextInputType.phone),
          TextField(controller: address, decoration: const InputDecoration(labelText: 'Shop address')),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit')),
        ],
      ),
    );
    if (ok == true && shop.text.trim().isNotEmpty && phone.text.trim().isNotEmpty && address.text.trim().isNotEmpty) {
      try {
        await _auth.submitSellerApplication(shopName: shop.text, phone: phone.text, address: address.text);
        if (mounted) setState(() => _message = 'Seller application submitted for review.');
      } catch (e) {
        if (mounted) setState(() => _message = e.toString());
      }
    }
    shop.dispose(); phone.dispose(); address.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My account')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          const CircleAvatar(radius: 34, child: Icon(Icons.person, size: 36)),
          const SizedBox(height: 12),
          Text(user.displayName ?? user.email ?? 'Elyramart user', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          FutureBuilder<Map<String, dynamic>?>(
            future: _auth.loadMyProfile(),
            builder: (context, snapshot) {
              if (snapshot.data?['role'] == 'seller') return FilledButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SellerPage())),
                icon: const Icon(Icons.storefront), label: const Text('Open seller dashboard'));
              return const SizedBox.shrink();
            },
          ),
          FutureBuilder<IdTokenResult>(
            future: user.getIdTokenResult(true),
            builder: (context, snapshot) {
              final isAdmin = snapshot.data?.claims?['admin'] == true;
              if (snapshot.hasError) return const Text('Could not verify account permissions.');
              if (isAdmin) return FilledButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPage())),
                icon: const Icon(Icons.admin_panel_settings), label: const Text('Open admin dashboard'));
              return const SizedBox.shrink();
            },
          ),
          FilledButton.icon(onPressed: _sellerApplication, icon: const Icon(Icons.storefront_outlined), label: const Text('Apply as a seller')),
          OutlinedButton.icon(onPressed: () async { await _auth.signOut(); if (mounted) setState(() {}); }, icon: const Icon(Icons.logout), label: const Text('Sign out')),
          if (_message.isNotEmpty) Text(_message),
        ]),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Elyramart account')),
      body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(22), child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.account_circle_outlined, size: 64),
          const SizedBox(height: 12),
          Text(_register ? 'Create customer account' : 'Welcome back', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          if (_register) ...[
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder()), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number', border: OutlineInputBorder()), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter phone number' : null),
            const SizedBox(height: 12),
          ],
          TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', border: OutlineInputBorder()), validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password (minimum 6 characters)', border: OutlineInputBorder()), validator: (v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null),
          const SizedBox(height: 16),
          FilledButton(onPressed: _busy ? null : _submit, child: _busy ? const CircularProgressIndicator() : Text(_register ? 'Create account' : 'Sign in')),
          TextButton(onPressed: _busy ? null : () => setState(() { _register = !_register; _message = ''; }), child: Text(_register ? 'Already have an account? Sign in' : 'New here? Create an account')),
          if (_message.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_message, textAlign: TextAlign.center)),
        ]),
      ))),
    );
  }
}
