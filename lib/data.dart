import 'package:intl/intl.dart';

String img(String name) => 'assets/images/$name.jpg';
const logoAsset = 'assets/images/logo.png';

String money(double v) => '\$ ${v.toStringAsFixed(2)}';
String stamp(DateTime d) => "${DateFormat('dd MMMM').format(d).toLowerCase()} '${DateFormat('yy').format(d)} ${DateFormat('hh.mm a').format(d)}";

// ─── Studio info (from Figma Contact / footer) ────────────────────────────
class Studio {
  static const address = '993 Fir St #71, Sherwood Park,\nAB T8A 4N5, Canada';
  static const email = 'zanypottery@gmail.com';
  static const phone = '+1 780-250-9269';
  static const phoneUri = 'tel:+17802509269';
  static const directions = 'https://maps.app.goo.gl/8yKi2oKb6gDj8yfTA';
  static const instagram = 'https://www.instagram.com/zanypotteryandglass/';
}

// ─── Studio events ───────────────────────────────────────────────────────
class StudioEvent {
  final String id, title, image, description;
  final DateTime start, end;
  final String? price;
  const StudioEvent(this.id, this.title, this.image, this.start, this.end, this.description, {this.price});
  String get dateLabel {
    final d = start.day;
    final suf = (d >= 11 && d <= 13) ? 'th' : const {1: 'st', 2: 'nd', 3: 'rd'}[d % 10] ?? 'th';
    return '${DateFormat('EEEE MMMM').format(start)} $d$suf ${start.year}';
  }

  String get timeLabel => '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}';
}

final events = <StudioEvent>[
  StudioEvent('baby-print', 'Baby Print Party: Daddy and Grandpa Prints', img('event_baby_print'),
      DateTime(2026, 6, 9, 12), DateTime(2026, 6, 9, 14),
      'Bring your little one in to make hand and footprint keepsakes for Dad and Grandpa. We’ll help with the prints; you add the colour and the love.'),
  StudioEvent('dad-night', 'Kids Night Out- Make it for Dad!', img('event_dad'), DateTime(2026, 6, 12, 12),
      DateTime(2026, 6, 12, 14), 'Drop the kids off for a creative night painting a one-of-a-kind Father’s Day gift. (\$32+tx)',
      price: '\$32 + tax'),
  StudioEvent('teacher-night', 'Kids Night Out!- Make it for Teacher/Coach/Assistant!', img('event_teacher'),
      DateTime(2026, 6, 19, 12), DateTime(2026, 6, 19, 14),
      'End the school year with a handmade thank-you. Kids paint a personalised piece for a favourite teacher, coach or assistant. (\$32+tx)',
      price: '\$32 + tax'),
  StudioEvent('donuts', 'Mmmmm Donuts and rootBEER for Dad!', img('event_donuts'), DateTime(2026, 6, 21, 12),
      DateTime(2026, 6, 21, 18),
      'Reserve a table & come in with Dad, Grandpa or BOTH and enjoy some complementary donuts and rootBEER while painting away on Father’s Day! Be creative together and make some memories that will last forever. Just like Homer says, MMMMMMMMmmmmmm memories hahaha'),
  StudioEvent('plant-bingo', 'Pottery Painting & PLANT BINGO!', img('event_bingo'), DateTime(2026, 6, 24, 18, 30),
      DateTime(2026, 6, 24, 20, 30),
      'Paint a planter, play a few rounds of bingo and win plants to take home. A relaxed evening for plant people and first-time painters alike.'),
];

// ─── Shop ────────────────────────────────────────────────────────────────
enum MainCat { pottery, glass }

class ShopCategory {
  final String name, image;
  const ShopCategory(this.name, this.image);
}

final shopCategories = <ShopCategory>[
  ShopCategory('All', img('banner2')),
  ShopCategory('Table Ware', img('shopcat_tableware')),
  ShopCategory('Home Decor', img('shopcat_decor')),
  ShopCategory('Figurines', img('shopcat_figurines')),
  ShopCategory('Banks', img('shopcat_banks')),
  ShopCategory('Boxes', img('shopcat_boxes')),
];

class Product {
  final String id, name, itemNo, image, category, type;
  final MainCat main;
  final double price, oldPrice, rating;
  final bool bestSeller;
  final String description;
  final List<String> details;
  const Product({
    required this.id,
    required this.name,
    required this.itemNo,
    required this.image,
    required this.category,
    required this.type,
    this.main = MainCat.pottery,
    this.price = 10.99,
    this.oldPrice = 15.99,
    this.rating = 4.8,
    this.bestSeller = false,
    this.description = 'A paint-your-own bisque piece. Choose your colours in the studio and we’ll glaze and fire it so it’s ready to use and enjoy.',
    this.details = const ['Food safe once glazed and fired', 'Ready for pickup in about a week'],
  });
  int get discount => ((1 - price / oldPrice) * 100).round();
}

const _lodgeDescription =
    'Mugs tend to pile up in your cupboard. You get one from a gift shop at a National Park, another at a holiday gift exchange. You try to give them each special attention—until this one comes along. With its soothing hand-feel and durable construction, this is the coffee mug that you\'ll want to use every single day. Trust us. Live with others? Get a few. They’ll want to use it, too.';

final products = <Product>[
  Product(id: 'dragon', name: 'Baby Dragon', itemNo: '5478', image: img('p_dragon'), category: 'Figurines', type: 'Figurine', bestSeller: true),
  Product(id: 'cruet', name: 'Italian Olive Oil Cruet with Stopper', itemNo: '4258', image: img('p_cruet'), category: 'Table Ware', type: 'Pitcher', bestSeller: true),
  Product(id: 'caterpillar', name: 'Caterpillar Bank', itemNo: '5479', image: img('p_caterpillar'), category: 'Banks', type: 'Bank', bestSeller: true),
  Product(id: 'bracelet', name: 'Friendship Bracelet Mug', itemNo: '4259', image: img('p_bracelet_mug'), category: 'Table Ware', type: 'Mug', bestSeller: true),
  Product(id: 'fish', name: 'Oval Fish Platter', itemNo: '5480', image: img('p_fish_platter'), category: 'Table Ware', type: 'Platter'),
  Product(id: 'oval', name: 'Oval Platter', itemNo: '4260', image: img('p_oval_platter'), category: 'Table Ware', type: 'Platter'),
  Product(id: 'handles', name: 'Platter with Handles - 15 in.', itemNo: '5481', image: img('p_handles_platter'), category: 'Table Ware', type: 'Platter'),
  Product(id: 'espresso', name: 'Espresso Cup with Saucer', itemNo: '4261', image: img('p_espresso'), category: 'Table Ware', type: 'Cup'),
  Product(id: 'cone', name: 'Tall Cone/Flare Mug', itemNo: '5482', image: img('p_cone_mug'), category: 'Table Ware', type: 'Mug'),
  Product(id: 'pitcher', name: 'Medium Pitcher', itemNo: '4262', image: img('p_pitcher'), category: 'Table Ware', type: 'Pitcher'),
  Product(
    id: 'lodge',
    name: 'Lodge Mug',
    itemNo: '5483',
    image: img('p_lodge_mug'),
    category: 'Table Ware',
    type: 'Mug',
    description: _lodgeDescription,
    details: [
      'Available as a Single or 4-Packs',
      'Classic Cool: Heron, Black Mountain, Morel, Eggshell',
      'Classic Warm: Amaro, Panna Cotta, Morel, Eggshell',
      'Afterglow: Thistle, Heron, Amaro, Panna Cotta',
      'Plein Air: Water Lily, Thistle, Panna Cotta, Morel',
      'Solarium: Lagoon, Panna Cotta, Morel, Eggshell',
      'Dimensions: 3.1" dia x 4.25" H',
      'Weight: 1 lb',
      'Holds 10 oz comfortably, 12 oz to the brim',
      'Material: 100% Lead Free Stoneware',
      'Our pottery is made by humans and reduction-fired in Asheville, North Carolina. Any differences in glaze applications and surfaces are there to embrace.',
    ],
  ),
  Product(id: 'tea', name: 'Tea For One', itemNo: '4263', image: img('p_tea_for_one'), category: 'Table Ware', type: 'Teapot'),
  Product(id: 'whitemug', name: 'Classic Stoneware Mug', itemNo: '5484', image: img('p_white_mug'), category: 'Table Ware', type: 'Mug'),
  Product(id: 'g-flower', name: 'Fused Glass Flower Plate', itemNo: '6101', image: img('glass_flower'), category: 'Home Decor', type: 'Plate', main: MainCat.glass, price: 24.99, oldPrice: 29.99),
  Product(id: 'g-ocean', name: 'Ocean Glass Bowl', itemNo: '6102', image: img('glass_ocean'), category: 'Home Decor', type: 'Bowl', main: MainCat.glass, price: 29.99, oldPrice: 34.99),
  Product(id: 'g-swirl', name: 'Swirl Glass Dish', itemNo: '6103', image: img('glass_swirl'), category: 'Table Ware', type: 'Bowl', main: MainCat.glass, price: 22.99, oldPrice: 27.99),
  Product(id: 'g-leaf', name: 'Green Leaf Glass Tray', itemNo: '6104', image: img('glass_leaf'), category: 'Table Ware', type: 'Plate', main: MainCat.glass, price: 19.99, oldPrice: 24.99),
  Product(id: 'g-blue', name: 'Blue Lagoon Glass Bowl', itemNo: '6105', image: img('glass_blue'), category: 'Home Decor', type: 'Bowl', main: MainCat.glass, price: 34.99, oldPrice: 39.99),
];

Product productById(String id) => products.firstWhere((p) => p.id == id);

const productTypes = ['All', 'Cup', 'Mug', 'Plate', 'Platter', 'Bowl', 'Pitcher', 'Teapot', 'Figurine', 'Bank'];

// ─── Bookings & orders ───────────────────────────────────────────────────
enum BookingStatus { pending, accepted, completed, cancelled }

extension BookingStatusX on BookingStatus {
  String get label => const ['Pending', 'Accept', 'Completed', 'Cancelled'][index];
}

class Booking {
  final String orderNo, bookingFor, summary;
  final DateTime dateTime;
  BookingStatus status;
  int? rating;
  Booking(this.orderNo, this.dateTime, this.bookingFor, this.status, {this.summary = ''});
}

class CartLine {
  final Product product;
  int qty;
  CartLine(this.product, [this.qty = 1]);
  double get total => product.price * qty;
}

enum OrderStatus { placed, onTheWay, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get label => const ['Order Placed', 'On The Way', 'Delivered', 'Cancelled'][index];
}

class Address {
  final String name, lines, email, phone;
  const Address(this.name, this.lines, this.email, this.phone);
}

class Order {
  final String orderNo;
  final DateTime placedOn, deliveryOn;
  final List<CartLine> lines;
  final double subtotal, delivery, discount, gift;
  final Address address;
  final String paymentType;
  OrderStatus status;
  int? rating;
  Order({
    required this.orderNo,
    required this.placedOn,
    required this.deliveryOn,
    required this.lines,
    required this.subtotal,
    required this.delivery,
    required this.discount,
    required this.address,
    this.gift = 0,
    this.paymentType = 'Credit Card',
    this.status = OrderStatus.placed,
  });
  double get total => subtotal + delivery + gift - discount;
  String get productNames => lines.map((l) => l.product.name).join(', ');
}

class AppNotification {
  final String title, body, time;
  bool unread;
  AppNotification(this.title, this.body, this.time, {this.unread = false});
}

// ─── Form options ────────────────────────────────────────────────────────
const activityTypes = ['Pottery Painting', 'Pottery Wheels', 'Clay Handbuilding', 'Glass Fusion'];
const paymentPrefs = ['Individual Payments', 'One Payment for the Group', 'Pay at the Studio'];
const occasions = ['None', 'Birthday', 'Anniversary', 'Graduation', 'Date Night', 'Other'];
const referralSources = ['Friend Referral', 'Instagram', 'Facebook', 'Google Search', 'Walked By', 'Other'];
const partyEventTypes = [
  'Kids Birthday Party',
  'Adult Birthday Party',
  'Bridal Shower',
  'Bachelorette Party',
  'Baby Shower',
  'Private Event',
  'Team Building',
  'School & Group Event',
  'After School Program',
  'Summer Camp',
];
const partyActivities = ['Pottery', 'Pottery Wheel', 'Clay Handbuilding', 'Glass Fusion'];
const ageGroups = ['Under 5', '5 to 10', '11 to 14', 'Teens', 'Adults', 'Mixed Ages'];
const giftOccasions = ['Birthdays', 'Anniversary', 'Wedding', 'Mother’s Day', 'Father’s Day', 'Holidays', 'Thank You'];
const courses = [
  'Beginner Pottery Course',
  'Wheel Throwing Course',
  'Ceramic Sculpting Course',
  'Advanced Ceramic Techniques',
  'Pottery Wheel Classes',
  'Clay Handbuilding Classes',
  'Glass Fusion Workshops',
  'Ceramic Painting',
];
