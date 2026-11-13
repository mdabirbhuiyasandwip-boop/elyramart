import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'screens/account_page.dart';
import 'screens/catalog_page.dart';
import 'screens/service_request_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ElyramartApp());
}

class ElyramartApp extends StatefulWidget {
  const ElyramartApp({super.key});
  @override
  State<ElyramartApp> createState() => _ElyramartAppState();
}

class _ElyramartAppState extends State<ElyramartApp> {
  bool english = true;
  int tab = 0;
  final Color brand = const Color(0xFF176B52);

  @override
  Widget build(BuildContext context) {
    final t = english;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elyramart',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: brand), useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Container(width: 34, height: 34, alignment: Alignment.center,
              decoration: BoxDecoration(color: brand, borderRadius: BorderRadius.circular(10)),
              child: const Text('E', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22))),
            const SizedBox(width: 10),
            const Text('Elyramart', style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          actions: [
            IconButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CatalogPage())), icon: const Icon(Icons.storefront_outlined)),
            TextButton(onPressed: () => setState(() => english = !english),
              child: Text(english ? 'বাংলা' : 'English')),
            IconButton(onPressed: () => _showAccount(context), icon: const Icon(Icons.account_circle_outlined)),
          ],
        ),
        body: IndexedStack(index: tab, children: [
          _home(t), _orders(t), _services(t), _settings(t),
        ]),
        bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_outlined), label: t ? 'Home' : 'হোম'),
            NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), label: t ? 'Orders' : 'অর্ডার'),
            NavigationDestination(icon: const Icon(Icons.handyman_outlined), label: t ? 'Services' : 'সেবা'),
            NavigationDestination(icon: const Icon(Icons.settings_outlined), label: t ? 'Settings' : 'সেটিংস'),
          ]),
      ),
    );
  }

  Widget _home(bool en) => ListView(padding: const EdgeInsets.all(16), children: [
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFE7F3EE), borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(en ? 'Your world, your choice' : 'আপনার পছন্দ, আপনার দুনিয়া', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(en ? 'Shop essentials and request trusted home services.' : 'প্রয়োজনীয় পণ্য কিনুন এবং ঘরের সেবা নিন।'),
      ])),
    const SizedBox(height: 20),
    Text(en ? 'Explore categories' : 'ক্যাটাগরি দেখুন', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
      children: [
        _category(Icons.medication_outlined, en ? 'Medicine' : 'ওষুধ', 'medicine', en),
        _category(Icons.shopping_basket_outlined, en ? 'Grocery' : 'মুদি', 'grocery', en),
        _category(Icons.face_retouching_natural, en ? 'Beauty & Care' : 'কসমেটিকস', 'beauty', en),
        _category(Icons.plumbing_outlined, en ? 'Plumbing' : 'প্লাম্বিং', 'plumbing', en),
        _category(Icons.electrical_services_outlined, en ? 'Technician' : 'টেকনিশিয়ান', 'technician', en),
        _category(Icons.delivery_dining, en ? 'Delivery' : 'ডেলিভারি', 'delivery', en),
      ]),
    const SizedBox(height: 18),
    Card(child: ListTile(leading: const Icon(Icons.info_outline), title: Text(en ? 'Marketplace preview' : 'মার্কেটপ্লেস প্রিভিউ'),
      subtitle: Text(en ? 'Products and sellers will appear after admin setup.' : 'অ্যাডমিন সেটআপের পর পণ্য ও বিক্রেতা দেখা যাবে।'))),
  ]);

  Widget _category(IconData icon, String label, String category, bool en) => Card(child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => (category == 'plumbing' || category == 'technician' || category == 'delivery') ? ServiceRequestPage(service: category == 'plumbing' ? (en ? 'Plumber' : 'প্লাম্বার') : category == 'technician' ? (en ? 'Technician' : 'টেকনিশিয়ান') : (en ? 'Delivery' : 'ডেলিভারি')) : CatalogPage(category: category, english: en))),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 30, color: brand), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))])));

  Widget _orders(bool en) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Center(child: Text(en ? 'Sign in to view your orders.' : 'অর্ডার দেখতে লগইন করুন।'));
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('orders').where('customerUid', isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Could not load orders: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final orders = snapshot.data!.docs;
        if (orders.isEmpty) return Center(child: Text(en ? 'No orders yet' : 'এখনো কোনো অর্ডার নেই'));
        return ListView(padding: const EdgeInsets.all(12), children: orders.map((doc) {
          final data = doc.data();
          final items = data['items'] is List
              ? List<Map<String, dynamic>>.from(
                  (data['items'] as List).whereType<Map>().map((item) => Map<String, dynamic>.from(item)),
                )
              : <Map<String, dynamic>>[];
          return Card(
            child: ExpansionTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: Text('BDT ${data['total'] ?? 0}'),
              subtitle: Text(
                '${data['status'] ?? 'pending'} • '
                '${en ? 'Cash on delivery' : 'ক্যাশ অন ডেলিভারি'}',
              ),
              children: [
                for (final item in items)
                  ListTile(
                    dense: true,
                    title: Text(item['title']?.toString() ?? 'Product'),
                    subtitle: Text(
                      '× ${item['quantity'] ?? 1} • '
                      'BDT ${item['unitPrice'] ?? 0}',
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(data['phone']?.toString() ?? '—'),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(data['deliveryAddress']?.toString() ?? '—'),
                ),
              ],
            ),
          );
        }).toList());
      },
    );
  }

  Widget _services(bool en) => ListView(padding: const EdgeInsets.all(16), children: [
    Text(en ? 'Home services' : 'হোম সার্ভিস', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    for (final item in (en ? ['Electrician','Plumber','Appliance technician'] : ['ইলেকট্রিশিয়ান','প্লাম্বার','ইলেকট্রনিক্স টেকনিশিয়ান']))
      Card(child: ListTile(leading: const Icon(Icons.build_outlined), title: Text(item), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceRequestPage(service: item))))),
    Card(child: ListTile(leading: const Icon(Icons.delivery_dining), title: Text(en ? 'Request a delivery' : 'ডেলিভারি অনুরোধ'), subtitle: Text(en ? 'Send a delivery request' : 'ডেলিভারির অনুরোধ পাঠান'), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ServiceRequestPage(service: en ? 'Delivery' : 'ডেলিভারি'))))),
  ]);

  Widget _settings(bool en) => ListView(children: [
    ListTile(leading: const Icon(Icons.language), title: Text(en ? 'App language' : 'অ্যাপের ভাষা'),
      subtitle: Text(en ? 'English' : 'বাংলা'), trailing: Switch(value: english, onChanged: (v) => setState(() => english = v))),
    const ListTile(leading: Icon(Icons.admin_panel_settings_outlined), title: Text('Admin access'),
      subtitle: Text('Owner admin panel appears after secure Firebase admin approval.')),
    const ListTile(leading: Icon(Icons.info_outline), title: Text('Elyramart'), subtitle: Text('Marketplace app • Beta development build')),
  ]);

  void _showAccount(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountPage()));
  }
}
