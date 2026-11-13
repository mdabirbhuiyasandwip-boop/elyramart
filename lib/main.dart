import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/account_page.dart';

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
        _category(Icons.medication_outlined, en ? 'Medicine' : 'ওষুধ'),
        _category(Icons.shopping_basket_outlined, en ? 'Grocery' : 'মুদি'),
        _category(Icons.face_retouching_natural, en ? 'Beauty & Care' : 'কসমেটিকস'),
        _category(Icons.plumbing_outlined, en ? 'Plumbing' : 'প্লাম্বিং'),
        _category(Icons.electrical_services_outlined, en ? 'Technician' : 'টেকনিশিয়ান'),
        _category(Icons.delivery_dining, en ? 'Delivery' : 'ডেলিভারি'),
      ]),
    const SizedBox(height: 18),
    Card(child: ListTile(leading: const Icon(Icons.info_outline), title: Text(en ? 'Marketplace preview' : 'মার্কেটপ্লেস প্রিভিউ'),
      subtitle: Text(en ? 'Products and sellers will appear after admin setup.' : 'অ্যাডমিন সেটআপের পর পণ্য ও বিক্রেতা দেখা যাবে।'))),
  ]);

  Widget _category(IconData icon, String label) => Card(child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () {},
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 30, color: brand), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))])));

  Widget _orders(bool en) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.receipt_long_outlined, size: 54, color: Colors.grey), const SizedBox(height: 12),
    Text(en ? 'No orders yet' : 'এখনো কোনো অর্ডার নেই'),
    Text(en ? 'Your orders will appear here.' : 'আপনার অর্ডার এখানে দেখা যাবে।'),
  ]));

  Widget _services(bool en) => ListView(padding: const EdgeInsets.all(16), children: [
    Text(en ? 'Home services' : 'হোম সার্ভিস', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    for (final item in (en ? ['Electrician','Plumber','Appliance technician'] : ['ইলেকট্রিশিয়ান','প্লাম্বার','ইলেকট্রনিক্স টেকনিশিয়ান']))
      Card(child: ListTile(leading: const Icon(Icons.build_outlined), title: Text(item), trailing: const Icon(Icons.chevron_right))),
    Card(child: ListTile(leading: const Icon(Icons.delivery_dining), title: Text(en ? 'Request a delivery' : 'ডেলিভারি অনুরোধ'), subtitle: Text(en ? 'Coming soon' : 'শীঘ্রই আসছে'))),
  ]);

  Widget _settings(bool en) => ListView(children: [
    ListTile(leading: const Icon(Icons.language), title: Text(en ? 'App language' : 'অ্যাপের ভাষা'),
      subtitle: Text(en ? 'English' : 'বাংলা'), trailing: Switch(value: english, onChanged: (v) => setState(() => english = v))),
    const ListTile(leading: Icon(Icons.admin_panel_settings_outlined), title: Text('Admin access'),
      subtitle: Text('Admin login and role permissions require secure Firebase setup.')),
    const ListTile(leading: Icon(Icons.info_outline), title: Text('Elyramart'), subtitle: Text('Marketplace app • Preview build')),
  ]);

  void _showAccount(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AccountPage()));
  }
}
