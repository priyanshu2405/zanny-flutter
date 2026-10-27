import 'package:flutter/material.dart';

import 'data.dart';

/// In-memory app state for the prototype. Replace with API calls later.
class AppState extends ChangeNotifier {
  // Profile (sample values from the Figma "My Profile" screen)
  String name = 'Joe Thomas';
  String email = 'zoesaldana@gmail.com';
  String phone = '+1 985 547 2222';
  String address = 'Kevin Zegers\nP.O. Box 4400, Fredericton,\nNew Brunswick, E3B 5A3.';
  bool loggedIn = false;
  bool notificationsOn = true;
  final List<String> uploadedPictures = []; // local file paths

  // Shop
  final Set<String> favourites = {'fish', 'oval', 'handles', 'espresso'};
  final List<CartLine> cart = [];
  String? coupon;
  bool giftWrap = false;
  String giftOccasion = giftOccasions.first;

  static const freeShippingOver = 50.0;
  static const deliveryFee = 7.99;
  static const giftFee = 4.99;
  static const couponCode = 'ZANY10';

  int get cartCount => cart.fold(0, (s, l) => s + l.qty);
  double get subtotal => cart.fold<double>(0, (s, l) => s + l.total);
  double get delivery => subtotal == 0 || subtotal >= freeShippingOver ? 0 : deliveryFee;
  double get discount => coupon == couponCode ? subtotal * 0.10 : 0;
  double get gift => giftWrap ? giftFee : 0;
  double get total => subtotal + delivery + gift - discount;

  // Bookings, orders, notifications
  final List<Booking> bookings = [
    Booking('#452788', DateTime(2026, 6, 8, 11, 30), 'Kids Birthday party', BookingStatus.accepted),
    Booking('#452712', DateTime(2026, 6, 8, 11, 30), 'Team Building', BookingStatus.completed),
  ];
  late final List<Order> orders = [
    Order(
      orderNo: '#452788',
      placedOn: DateTime(2026, 6, 8, 11, 30),
      deliveryOn: DateTime(2026, 6, 15, 12, 30),
      lines: [CartLine(productById('lodge')), CartLine(productById('oval'))],
      subtotal: 21.98,
      delivery: 0,
      discount: 5,
      address: _sampleAddress,
      status: OrderStatus.onTheWay,
    ),
    Order(
      orderNo: '#452701',
      placedOn: DateTime(2026, 5, 28, 15, 10),
      deliveryOn: DateTime(2026, 6, 2, 12, 30),
      lines: [CartLine(productById('bracelet'), 2)],
      subtotal: 21.98,
      delivery: 0,
      discount: 0,
      address: _sampleAddress,
      status: OrderStatus.delivered,
    ),
  ];
  final List<AppNotification> notifications = [
    AppNotification('Your piece ready for pickup',
        'Your painted Lodge Mug has been glazed and fired. Pick it up any time during studio hours.', '09:49 AM',
        unread: true),
    AppNotification('Booking accepted', 'Your Kids Birthday party booking #452788 is confirmed for 08 June.', '09:12 AM'),
    AppNotification('Your order is on the way', 'Order #452788 has shipped and should arrive by 15 June.', 'Yesterday'),
  ];

  static const _sampleAddress = Address('Kevin Zegers', 'P.O. Box 4400, Fredericton,\nNew Brunswick, E3B 5A3.',
      'Kevinzegers@email.com', '+1 9876543210');

  String _id() => '#${(DateTime.now().millisecondsSinceEpoch % 900000 + 100000)}';

  // ── Auth
  void signIn() {
    loggedIn = true;
    notifyListeners();
  }

  void register({required String first, required String last, required String email, required String phone}) {
    name = '$first $last'.trim();
    this.email = email;
    this.phone = phone;
    loggedIn = true;
    notifyListeners();
  }

  void logout() {
    loggedIn = false;
    notifyListeners();
  }

  void updateProfile({required String name, required String email, required String phone, required String address}) {
    this.name = name;
    this.email = email;
    this.phone = phone;
    this.address = address;
    notifyListeners();
  }

  void toggleNotifications(bool v) {
    notificationsOn = v;
    notifyListeners();
  }

  void addPicture(String path) {
    uploadedPictures.insert(0, path);
    notifyListeners();
  }

  // ── Shop
  bool isFav(String id) => favourites.contains(id);
  void toggleFav(String id) {
    favourites.contains(id) ? favourites.remove(id) : favourites.add(id);
    notifyListeners();
  }

  int qtyInCart(String id) => cart.where((l) => l.product.id == id).fold(0, (s, l) => s + l.qty);

  void addToCart(Product p, [int qty = 1]) {
    final i = cart.indexWhere((l) => l.product.id == p.id);
    i >= 0 ? cart[i].qty += qty : cart.add(CartLine(p, qty));
    notifyListeners();
  }

  void setQty(Product p, int qty) {
    final i = cart.indexWhere((l) => l.product.id == p.id);
    if (i < 0) return;
    qty <= 0 ? cart.removeAt(i) : cart[i].qty = qty;
    notifyListeners();
  }

  void clearCart() {
    cart.clear();
    coupon = null;
    giftWrap = false;
    notifyListeners();
  }

  bool applyCoupon(String code) {
    final ok = code.trim().toUpperCase() == couponCode;
    coupon = ok ? couponCode : null;
    notifyListeners();
    return ok;
  }

  void setGift(bool on, [String? occasion]) {
    giftWrap = on;
    if (occasion != null) giftOccasion = occasion;
    notifyListeners();
  }

  Order placeOrder({required Address address, required String paymentType}) {
    final now = DateTime.now();
    final o = Order(
      orderNo: _id(),
      placedOn: now,
      deliveryOn: now.add(const Duration(days: 7)),
      lines: cart.map((l) => CartLine(l.product, l.qty)).toList(),
      subtotal: subtotal,
      delivery: delivery,
      discount: discount,
      gift: gift,
      address: address,
      paymentType: paymentType,
    );
    orders.insert(0, o);
    clearCart();
    return o;
  }

  void repeatOrder(Order o) {
    for (final l in o.lines) {
      addToCart(l.product, l.qty);
    }
  }

  void cancelOrder(Order o) {
    o.status = OrderStatus.cancelled;
    notifyListeners();
  }

  void rateOrder(Order o, int stars) {
    o.rating = stars;
    notifyListeners();
  }

  // ── Bookings
  Booking addBooking(String bookingFor, DateTime when, String summary) {
    final b = Booking(_id(), when, bookingFor, BookingStatus.pending, summary: summary);
    bookings.insert(0, b);
    notifications.insert(0, AppNotification('Booking received', '$bookingFor ${b.orderNo} is waiting for studio confirmation.', 'Just now', unread: true));
    notifyListeners();
    return b;
  }

  void cancelBooking(Booking b) {
    b.status = BookingStatus.cancelled;
    notifyListeners();
  }

  void rateBooking(Booking b, int stars) {
    b.rating = stars;
    notifyListeners();
  }

  void markNotificationsRead() {
    for (final n in notifications) {
      n.unread = false;
    }
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState super.notifier, required super.child});
  static AppState of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
  static AppState read(BuildContext c) => c.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
