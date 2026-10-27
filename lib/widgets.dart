import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data.dart';
import 'state.dart';
import 'theme.dart';

/// Scaffold key of the main shell, so any screen's menu icon can open the drawer.
final shellScaffoldKey = GlobalKey<ScaffoldState>();

/// Push above the bottom navigation (full-screen flows: forms, cart, checkout).
Future<T?> pushRoot<T>(BuildContext context, Widget page) =>
    Navigator.of(context, rootNavigator: true).push<T>(MaterialPageRoute(builder: (_) => page));

/// Push inside the current tab (keeps the bottom navigation visible).
Future<T?> pushTab<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

void toast(BuildContext context, String msg) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(msg)));

Future<void> openUrl(BuildContext context, String url) async {
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok && context.mounted) toast(context, 'Couldn’t open $url');
}

// ─── App bar ─────────────────────────────────────────────────────────────

class ZAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool close;
  final PreferredSizeWidget? bottom;
  const ZAppBar(this.title, {super.key, this.actions, this.close = false, this.bottom});

  @override
  Size get preferredSize => Size.fromHeight(64 + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      leading: canPop
          ? IconButton(
              tooltip: close ? 'Close' : 'Back',
              icon: Icon(close ? Icons.close : Icons.arrow_back_ios_new, size: close ? 24 : 18),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu, size: 28),
              onPressed: () => shellScaffoldKey.currentState?.openDrawer(),
            ),
      title: Text(title),
      actions: actions,
      bottom: bottom,
    );
  }
}

class CartButton extends StatelessWidget {
  final VoidCallback onTap;
  const CartButton({super.key, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final n = AppScope.of(context).cartCount;
    return IconButton(
      tooltip: 'Cart',
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: n > 0,
        label: Text('$n'),
        backgroundColor: Z.orange,
        child: const Icon(Icons.shopping_cart_outlined, size: 28),
      ),
    );
  }
}

// ─── Buttons ─────────────────────────────────────────────────────────────

class ZButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final double height;
  final double fontSize;
  const ZButton(this.label, {super.key, required this.onPressed, this.outlined = false, this.height = 46, this.fontSize = 15});

  @override
  Widget build(BuildContext context) {
    final style = p(fontSize, w: FontWeight.w600, c: outlined ? Z.orange : Colors.white);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Z.orange, width: 1.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(label.toUpperCase(), style: style),
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: Z.orange,
                disabledBackgroundColor: Z.greyBtn,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(label.toUpperCase(), style: style),
            ),
    );
  }
}

/// Compact buttons used on cards ("Add", "Cancel", "Track Order"…).
class SmallBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final double width;
  final bool pill;
  const SmallBtn(this.label, {super.key, this.onTap, this.outlined = false, this.width = 100, this.pill = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? Colors.white : Z.orange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(pill ? 20 : 4),
        side: outlined ? const BorderSide(color: Z.orange) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(pill ? 20 : 4),
        child: Container(
          width: width,
          height: pill ? 26 : 32,
          alignment: Alignment.center,
          child: Text(label, style: p(pill ? 11 : 12.5, w: FontWeight.w500, c: outlined ? Z.orange : Colors.white)),
        ),
      ),
    );
  }
}

/// Segment toggle used for List/Calendar view and Pottery/Glass fusion.
class ToggleChips extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  const ToggleChips({super.key, required this.labels, required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: i == selected ? Z.orange : Z.greyBtn,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  onTap: () => onChanged(i),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    child: Text(labels[i].toUpperCase(), style: p(11.5, c: Colors.white)),
                  ),
                ),
              ),
            ),
        ],
      );
}

// ─── Form fields ─────────────────────────────────────────────────────────

class FormLabel extends StatelessWidget {
  final String text;
  final double top;
  const FormLabel(this.text, {super.key, this.top = 16});
  @override
  Widget build(BuildContext context) =>
      Padding(padding: EdgeInsets.fromLTRB(4, top, 0, 8), child: Text(text, style: p(13.5)));
}

class SectionHeading extends StatelessWidget {
  final String text;
  final double top;
  const SectionHeading(this.text, {super.key, this.top = 20});
  @override
  Widget build(BuildContext context) =>
      Padding(padding: EdgeInsets.only(top: top, bottom: 2), child: Text(text, style: p(16, w: FontWeight.w500)));
}

String? requiredV(String? v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null;
String? emailV(String? v) =>
    (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) ? 'Enter a valid email address' : null;
String? phoneV(String? v) => (v == null || v.replaceAll(RegExp(r'\D'), '').length < 7) ? 'Enter a valid phone number' : null;

class ZField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;
  final bool obscure;
  final int maxLines;
  final Widget? suffix;
  final String? initial;
  final ValueChanged<String>? onChanged;
  const ZField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboard,
    this.obscure = false,
    this.maxLines = 1,
    this.suffix,
    this.initial,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) FormLabel(label),
          TextFormField(
            controller: controller,
            initialValue: controller == null ? initial : null,
            validator: validator,
            keyboardType: keyboard,
            obscureText: obscure,
            maxLines: obscure ? 1 : maxLines,
            onChanged: onChanged,
            style: p(14),
            decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
          ),
        ],
      );
}

class PasswordField extends StatefulWidget {
  final String label, hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool showToggle;
  const PasswordField(
      {super.key, required this.label, required this.hint, required this.controller, this.validator, this.showToggle = true});
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hide = true;
  @override
  Widget build(BuildContext context) => ZField(
        label: widget.label,
        hint: widget.hint,
        controller: widget.controller,
        obscure: _hide,
        validator: widget.validator ?? (v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null,
        suffix: widget.showToggle
            ? IconButton(
                tooltip: _hide ? 'Show password' : 'Hide password',
                icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Z.text, size: 20),
                onPressed: () => setState(() => _hide = !_hide),
              )
            : null,
      );
}

class ZDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  const ZDropdown({super.key, required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) FormLabel(label),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: Z.text),
            style: p(14),
            items: [for (final i in items) DropdownMenuItem(value: i, child: Text(i, overflow: TextOverflow.ellipsis))],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      );
}

/// Read-only field that opens the date picker.
class DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;
  final DateTime? first;
  const DateField({super.key, required this.label, required this.value, required this.onPicked, this.first});

  @override
  Widget build(BuildContext context) => _PickerBox(
        label: label,
        text: value == null ? 'Select Date' : DateFormat('EEE, dd MMM yyyy').format(value!),
        icon: Icons.calendar_today_outlined,
        empty: value == null,
        onTap: () async {
          final start = first ?? DateTime.now();
          final firstDay = DateTime(start.year, start.month, start.day);
          final d = await showDatePicker(
            context: context,
            initialDate: (value != null && !value!.isBefore(firstDay)) ? value! : firstDay,
            firstDate: firstDay,
            lastDate: DateTime(start.year + 2),
          );
          if (d != null) onPicked(d);
        },
      );
}

class TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final ValueChanged<TimeOfDay> onPicked;
  const TimeField({super.key, required this.label, required this.value, required this.onPicked});

  @override
  Widget build(BuildContext context) => _PickerBox(
        label: label,
        text: value == null ? 'Select Time' : value!.format(context),
        icon: Icons.access_time,
        empty: value == null,
        onTap: () async {
          final t = await showTimePicker(context: context, initialTime: value ?? const TimeOfDay(hour: 12, minute: 0));
          if (t != null) onPicked(t);
        },
      );
}

class _PickerBox extends StatelessWidget {
  final String label, text;
  final IconData icon;
  final bool empty;
  final VoidCallback onTap;
  const _PickerBox({required this.label, required this.text, required this.icon, required this.empty, required this.onTap});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormLabel(label),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: InputDecorator(
              decoration: InputDecoration(suffixIcon: Icon(icon, color: Z.text, size: 20)),
              child: Text(text, style: p(14, c: empty ? const Color(0xFF9A9A9A) : Z.text)),
            ),
          ),
        ],
      );
}

class CheckLine extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;
  const CheckLine({super.key, required this.value, required this.onChanged, required this.label});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(value: value, onChanged: (v) => onChanged(v ?? false), visualDensity: VisualDensity.compact),
            ),
            const SizedBox(width: 8),
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 2), child: label)),
          ]),
        ),
      );
}

// ─── Content helpers ─────────────────────────────────────────────────────

class Bullets extends StatelessWidget {
  final List<String> items;
  final double size;
  final FontWeight weight;
  final double gap;
  const Bullets(this.items, {super.key, this.size = 13, this.weight = FontWeight.w400, this.gap = 4});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final t in items)
            Padding(
              padding: EdgeInsets.only(bottom: gap),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(padding: const EdgeInsets.fromLTRB(6, 0, 8, 0), child: Text('•', style: p(size, h: 1.5))),
                Expanded(child: Text(t, style: p(size, w: weight, h: 1.5, c: const Color(0xFF333333)))),
              ]),
            ),
        ],
      );
}

/// "Label   :   value" rows used on bookings, orders and receipts.
class KV extends StatelessWidget {
  final String k, v;
  final double keyWidth;
  final bool boldValue;
  final TextAlign valueAlign;
  const KV(this.k, this.v, {super.key, this.keyWidth = 90, this.boldValue = false, this.valueAlign = TextAlign.left});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: keyWidth, child: Text(k, style: p(12.5, w: boldValue ? FontWeight.w600 : FontWeight.w400))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(':', style: p(12.5))),
          Expanded(
              child: Text(v,
                  textAlign: valueAlign,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: p(12.5, w: boldValue ? FontWeight.w600 : FontWeight.w400))),
        ]),
      );
}

/// Black tile with the ZANY logo (booking and order cards).
class LogoTile extends StatelessWidget {
  final double size;
  const LogoTile({super.key, this.size = 64});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(4)),
        child: Image.asset(logoAsset, fit: BoxFit.contain),
      );
}

class ThickDivider extends StatelessWidget {
  const ThickDivider({super.key});
  @override
  Widget build(BuildContext context) => Container(height: 8, color: Z.divider);
}

class GalleryGrid extends StatelessWidget {
  final List<String> images;
  const GalleryGrid(this.images, {super.key});
  @override
  Widget build(BuildContext context) => GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          for (final i in images)
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => Dialog(
                  insetPadding: const EdgeInsets.all(16),
                  clipBehavior: Clip.antiAlias,
                  child: InteractiveViewer(child: Image.asset(i, fit: BoxFit.contain)),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Z.border), borderRadius: BorderRadius.circular(6)),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(i, fit: BoxFit.cover),
              ),
            ),
        ],
      );
}

class CircleCategory extends StatelessWidget {
  final String label, image;
  final bool selected;
  final VoidCallback onTap;
  final double size;
  const CircleCategory(
      {super.key, required this.label, required this.image, required this.onTap, this.selected = false, this.size = 44});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: size + 24,
          child: Column(children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? Z.orange : Colors.black54, width: selected ? 2 : 1),
                image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: p(9.5, c: selected ? Z.orange : Z.text)),
          ]),
        ),
      );
}

class QtyButtons extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final double size;
  const QtyButtons({super.key, required this.value, required this.onChanged, this.min = 1, this.size = 26});
  @override
  Widget build(BuildContext context) {
    Widget b(String t, VoidCallback? f, String sem) => Semantics(
          button: true,
          label: sem,
          child: InkWell(
            onTap: f,
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: f == null ? Z.greyBtn : Z.orange, borderRadius: BorderRadius.circular(3)),
              child: Text(t, style: p(size * 0.55, w: FontWeight.w600, c: Colors.white, h: 1)),
            ),
          ),
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      b('+', () => onChanged(value + 1), 'Increase quantity'),
      SizedBox(width: size * 1.3, child: Text('$value', textAlign: TextAlign.center, style: p(size * 0.5))),
      b('-', value > min ? () => onChanged(value - 1) : null, 'Decrease quantity'),
    ]);
  }
}

/// 5-star feedback dialog (Figma: "GIVE ME YOUR FEEDBACK").
Future<int?> showFeedbackDialog(BuildContext context, {int initial = 0}) {
  return showDialog<int>(
    context: context,
    builder: (ctx) {
      var stars = initial;
      final note = TextEditingController();
      return StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('GIVE ME YOUR FEEDBACK', textAlign: TextAlign.center, style: p(16, w: FontWeight.w600)),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    tooltip: '$i star${i > 1 ? 's' : ''}',
                    onPressed: () => setS(() => stars = i),
                    icon: Icon(i <= stars ? Icons.star_rounded : Icons.star_outline_rounded, color: Z.star, size: 38),
                  ),
              ]),
              const SizedBox(height: 8),
              Text('Add Feedback', style: p(13.5)),
              const SizedBox(height: 8),
              TextField(controller: note, maxLines: 3, style: p(14), decoration: const InputDecoration(hintText: 'Add text here')),
              const SizedBox(height: 20),
              ZButton('Submit', onPressed: stars == 0 ? null : () => Navigator.pop(ctx, stars)),
            ]),
          ),
        ),
      );
    },
  );
}

Future<bool> confirm(BuildContext context, String title, String body, {String yes = 'Yes', String no = 'No'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text(title, style: p(17, w: FontWeight.w600)),
      content: Text(body, style: p(13.5)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d, false), child: Text(no, style: p(14, c: Z.sub))),
        TextButton(onPressed: () => Navigator.pop(d, true), child: Text(yes, style: p(14, w: FontWeight.w600, c: Z.orange))),
      ],
    ),
  );
  return r ?? false;
}
