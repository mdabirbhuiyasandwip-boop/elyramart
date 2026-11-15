import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyListingsPage extends StatefulWidget {
  const PropertyListingsPage({super.key, this.english = true});
  final bool english;

  @override
  State<PropertyListingsPage> createState() => _PropertyListingsPageState();
}

class _PropertyListingsPageState extends State<PropertyListingsPage> {
  final _search = TextEditingController();
  final _maxRent = TextEditingController();
  String _query = '';
  double? _rentLimit;

  @override
  void dispose() {
    _search.dispose();
    _maxRent.dispose();
    super.dispose();
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.english ? 'Could not open phone app.' : 'ফোন অ্যাপ খোলা যায়নি।')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = widget.english;
    return Scaffold(
      appBar: AppBar(title: Text(en ? 'Find a home' : 'বাসা খুঁজুন')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: en ? 'Search city, area or property...' : 'শহর, এলাকা বা বাসা খুঁজুন...',
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _maxRent,
              keyboardType: TextInputType.number,
              onChanged: (v) => setState(() => _rentLimit = double.tryParse(v.trim())),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.payments_outlined),
                hintText: en ? 'Max monthly rent (BDT)' : 'সর্বোচ্চ মাসিক ভাড়া (টাকা)',
                border: const OutlineInputBorder(),
              ),
            )),
            const SizedBox(width: 8),
            IconButton(
              tooltip: en ? 'Clear filters' : 'ফিল্টার মুছুন',
              onPressed: () { _search.clear(); _maxRent.clear(); setState(() { _query = ''; _rentLimit = null; }); },
              icon: const Icon(Icons.filter_alt_off_outlined),
            ),
          ]),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('propertyListings')
                .where('status', isEqualTo: 'active').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text(en ? 'Could not load listings: ${snapshot.error}' : 'বাসার তালিকা লোড হয়নি: ${snapshot.error}'));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final listings = snapshot.data!.docs.where((doc) {
                final p = doc.data();
                final searchable = [p['title'], p['city'], p['area'], p['description'], p['propertyType']]
                    .whereType<Object>().join(' ').toLowerCase();
                final rent = (p['monthlyRent'] as num?)?.toDouble() ?? 0;
                return searchable.contains(_query) && (_rentLimit == null || rent <= _rentLimit!);
              }).toList();
              if (listings.isEmpty) {
                return Center(child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    en ? 'No matching verified home listings yet. Try another area or rent range.'
                       : 'মিলছে এমন যাচাইকৃত বাসার বিজ্ঞাপন এখনো নেই। অন্য এলাকা বা ভাড়ার সীমা দিয়ে খুঁজুন।',
                    textAlign: TextAlign.center,
                  ),
                ));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final p = listings[index].data();
                  final image = p['imageUrl']?.toString() ?? '';
                  final phone = p['phone']?.toString() ?? '';
                  final rent = (p['monthlyRent'] as num?)?.toStringAsFixed(0) ?? '—';
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      if (image.isNotEmpty)
                        Image.network(image, height: 170, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(height: 80, child: Icon(Icons.home_work_outlined, size: 42)))
                      else
                        const SizedBox(height: 90, child: Icon(Icons.home_work_outlined, size: 42)),
                      ListTile(
                        title: Text(p['title']?.toString() ?? (en ? 'Home for rent' : 'ভাড়ার বাসা')),
                        subtitle: Text('${p['area'] ?? ''}, ${p['city'] ?? ''}\nBDT $rent / ${en ? 'month' : 'মাস'} • ${p['bedrooms'] ?? '—'} ${en ? 'bedrooms' : 'বেডরুম'}\n${p['description'] ?? ''}'),
                        isThreeLine: true,
                      ),
                      if (phone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Align(alignment: Alignment.centerRight, child: FilledButton.icon(
                            onPressed: () => _call(phone),
                            icon: const Icon(Icons.call),
                            label: Text(en ? 'Contact advertiser' : 'বিজ্ঞাপনদাতাকে কল করুন'),
                          )),
                        ),
                    ]),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}
