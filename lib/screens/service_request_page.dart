import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceRequestPage extends StatefulWidget {
  const ServiceRequestPage({
    super.key,
    required this.service,
    this.serviceCode = 'general',
    this.english = true,
  });

  final String service;
  final String serviceCode;
  final bool english;

  @override
  State<ServiceRequestPage> createState() => _ServiceRequestPageState();
}

class _ServiceRequestPageState extends State<ServiceRequestPage> {
  final _details = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _from = TextEditingController();
  final _to = TextEditingController();
  final _date = TextEditingController();
  final _endDate = TextEditingController();
  final _people = TextEditingController(text: '1');
  final _budget = TextEditingController();
  bool _busy = false;

  bool get _en => widget.english;
  bool get _isTravel => widget.serviceCode == 'bus' || widget.serviceCode == 'launch';
  bool get _isHotel => widget.serviceCode == 'hotel';
  bool get _isRent => widget.serviceCode == 'house_rent';
  bool get _isToll => widget.serviceCode == 'toll';

  @override
  void dispose() {
    _details.dispose();
    _address.dispose();
    _phone.dispose();
    _from.dispose();
    _to.dispose();
    _date.dispose();
    _endDate.dispose();
    _people.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_en ? 'Please sign in before sending a request.' : 'অনুরোধ পাঠাতে আগে লগইন করুন।'),
      ));
      return;
    }

    final details = _details.text.trim();
    final address = _address.text.trim();
    final phone = _phone.text.trim();
    final people = int.tryParse(_people.text.trim());

    if (details.length < 5 || address.length < 6 || phone.length < 6 ||
        ((_isTravel || _isToll) && (_from.text.trim().isEmpty || _to.text.trim().isEmpty)) ||
        ((_isTravel || _isHotel) && _date.text.trim().isEmpty) ||
        ((_isTravel || _isHotel) && (people == null || people < 1 || people > 30))) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_en ? 'Please complete the required fields correctly.' : 'প্রয়োজনীয় তথ্যগুলো সঠিকভাবে পূরণ করুন।'),
      ));
      return;
    }

    setState(() => _busy = true);
    try {
      await FirebaseFirestore.instance.collection('serviceRequests').add({
        'customerUid': user.uid,
        'service': widget.service,
        'serviceCode': widget.serviceCode,
        'details': details,
        'address': address,
        'phone': phone,
        'fromLocation': _from.text.trim(),
        'toLocation': _to.text.trim(),
        'startDate': _date.text.trim(),
        'endDate': _endDate.text.trim(),
        'peopleCount': people,
        'budget': _budget.text.trim(),
        'status': 'pending',
        'requestKind': 'information_or_booking_request',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_en
            ? 'Request submitted. This is a request only; availability and price will be confirmed by Elyramart.'
            : 'অনুরোধ জমা হয়েছে। এটি প্রাথমিক অনুরোধ—প্রাপ্যতা ও মূল্য এলিরামার্ট নিশ্চিত করবে।'),
      ));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_en ? 'Could not submit request: $e' : 'অনুরোধ জমা হয়নি: $e'),
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _field(TextEditingController controller, String label, {
    int lines = 1,
    TextInputType? keyboard,
    String? hint,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      maxLines: lines,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final title = _en ? 'Request ${widget.service}' : '${widget.service} অনুরোধ';
    return Scaffold(
      appBar: AppBar(title: Text(widget.service)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (_isRent)
            Text(_en ? 'Tell us which area and type of home you need.' : 'কোন এলাকায় এবং কী ধরনের বাসা চান লিখুন।'),
          if (_isHotel)
            Text(_en ? 'Send your stay details; the hotel must confirm availability.' : 'থাকার তথ্য দিন; হোটেল প্রাপ্যতা নিশ্চিত করবে।'),
          if (_isTravel)
            Text(_en ? 'Send your route and travel date; ticket availability is not live yet.' : 'রুট ও যাত্রার তারিখ দিন; এখনো লাইভ টিকিট ব্যবস্থা নয়।'),
          if (_isToll)
            Text(_en ? 'Tell us your route and vehicle details for toll information.' : 'টোল তথ্যের জন্য রুট ও গাড়ির বিবরণ দিন।'),
          const SizedBox(height: 14),
          if (_isTravel || _isToll) ...[
            _field(_from, _en ? 'From' : 'কোথা থেকে'),
            _field(_to, _en ? 'To' : 'কোথায়'),
          ],
          if (_isRent || _isHotel)
            _field(_address, _en ? 'Preferred city / area' : 'পছন্দের শহর / এলাকা'),
          if (_isTravel || _isHotel)
            _field(_date, _en ? (_isHotel ? 'Check-in date (YYYY-MM-DD)' : 'Travel date (YYYY-MM-DD)') : (_isHotel ? 'চেক-ইন তারিখ (YYYY-MM-DD)' : 'যাত্রার তারিখ (YYYY-MM-DD)')),
          if (_isHotel)
            _field(_endDate, _en ? 'Check-out date (YYYY-MM-DD)' : 'চেক-আউট তারিখ (YYYY-MM-DD)'),
          if (_isTravel || _isHotel)
            _field(_people, _en ? (_isHotel ? 'Number of guests' : 'Passengers') : (_isHotel ? 'অতিথির সংখ্যা' : 'যাত্রীর সংখ্যা'), keyboard: TextInputType.number),
          if (_isRent || _isHotel)
            _field(_budget, _en ? 'Budget (BDT, optional)' : 'বাজেট (টাকা, ঐচ্ছিক)', keyboard: TextInputType.number),
          if (_isToll)
            _field(_budget, _en ? 'Vehicle type / axle details' : 'গাড়ির ধরন / এক্সেল সংখ্যা'),
          if (!_isRent && !_isHotel)
            _field(_address, _en ? 'Your contact / pickup area' : 'আপনার ঠিকানা / পিকআপ এলাকা'),
          _field(_details, _en ? 'More details / requirements' : 'অতিরিক্ত তথ্য / প্রয়োজন', lines: 4),
          _field(_phone, _en ? 'Contact phone' : 'যোগাযোগের ফোন নম্বর', keyboard: TextInputType.phone),
          const SizedBox(height: 6),
          if (_isTravel || _isHotel || _isRent || _isToll)
            Text(
              _en
                  ? 'No ticket, room, toll payment or confirmed booking is made by submitting this form.'
                  : 'এই ফর্ম জমা দিলে টিকিট, রুম, টোল পেমেন্ট বা নিশ্চিত বুকিং সম্পন্ন হয় না।',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const CircularProgressIndicator()
                : Text(_en ? 'Submit request' : 'অনুরোধ জমা দিন'),
          ),
        ],
      ),
    );
  }
}
