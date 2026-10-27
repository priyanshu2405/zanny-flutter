import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'reserve.dart';

/// Figma p18 — My Bookings.
class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: ZAppBar('My Bookings', actions: [
        IconButton(
          tooltip: 'New reservation',
          onPressed: () => pushRoot(context, const ReserveTableScreen()),
          icon: const Icon(Icons.add),
        ),
      ]),
      body: s.bookings.isEmpty
          ? _Empty(onBook: () => pushRoot(context, const ReserveTableScreen()))
          : ListView.separated(
              padding: const EdgeInsets.only(top: 6, bottom: 20),
              itemCount: s.bookings.length,
              separatorBuilder: (_, __) => const ThickDivider(),
              itemBuilder: (_, i) => _BookingCard(booking: s.bookings[i]),
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.read(context);
    final b = booking;
    final buttons = <Widget>[
      if (b.status == BookingStatus.pending || b.status == BookingStatus.accepted)
        SmallBtn('Cancel', outlined: true, onTap: () async {
          final ok = await confirm(context, 'Cancel booking ${b.orderNo}?',
              'Deposits for parties and private events are non-refundable.', yes: 'Cancel booking', no: 'Keep');
          if (ok) s.cancelBooking(b);
        }),
      if (b.status == BookingStatus.completed)
        SmallBtn(b.rating == null ? 'Give Rating' : 'Rated ${b.rating}★', outlined: true, onTap: () async {
          final r = await showFeedbackDialog(context, initial: b.rating ?? 0);
          if (r != null) {
            s.rateBooking(b, r);
            if (context.mounted) toast(context, 'Thanks for your feedback!');
          }
        }),
      if (b.status == BookingStatus.completed || b.status == BookingStatus.cancelled)
        SmallBtn('Book again', onTap: () {
          final isTable = b.bookingFor.startsWith('Table: ');
          pushRoot(
            context,
            isTable
                ? ReserveTableScreen(activity: b.bookingFor.substring(7))
                : PartyBookingScreen(eventType: b.bookingFor),
          );
        }),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const LogoTile(size: 62),
        const SizedBox(width: 18),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            KV('Order No', b.orderNo, keyWidth: 82, boldValue: true),
            KV('Date & Time', stamp(b.dateTime), keyWidth: 82),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                SizedBox(width: 82, child: Text('Status', style: p(12.5))),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(':', style: p(12.5))),
                Text(b.status.label,
                    style: p(12.5,
                        w: FontWeight.w500,
                        c: switch (b.status) {
                          BookingStatus.cancelled => Colors.red.shade700,
                          BookingStatus.pending => Z.orange,
                          BookingStatus.accepted => Z.teal,
                          BookingStatus.completed => Z.text,
                        })),
              ]),
            ),
            KV('Booking for', b.bookingFor, keyWidth: 82),
            if (buttons.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 12, runSpacing: 8, children: buttons),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _Empty extends StatelessWidget {
  final VoidCallback onBook;
  const _Empty({required this.onBook});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.edit_calendar_outlined, size: 54, color: Z.teal),
            const SizedBox(height: 12),
            Text('No bookings yet', style: p(16, w: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Reserve a table or book a party and it will show up here.', textAlign: TextAlign.center, style: p(13, c: Z.sub)),
            const SizedBox(height: 18),
            SizedBox(width: 200, child: ZButton('Reserve a Table', onPressed: onBook)),
          ]),
        ),
      );
}
