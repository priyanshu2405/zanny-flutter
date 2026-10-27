import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'reserve.dart';

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Figma p15 (list) and p16 (calendar) — Studio Events.
class StudioEventsScreen extends StatefulWidget {
  const StudioEventsScreen({super.key});
  @override
  State<StudioEventsScreen> createState() => _StudioEventsScreenState();
}

class _StudioEventsScreenState extends State<StudioEventsScreen> {
  int _view = 0;
  late DateTime _month = DateTime(events.first.start.year, events.first.start.month);
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final monthEvents = events.where((e) => e.start.year == _month.year && e.start.month == _month.month).toList();
    final shown = _view == 0
        ? events
        : _selected == null
            ? monthEvents
            : monthEvents.where((e) => _sameDay(e.start, _selected!)).toList();
    return Scaffold(
      appBar: const ZAppBar('Studio Events'),
      body: ListView(padding: EdgeInsets.zero, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 16, 12),
          child: ToggleChips(labels: const ['List View', 'Calendar View'], selected: _view, onChanged: (i) => setState(() => _view = i)),
        ),
        if (_view == 1) ...[
          _calendar(monthEvents),
          const SizedBox(height: 16),
          const ThickDivider(),
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.all(28),
              child: Text(_selected == null ? 'No events this month.' : 'No events on this day. Tap a highlighted date.',
                  textAlign: TextAlign.center, style: p(13, c: Z.sub)),
            ),
        ],
        for (final e in shown) ...[
          _EventRow(event: e),
          const ThickDivider(),
        ],
      ]),
    );
  }

  Widget _calendar(List<StudioEvent> monthEvents) {
    final first = DateTime(_month.year, _month.month, 1);
    final lead = first.weekday % 7; // Sunday first
    final gridStart = first.subtract(Duration(days: lead));
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final rows = ((lead + days) / 7).ceil();
    final today = DateTime.now();
    const border = BorderSide(color: Color(0xFFD9D9D9));

    Widget cell(Widget child, {Color? bg, VoidCallback? onTap}) => Expanded(
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: 44,
              decoration: BoxDecoration(color: bg, border: const Border(right: border, bottom: border)),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(children: [
        Row(children: [
          IconButton(
            tooltip: 'Previous month',
            onPressed: () => setState(() {
              _month = DateTime(_month.year, _month.month - 1);
              _selected = null;
            }),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(child: Text(DateFormat('MMMM yyyy').format(_month), textAlign: TextAlign.center, style: p(14, w: FontWeight.w600))),
          IconButton(
            tooltip: 'Next month',
            onPressed: () => setState(() {
              _month = DateTime(_month.year, _month.month + 1);
              _selected = null;
            }),
            icon: const Icon(Icons.chevron_right),
          ),
        ]),
        Container(
          decoration: const BoxDecoration(border: Border(top: border, left: border)),
          child: Column(children: [
            Row(children: [for (final d in const ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']) cell(Text(d, style: p(12.5)))]),
            for (var r = 0; r < rows; r++)
              Row(children: [
                for (var c = 0; c < 7; c++)
                  () {
                    final day = gridStart.add(Duration(days: r * 7 + c));
                    final inMonth = day.month == _month.month;
                    final hasEvent = inMonth && monthEvents.any((e) => _sameDay(e.start, day));
                    final sel = _selected != null && _sameDay(_selected!, day);
                    final isToday = _sameDay(day, today);
                    Widget label = Text('${day.day}', style: p(13, c: sel ? Colors.white : (inMonth ? Z.text : Z.greyBtn)));
                    if (isToday && !sel) {
                      label = Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Z.orange)),
                        child: Text('${day.day}', style: p(13, c: Z.orange)),
                      );
                    }
                    return cell(
                      label,
                      bg: sel ? Z.orange : (hasEvent ? Z.orangeSoft : null),
                      onTap: inMonth ? () => setState(() => _selected = sel ? null : day) : null,
                    );
                  }(),
              ]),
          ]),
        ),
      ]),
    );
  }
}

class _EventRow extends StatelessWidget {
  final StudioEvent event;
  const _EventRow({required this.event});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => pushTab(context, EventDetailsScreen(event: event)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          child: Row(children: [
            Container(
              width: 78,
              height: 78,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFD0D0D0))),
              child: Image.asset(event.image, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: p(11.5, w: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(event.dateLabel, style: p(10.5)),
                const SizedBox(height: 4),
                Text(event.timeLabel, style: p(10.5)),
                const SizedBox(height: 4),
                Text('More Info', style: p(12, w: FontWeight.w500, c: Z.orange, d: TextDecoration.underline)),
              ]),
            ),
          ]),
        ),
      );
}

/// Figma p17 — Event Details.
class EventDetailsScreen extends StatelessWidget {
  final StudioEvent event;
  const EventDetailsScreen({super.key, required this.event});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const ZAppBar('Event Details'),
        body: ListView(padding: const EdgeInsets.fromLTRB(14, 14, 14, 24), children: [
          Container(
            height: 152,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFD0D0D0))),
            child: Image.asset(event.image, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(event.title, style: p(14, w: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(event.dateLabel, style: p(10.5, w: FontWeight.w500)),
              const SizedBox(height: 6),
              Text(event.timeLabel, style: p(10.5, w: FontWeight.w500)),
              if (event.price != null) ...[
                const SizedBox(height: 6),
                Text(event.price!, style: p(12, w: FontWeight.w600, c: Z.orange)),
              ],
              const SizedBox(height: 12),
              Text(event.description, style: p(12, h: 1.9, c: const Color(0xFF333333))),
            ]),
          ),
          const SizedBox(height: 16),
          if (event.end.isBefore(DateTime.now())) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Z.grey, borderRadius: BorderRadius.circular(6)),
              child: Text('This event has ended. Reserve a table to visit the studio any day.', style: p(12.5)),
            ),
            ZButton('Reserve a Table', height: 50, fontSize: 18, onPressed: () => pushRoot(context, const ReserveTableScreen())),
          ] else
            ZButton('Book Now', height: 50, fontSize: 18, onPressed: () {
              pushRoot(context, ReserveTableScreen(date: event.start, note: 'Booking for: ${event.title}'));
            }),
        ]),
      );
}
