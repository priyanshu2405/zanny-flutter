import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'shell.dart';

DateTime _combine(DateTime d, TimeOfDay t) => DateTime(d.year, d.month, d.day, t.hour, t.minute);
List<String> _guestOptions([int max = 30]) => [for (var i = 1; i <= max; i++) '$i Guest${i > 1 ? 's' : ''}'];

/// Multi-step form scaffold: device back goes to the previous step.
class _Steps extends StatelessWidget {
  final String title;
  final int step;
  final VoidCallback onBack;
  final Widget child;
  const _Steps({required this.title, required this.step, required this.onBack, required this.child});
  @override
  Widget build(BuildContext context) => PopScope(
        canPop: step == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) onBack();
        },
        child: Scaffold(
          appBar: ZAppBar(title),
          body: AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: KeyedSubtree(key: ValueKey(step), child: child)),
        ),
      );
}

// ─── Figma p10–p12 — Reserve a Table ─────────────────────────────────────

class ReserveTableScreen extends StatefulWidget {
  final String? activity;
  final DateTime? date;
  final String? note;
  const ReserveTableScreen({super.key, this.activity, this.date, this.note});
  @override
  State<ReserveTableScreen> createState() => _ReserveTableScreenState();
}

class _ReserveTableScreenState extends State<ReserveTableScreen> {
  int _step = 0;
  final _forms = List.generate(3, (_) => GlobalKey<FormState>());
  late final AppState _s = AppScope.read(context);

  // Step 1
  late DateTime? _date = (widget.date != null && widget.date!.isAfter(DateTime.now())) ? widget.date : null;
  TimeOfDay? _time;
  String _guests = '1 Guest';
  late String _activity = activityTypes.contains(widget.activity) ? widget.activity! : activityTypes.first;
  String _allParticipating = 'Yes';
  final _participants = TextEditingController();
  final _nonParticipants = TextEditingController();
  // Step 2
  late final _name = TextEditingController(text: _s.loggedIn ? _s.name : '');
  late final _email = TextEditingController(text: _s.loggedIn ? _s.email : '');
  late final _phone = TextEditingController(text: _s.loggedIn ? _s.phone : '');
  String _pay = paymentPrefs.first;
  String _occasion = 'Birthday';
  final _ack = [false, false, false];
  String _heard = referralSources.first;
  // Step 3
  late final _anything = TextEditingController(text: widget.note ?? '');
  final _details = TextEditingController();
  bool _terms = false;
  bool _updates = true;

  int get _guestCount => int.parse(_guests.split(' ').first);

  void _next() {
    if (_step == 0) {
      if (_date == null || _time == null) return toast(context, 'Select a date and time for your reservation.');
      if (!_forms[0].currentState!.validate()) return;
    }
    if (_step == 1) {
      if (!_forms[1].currentState!.validate()) return;
      if (_ack.contains(false)) return toast(context, 'Please confirm the studio information to continue.');
    }
    setState(() => _step++);
  }

  void _submit() {
    if (!_terms) return toast(context, 'Please agree to the Terms & Conditions.');
    final when = _combine(_date!, _time!);
    final b = _s.addBooking('Table: $_activity', when, '$_guests · $_pay${_occasion == 'None' ? '' : ' · $_occasion'}');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingDoneScreen(booking: b)));
  }

  @override
  Widget build(BuildContext context) {
    final steps = [_one(), _two(), _three()];
    return _Steps(title: 'Reserve a Table', step: _step, onBack: () => setState(() => _step--), child: steps[_step]);
  }

  Widget _one() => Form(
        key: _forms[0],
        child: ListView(padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), children: [
          const SectionHeading('Reservation Information', top: 12),
          DateField(label: 'Select Date', value: _date, onPicked: (d) => setState(() => _date = d)),
          TimeField(label: 'Select Time', value: _time, onPicked: (t) => setState(() => _time = t)),
          ZDropdown(label: 'Number of Guests', value: _guests, items: _guestOptions(), onChanged: (v) => setState(() => _guests = v)),
          ZDropdown(label: 'Activity Type', value: _activity, items: activityTypes, onChanged: (v) => setState(() => _activity = v)),
          ZDropdown(
              label: 'Are All Guests Participating?',
              value: _allParticipating,
              items: const ['Yes', 'No'],
              onChanged: (v) => setState(() => _allParticipating = v)),
          if (_allParticipating == 'No') ...[
            Padding(padding: const EdgeInsets.only(top: 16), child: Text('If No', style: p(14, w: FontWeight.w500))),
            ZField(
              label: 'Number of Participants',
              controller: _participants,
              keyboard: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 1) return 'Enter how many guests will paint or create';
                if (n > _guestCount) return 'Can’t be more than $_guestCount guests';
                return null;
              },
            ),
            ZField(
              label: 'Number of Non-Participants',
              controller: _nonParticipants,
              keyboard: TextInputType.number,
              validator: (v) {
                final a = int.tryParse(_participants.text) ?? 0, b = int.tryParse(v ?? '');
                if (b == null) return 'Enter a number (0 if none)';
                if (a + b != _guestCount) return 'Participants + non-participants should equal $_guestCount';
                return null;
              },
            ),
          ],
          const SizedBox(height: 20),
          ZButton('Next', onPressed: _next),
        ]),
      );

  Widget _two() => Form(
        key: _forms[1],
        child: ListView(padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), children: [
          const SectionHeading('Contact Information', top: 12),
          ZField(label: 'Full Name', controller: _name, validator: requiredV),
          ZField(label: 'Email Address', controller: _email, keyboard: TextInputType.emailAddress, validator: emailV),
          ZField(label: 'Phone Number', controller: _phone, keyboard: TextInputType.phone, validator: phoneV),
          const SectionHeading('Payment Preferences'),
          ZDropdown(label: 'How Would You Like To Pay?', value: _pay, items: paymentPrefs, onChanged: (v) => setState(() => _pay = v)),
          const SectionHeading('Special Occasion'),
          ZDropdown(label: 'Are You Celebrating Anything Special?', value: _occasion, items: occasions, onChanged: (v) => setState(() => _occasion = v)),
          const SectionHeading('Studio Information'),
          const SizedBox(height: 8),
          for (final (i, t) in const [
            'I understand reservations are held for 15 minutes after the scheduled start time.',
            'I understand project completion and pickup times may vary depending on firing and finishing requirements.',
            'I understand all guests must follow studio safety guidelines.',
          ].indexed)
            CheckLine(value: _ack[i], onChanged: (v) => setState(() => _ack[i] = v), label: Text(t, style: p(13))),
          ZDropdown(label: 'How Did You Hear About Us?', value: _heard, items: referralSources, onChanged: (v) => setState(() => _heard = v)),
          const SizedBox(height: 24),
          ZButton('Next', onPressed: _next),
        ]),
      );

  Widget _three() => ListView(padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), children: [
        const SectionHeading('Additional Comments', top: 12),
        ZField(label: 'Anything We Should Know?', controller: _anything),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 0, 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Examples:', style: p(12.5)),
            const SizedBox(width: 10),
            const Expanded(
                child: Bullets(['Wheelchair accessibility needs', 'First-time visitors', 'Birthday surprise', 'Group seating request'],
                    size: 12.5, gap: 0)),
          ]),
        ),
        ZField(label: 'Additional Details', controller: _details, maxLines: 6),
        const SizedBox(height: 10),
        CheckLine(value: _terms, onChanged: (v) => setState(() => _terms = v), label: Text('I agree to the Terms & Conditions', style: p(13))),
        CheckLine(
            value: _updates,
            onChanged: (v) => setState(() => _updates = v),
            label: Text('I agree to receive booking updates and pickup notifications via email or SMS', style: p(13))),
        const SizedBox(height: 40),
        ZButton('Submit', onPressed: _submit),
      ]);
}

// ─── Figma p13–p14 — Party Booking ───────────────────────────────────────

class PartyBookingScreen extends StatefulWidget {
  final String? eventType;
  const PartyBookingScreen({super.key, this.eventType});
  @override
  State<PartyBookingScreen> createState() => _PartyBookingScreenState();
}

class _PartyBookingScreenState extends State<PartyBookingScreen> {
  int _step = 0;
  final _forms = List.generate(2, (_) => GlobalKey<FormState>());
  late final AppState _s = AppScope.read(context);
  late final _name = TextEditingController(text: _s.loggedIn ? _s.name : '');
  late final _email = TextEditingController(text: _s.loggedIn ? _s.email : '');
  late final _phone = TextEditingController(text: _s.loggedIn ? _s.phone : '');
  late String _type = partyEventTypes.contains(widget.eventType) ? widget.eventType! : partyEventTypes.first;
  String _activity = partyActivities.first;
  DateTime? _date;
  TimeOfDay? _time;
  String _guests = '8 Guests';
  String _age = '5 to 10';
  final _budget = TextEditingController();
  String _food = 'Yes';
  final _requests = TextEditingController();
  bool _deposit = false;

  void _submit() {
    if (_date == null || _time == null) return toast(context, 'Select a preferred date and time.');
    if (!_forms[1].currentState!.validate()) return;
    if (!_deposit) return toast(context, 'Please accept the deposit agreement to book your event.');
    final b = _s.addBooking(_type, _combine(_date!, _time!), '$_guests · $_activity · Ages $_age');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingDoneScreen(booking: b)));
  }

  @override
  Widget build(BuildContext context) => _Steps(
        title: 'Party Booking',
        step: _step,
        onBack: () => setState(() => _step--),
        child: _step == 0 ? _one() : _two(),
      );

  Widget _one() => Form(
        key: _forms[0],
        child: ListView(padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), children: [
          const SectionHeading('Contact Information', top: 12),
          ZField(label: 'Full Name', controller: _name, validator: requiredV),
          ZField(label: 'Email Address', controller: _email, keyboard: TextInputType.emailAddress, validator: emailV),
          ZField(label: 'Phone Number', controller: _phone, keyboard: TextInputType.phone, validator: phoneV),
          const SectionHeading('Book a Party or Private Event'),
          ZDropdown(label: 'Event Type', value: _type, items: partyEventTypes, onChanged: (v) => setState(() => _type = v)),
          ZDropdown(label: 'Activity Type', value: _activity, items: partyActivities, onChanged: (v) => setState(() => _activity = v)),
          const SizedBox(height: 28),
          ZButton('Next', onPressed: () {
            if (_forms[0].currentState!.validate()) setState(() => _step = 1);
          }),
        ]),
      );

  Widget _two() => Form(
        key: _forms[1],
        child: ListView(padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), children: [
          const SectionHeading('Reservation Information', top: 12),
          DateField(
            label: 'Preferred Date',
            value: _date,
            first: DateTime.now().add(const Duration(days: 14)),
            onPicked: (d) => setState(() => _date = d),
          ),
          TimeField(label: 'Preferred Time', value: _time, onPicked: (t) => setState(() => _time = t)),
          ZDropdown(label: 'Number of Guests', value: _guests, items: _guestOptions(60), onChanged: (v) => setState(() => _guests = v)),
          ZDropdown(label: 'Age Group', value: _age, items: ageGroups, onChanged: (v) => setState(() => _age = v)),
          ZField(
            label: 'Budget Per Person',
            hint: 'e.g. 35',
            controller: _budget,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            suffix: Padding(padding: const EdgeInsets.all(14), child: Text('CAD', style: p(12, c: Z.sub))),
          ),
          ZDropdown(label: 'Food & Beverage Plans', value: _food, items: const ['Yes', 'No', 'Not sure yet'], onChanged: (v) => setState(() => _food = v)),
          ZField(label: 'Special Requests', controller: _requests, maxLines: 6),
          const SectionHeading('Deposit Agreement'),
          CheckLine(
            value: _deposit,
            onChanged: (v) => setState(() => _deposit = v),
            label: Text('I understand a non-refundable deposit is required to secure my event booking.', style: p(13)),
          ),
          const SizedBox(height: 24),
          ZButton('Submit', onPressed: _submit),
        ]),
      );
}

// ─── Booking received (styled after Figma p30 confirmation) ──────────────

class BookingDoneScreen extends StatelessWidget {
  final Booking booking;
  const BookingDoneScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    void home(int tab) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      ShellController.go(tab);
    }

    return Scaffold(
      appBar: const ZAppBar('Successful', close: true),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 24), children: [
        Text('Confirmation', style: p(17, w: FontWeight.w600)),
        const SizedBox(height: 40),
        const Center(
          child: CircleAvatar(radius: 42, backgroundColor: Color(0xFFFDE3D8), child: Icon(Icons.event_available, color: Z.orange, size: 40)),
        ),
        const SizedBox(height: 18),
        Text('Your Booking Has Been Received', textAlign: TextAlign.center, style: p(15, w: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('We’ll confirm your booking by email and SMS shortly. You can follow its status in My Bookings.',
            textAlign: TextAlign.center, style: p(12.5, c: Z.sub)),
        const SizedBox(height: 36),
        KV('Booking No', booking.orderNo, keyWidth: 110),
        KV('Booking for', booking.bookingFor, keyWidth: 110),
        KV('Date & Time', DateFormat("dd MMM ''yy  hh:mm a").format(booking.dateTime), keyWidth: 110),
        if (booking.summary.isNotEmpty) KV('Details', booking.summary, keyWidth: 110),
        KV('Status', booking.status.label, keyWidth: 110),
        const SizedBox(height: 36),
        ZButton('View My Bookings', onPressed: () => home(1)),
        const SizedBox(height: 12),
        ZButton('Back to Home', outlined: true, onPressed: () => home(0)),
      ]),
    );
  }
}
