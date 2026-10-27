import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'cart.dart';
import 'shell.dart';
import 'shop.dart';

/// Figma p31 — My Orders.
class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      appBar: ZAppBar('My Orders', actions: [CartButton(onTap: () => pushRoot(context, const CartScreen()))]),
      body: s.orders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.shopping_bag_outlined, size: 54, color: Z.teal),
                  const SizedBox(height: 12),
                  Text('No orders yet', style: p(16, w: FontWeight.w600)),
                  const SizedBox(height: 18),
                  SizedBox(width: 200, child: ZButton('Shop Now', onPressed: () => ShellController.go(0, root: const ShopHomeScreen()))),
                ]),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(top: 6, bottom: 20),
              itemCount: s.orders.length,
              separatorBuilder: (_, __) => const ThickDivider(),
              itemBuilder: (_, i) => _OrderCard(order: s.orders[i]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.read(context);
    final o = order;
    final active = o.status == OrderStatus.placed || o.status == OrderStatus.onTheWay;
    return InkWell(
      onTap: () => pushTab(context, OrderDetailScreen(order: o)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const LogoTile(size: 62),
          const SizedBox(width: 18),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              KV('Order No', o.orderNo, keyWidth: 82, boldValue: true),
              KV('Date & Time', stamp(o.placedOn), keyWidth: 82),
              KV('Status', o.status.label, keyWidth: 82),
              KV('Products', o.productNames, keyWidth: 82),
              const SizedBox(height: 10),
              Wrap(spacing: 12, runSpacing: 8, children: [
                if (active) ...[
                  SmallBtn('Cancel', outlined: true, onTap: () async {
                    final ok = await confirm(context, 'Cancel order ${o.orderNo}?', 'Your payment will be refunded to the original card.',
                        yes: 'Cancel order', no: 'Keep');
                    if (ok) s.cancelOrder(o);
                  }),
                  SmallBtn('Track Order', onTap: () => pushTab(context, TrackOrderScreen(order: o))),
                ] else ...[
                  if (o.status == OrderStatus.delivered)
                    SmallBtn(o.rating == null ? 'Give Rating' : 'Rated ${o.rating}★', outlined: true, onTap: () async {
                      final r = await showFeedbackDialog(context, initial: o.rating ?? 0);
                      if (r != null) {
                        s.rateOrder(o, r);
                        if (context.mounted) toast(context, 'Thanks for your feedback!');
                      }
                    }),
                  SmallBtn('Repeat order', onTap: () {
                    s.repeatOrder(o);
                    pushRoot(context, const CartScreen());
                  }),
                ],
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Figma p32 — order detail (titled "Payment Details" in the design).
class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    AppScope.of(context); // rebuild on status changes
    final o = order;
    return Scaffold(
      appBar: const ZAppBar('Order Details'),
      body: ListView(padding: const EdgeInsets.fromLTRB(22, 16, 22, 28), children: [
        KV('Order No', o.orderNo, keyWidth: 130, boldValue: true),
        KV('Customer Name', o.address.name, keyWidth: 130),
        KV('Placed On', stamp(o.placedOn), keyWidth: 130),
        KV('Delivery date and time', stamp(o.deliveryOn), keyWidth: 130),
        KV('Order Amount', money(o.total), keyWidth: 130),
        KV('Order status', o.status.label, keyWidth: 130),
        const SizedBox(height: 14),
        const Divider(),
        const SectionHeading('Recipient Address'),
        const SizedBox(height: 6),
        Text('${o.address.name}\n${o.address.lines}\n${o.address.email}\n${o.address.phone}', style: p(12, h: 1.6)),
        const SizedBox(height: 14),
        const Divider(),
        const SectionHeading('Order Details'),
        for (final l in o.lines)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(border: Border.all(color: Z.border), borderRadius: BorderRadius.circular(3)),
                child: Image.asset(l.product.image, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.product.name, style: p(12)),
                  Text(money(l.product.price), style: p(12, w: FontWeight.w600)),
                  Text('X ${l.qty}', style: p(11.5)),
                ]),
              ),
            ]),
          ),
        const SizedBox(height: 16),
        const Divider(),
        const SectionHeading('Payment Details'),
        const SizedBox(height: 6),
        KV('Payment Type', o.paymentType, keyWidth: 130, valueAlign: TextAlign.right),
        KV('Subtotal', money(o.subtotal), keyWidth: 130, valueAlign: TextAlign.right),
        KV('Delivery Charges', money(o.delivery), keyWidth: 130, valueAlign: TextAlign.right),
        if (o.gift > 0) KV('Gift products', money(o.gift), keyWidth: 130, valueAlign: TextAlign.right),
        KV('Discount', money(o.discount), keyWidth: 130, valueAlign: TextAlign.right),
        KV('Total amount', money(o.total), keyWidth: 130, valueAlign: TextAlign.right, boldValue: true),
        if (o.status == OrderStatus.onTheWay || o.status == OrderStatus.placed) ...[
          const SizedBox(height: 24),
          ZButton('Track Order', onPressed: () => pushTab(context, TrackOrderScreen(order: o))),
        ],
      ]),
    );
  }
}

/// Track Order (button on My Orders; layout follows the web tracker).
class TrackOrderScreen extends StatelessWidget {
  final Order order;
  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final o = order;
    final steps = [
      ('Order placed', o.placedOn),
      ('Packed at the studio', o.placedOn.add(const Duration(days: 1))),
      ('On the way', o.placedOn.add(const Duration(days: 2))),
      ('Delivered', o.deliveryOn),
    ];
    final reached = switch (o.status) {
      OrderStatus.placed => 0,
      OrderStatus.onTheWay => 2,
      OrderStatus.delivered => 3,
      OrderStatus.cancelled => -1,
    };
    return Scaffold(
      appBar: const ZAppBar('Track Order'),
      body: ListView(padding: const EdgeInsets.fromLTRB(22, 20, 22, 24), children: [
        KV('Order No', o.orderNo, keyWidth: 100, boldValue: true),
        KV('Products', o.productNames, keyWidth: 100),
        KV('Expected', DateFormat('EEE, dd MMM').format(o.deliveryOn), keyWidth: 100),
        const SizedBox(height: 24),
        if (reached < 0)
          Text('This order was cancelled.', style: p(14, c: Colors.red.shade700))
        else
          for (final (i, (label, whenDate)) in steps.indexed)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: i <= reached ? Z.orange : const Color(0xFFD9D9D9),
                  child: i <= reached ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
                if (i < steps.length - 1) Container(width: 2, height: 46, color: i < reached ? Z.orange : const Color(0xFFD9D9D9)),
              ]),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: p(14, w: i == reached ? FontWeight.w600 : FontWeight.w400, c: i <= reached ? Z.text : Z.sub)),
                  Text(i <= reached ? stamp(whenDate) : 'Expected ${DateFormat('dd MMM').format(whenDate)}', style: p(11.5, c: Z.sub)),
                ]),
              ),
            ]),
        const SizedBox(height: 24),
        ZButton('Contact the Studio', outlined: true, onPressed: () => openUrl(context, Studio.phoneUri)),
      ]),
    );
  }
}
