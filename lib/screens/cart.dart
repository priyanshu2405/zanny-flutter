import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'shell.dart';
import 'shop.dart';

Widget _step(String n, String title) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Step $n', style: p(13.5, w: FontWeight.w500, c: Z.orange)),
        const SizedBox(height: 14),
        Text(title, style: p(16, w: FontWeight.w600)),
      ]),
    );

Widget _thumb(String image, [double size = 58]) => Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(border: Border.all(color: Z.border), borderRadius: BorderRadius.circular(3)),
      child: Image.asset(image, fit: BoxFit.contain),
    );

Widget _row(String k, String v, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(child: Text(k, style: p(12, w: bold ? FontWeight.w600 : FontWeight.w400))),
        Text(v, style: p(12, w: bold ? FontWeight.w600 : FontWeight.w400)),
      ]),
    );

// ─── Figma p25 — My Cart ─────────────────────────────────────────────────

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final short = AppState.freeShippingOver - s.subtotal;
    return Scaffold(
      appBar: ZAppBar('My Cart', close: true, actions: [
        if (s.cart.isNotEmpty)
          TextButton(
            onPressed: () async {
              if (await confirm(context, 'Clear cart?', 'Remove all items from your cart?', yes: 'Clear', no: 'Cancel')) s.clearCart();
            },
            child: Text('Clear Cart', style: p(13, c: Colors.white)),
          ),
      ]),
      body: s.cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.shopping_cart_outlined, size: 56, color: Z.teal),
                  const SizedBox(height: 12),
                  Text('Your cart is empty', style: p(16, w: FontWeight.w600)),
                  const SizedBox(height: 18),
                  SizedBox(width: 200, child: ZButton('Add Items', onPressed: () => _shop(context))),
                ]),
              ),
            )
          : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
              for (final l in s.cart) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _thumb(l.product.image),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l.product.name, style: p(13, w: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('${l.qty} X ${money(l.product.price)}', style: p(11)),
                        const SizedBox(height: 6),
                        QtyButtons(value: l.qty, min: 0, size: 18, onChanged: (v) => s.setQty(l.product, v)),
                      ]),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () => s.setQty(l.product, 0),
                      icon: const Icon(Icons.delete_outline, size: 20, color: Z.sub),
                    ),
                  ]),
                ),
                const Divider(),
              ],
              const SizedBox(height: 60),
              _row('Subtotal', money(s.subtotal), bold: true),
              const SizedBox(height: 16),
              if (short > 0)
                Text('Top up your order by ${money(short)} to qualify for free shipping!', style: p(11.5))
              else
                Text('Your order qualifies for free Delivery!', style: p(11.5, c: Z.teal)),
              const SizedBox(height: 18),
              ZButton('Add Items', onPressed: () => _shop(context)),
              const SizedBox(height: 12),
              ZButton('Proceed to Checkout', outlined: true, onPressed: () => pushRoot(context, const OrderSummaryScreen())),
            ]),
    );
  }

  static void _shop(BuildContext context) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    ShellController.go(0, root: const ShopHomeScreen());
  }
}

// ─── Figma p26 — Order details (summary, coupon, gift) ───────────────────

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});
  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final _code = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: const ZAppBar('Order details'),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 24), children: [
        for (final l in s.cart)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              _thumb(l.product.image),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.product.name, style: p(13, w: FontWeight.w500)),
                  Text('${l.qty} X ${money(l.product.price)}', style: p(11)),
                ]),
              ),
              Text(money(l.total), style: p(12, w: FontWeight.w500)),
            ]),
          ),
        const Divider(),
        const SizedBox(height: 18),
        _row('${s.cartCount} items', money(s.subtotal)),
        const SizedBox(height: 8),
        Text('Enter your coupon code if you have one.', style: p(10.5)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              style: p(12),
              decoration: InputDecoration(
                hintText: 'Enter your coupon code',
                hintStyle: p(11, c: const Color(0xFF9A9A9A)),
                helperText: s.coupon != null ? '${s.coupon} applied: 10% off' : 'Try ${AppState.couponCode}',
                helperStyle: p(10.5, c: s.coupon != null ? Z.teal : Z.sub),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SmallBtn('APPLY COUPON', width: 110, onTap: () {
              FocusScope.of(context).unfocus();
              final ok = s.applyCoupon(_code.text);
              toast(context, ok ? 'Coupon applied. You saved ${money(s.discount)}.' : 'That coupon code isn’t valid.');
            }),
          ),
        ]),
        const SizedBox(height: 10),
        CheckLine(
          value: s.giftWrap,
          onChanged: (v) => s.setGift(v),
          label: Text('Gift this product For special occasion (+${money(AppState.giftFee)})', style: p(12)),
        ),
        if (s.giftWrap) ZDropdown(label: 'Choose Occasion', value: s.giftOccasion, items: giftOccasions, onChanged: (v) => s.setGift(true, v)),
        const SizedBox(height: 22),
        const Divider(),
        const SizedBox(height: 10),
        _row('Subtotal', money(s.subtotal)),
        _row('Gift products', money(s.gift)),
        _row('Delivery Charge', s.delivery == 0 ? 'Free' : money(s.delivery)),
        if (s.discount > 0) _row('Discount (${s.coupon})', '- ${money(s.discount)}'),
        _row('Total', money(s.total), bold: true),
        const SizedBox(height: 26),
        ZButton('Continue', onPressed: s.cart.isEmpty ? null : () => pushRoot(context, const CheckoutScreen())),
      ]),
    );
  }
}

// ─── Figma p27 — Checkout (billing) + p28 payment method sheet ───────────

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _form = GlobalKey<FormState>();
  late final AppState _s = AppScope.read(context);
  late final _name = TextEditingController(text: _s.name);
  final _address = TextEditingController();
  final _street = TextEditingController();
  final _apt = TextEditingController();
  final _city = TextEditingController();
  String _country = 'Canada';
  final _state = TextEditingController();
  final _zip = TextEditingController();
  late final _email = TextEditingController(text: _s.email);
  late final _phone = TextEditingController(text: _s.phone);
  final _notes = TextEditingController();
  bool _save = true;

  Future<void> _continue() async {
    if (!_form.currentState!.validate()) return;
    final address = Address(
      _name.text.trim(),
      [_address.text, _street.text, _apt.text, '${_city.text}, ${_state.text} ${_zip.text}', _country]
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e != ',')
          .join(', '),
      _email.text.trim(),
      _phone.text.trim(),
    );
    final pay = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Payment Method', style: p(20, w: FontWeight.w600)),
            const SizedBox(height: 22),
            _row('Total amount', money(_s.total)),
            const SizedBox(height: 24),
            ZButton('Pay with Card', onPressed: () => Navigator.pop(ctx, true)),
          ]),
        ),
      ),
    );
    if (pay == true && mounted) pushRoot(context, PaymentScreen(address: address));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const ZAppBar('Checkout'),
        body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.fromLTRB(12, 0, 12, 24), children: [
            _step('1', 'Billing Details'),
            ZField(label: 'Full Name', controller: _name, validator: requiredV),
            ZField(label: 'Address', controller: _address, validator: requiredV),
            ZField(label: 'Street Address', hint: 'Select a Street ...', controller: _street),
            ZField(label: 'Apartment, suite, unit etc. (Optional)', controller: _apt),
            ZField(label: 'City', controller: _city, validator: requiredV),
            ZDropdown(label: 'Country', value: _country, items: const ['Canada', 'United States'], onChanged: (v) => setState(() => _country = v)),
            ZField(label: _country == 'Canada' ? 'Province' : 'State', controller: _state, validator: requiredV),
            ZField(label: 'Postcode / ZIP', controller: _zip, validator: requiredV),
            ZField(label: 'Email address', controller: _email, keyboard: TextInputType.emailAddress, validator: emailV),
            ZField(label: 'Phone', controller: _phone, keyboard: TextInputType.phone, validator: phoneV),
            const SizedBox(height: 10),
            CheckLine(value: _save, onChanged: (v) => setState(() => _save = v), label: Text('Save my information for a faster checkout', style: p(13))),
            ZField(label: 'Additional information', hint: 'Order notes (Optional)', controller: _notes, maxLines: 3),
            const SizedBox(height: 22),
            ZButton('Save and Continue', onPressed: _continue),
          ]),
        ),
      );
}

// ─── Figma p29 — Payment Details ─────────────────────────────────────────

class PaymentScreen extends StatefulWidget {
  final Address address;
  const PaymentScreen({super.key, required this.address});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _form = GlobalKey<FormState>();
  bool _saved = true;
  bool _remember = false;
  bool _busy = false;
  final _cardName = TextEditingController();
  final _cardNo = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();

  Future<void> _pay() async {
    if (!_saved && !_form.currentState!.validate()) return;
    setState(() => _busy = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    final s = AppScope.read(context);
    final order = s.placeOrder(address: widget.address, paymentType: 'Credit Card');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
      (r) => r.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: const ZAppBar('Payment Details'),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.fromLTRB(12, 0, 12, 24), children: [
          _step('2', 'Payment'),
          _row('Amount to Pay', money(s.total)),
          const SizedBox(height: 10),
          Text('Saved Cards', style: p(12.5, w: FontWeight.w500)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => setState(() => _saved = !_saved),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(border: Border.all(color: Z.border), borderRadius: BorderRadius.circular(6)),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFE8EEF9), borderRadius: BorderRadius.circular(2)),
                  child: Text('VISA', style: p(10, w: FontWeight.w700, c: const Color(0xFF1A1F71))),
                ),
                const SizedBox(width: 22),
                Expanded(child: Text('****   ****   ****   2233', style: p(12.5))),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(value: _saved, onChanged: (v) => setState(() => _saved = v ?? false)),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text('Add Card Details', style: p(12.5, w: FontWeight.w500)),
          AbsorbPointer(
            absorbing: _saved,
            child: Opacity(
              opacity: _saved ? 0.45 : 1,
              child: Column(children: [
                ZField(label: '', hint: 'Name on Card', controller: _cardName, validator: requiredV),
                const SizedBox(height: 12),
                ZField(
                  label: '',
                  hint: 'Card Number',
                  controller: _cardNo,
                  keyboard: TextInputType.number,
                  validator: (v) => (v == null || v.replaceAll(' ', '').length < 12) ? 'Enter a valid card number' : null,
                ),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: ZField(
                      label: '',
                      hint: 'Card Expiry (MM/YY)',
                      controller: _expiry,
                      keyboard: TextInputType.datetime,
                      validator: (v) => RegExp(r'^\d{2}/\d{2}$').hasMatch(v ?? '') ? null : 'Use MM/YY',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ZField(
                      label: '',
                      hint: 'C V V',
                      controller: _cvv,
                      keyboard: TextInputType.number,
                      obscure: true,
                      validator: (v) => (v == null || v.length < 3) ? 'Enter CVV' : null,
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                CheckLine(
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v),
                  label: Text('Securely Save my Card For Future Use.', style: p(12.5)),
                ),
              ]),
            ),
          ),
          if (_saved) Text('Paying with saved Visa ending 2233. Untick it to use a new card.', style: p(11, c: Z.sub)),
          const SizedBox(height: 40),
          _busy
              ? const Center(child: CircularProgressIndicator(color: Z.orange))
              : ZButton('Pay Now', onPressed: _pay),
          const SizedBox(height: 12),
          Text('Prototype: no real payment is taken.', textAlign: TextAlign.center, style: p(11, c: Z.sub)),
        ]),
      ),
    );
  }
}

// ─── Figma p30 — Successful ──────────────────────────────────────────────

class OrderSuccessScreen extends StatelessWidget {
  final Order order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final name = AppScope.read(context).name;
    void goShop() {
      Navigator.of(context).popUntil((r) => r.isFirst);
      ShellController.go(0, root: const ShopHomeScreen());
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goShop();
      },
      child: Scaffold(
        appBar: const ZAppBar('Successful'),
        body: ListView(padding: const EdgeInsets.fromLTRB(12, 0, 12, 24), children: [
          _step('3', 'Confirmation'),
          const SizedBox(height: 40),
          const Center(
            child: CircleAvatar(radius: 34, backgroundColor: Color(0xFFFDE3D8), child: Icon(Icons.receipt_long, color: Z.orange, size: 34)),
          ),
          const SizedBox(height: 18),
          Text('Your Order Has Been Placed', textAlign: TextAlign.center, style: p(13, w: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Congrats $name! Your ${money(order.total)} order with Zany is confirmed. Details sent to your email and mobile.',
              textAlign: TextAlign.center, style: p(10.5, c: Z.sub)),
          const SizedBox(height: 50),
          KV('Amount', money(order.total), keyWidth: 120, valueAlign: TextAlign.right),
          KV('Order ID', order.orderNo, keyWidth: 120, valueAlign: TextAlign.right),
          KV('Payment Type', order.paymentType, keyWidth: 120, valueAlign: TextAlign.right),
          KV('Transaction Time', stamp(order.placedOn), keyWidth: 120, valueAlign: TextAlign.right),
          const SizedBox(height: 50),
          ZButton('Continue Shopping', onPressed: goShop),
          const SizedBox(height: 12),
          ZButton('View My Orders', outlined: true, onPressed: () {
            Navigator.of(context).popUntil((r) => r.isFirst);
            ShellController.go(2);
          }),
        ]),
      ),
    );
  }
}
