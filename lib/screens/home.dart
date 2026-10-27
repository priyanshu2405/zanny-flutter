import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'account.dart';
import 'cart.dart';
import 'events.dart';
import 'info_pages.dart';
import 'reserve.dart';
import 'shop.dart';

/// Figma p5 — Home.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = AppScope.of(context).notifications.any((n) => n.unread);
    return Scaffold(
      appBar: ZAppBar(
        'Home',
        actions: [
          CartButton(onTap: () => pushRoot(context, const CartScreen())),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => pushTab(context, const NotificationsScreen()),
            icon: Badge(isLabelVisible: unread, smallSize: 8, backgroundColor: Z.orange, child: const Icon(Icons.notifications_none, size: 28)),
          ),
          const SizedBox(width: 4),
        ],
        bottom: SearchBarStrip(onTap: () => pushRoot(context, const SearchScreen())),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 14),
          const _PromoCarousel(),
          const SizedBox(height: 12),
          Container(
            color: Z.grey,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              for (final (label, image) in const [
                ('Pottery Painting', 'cat_painting'),
                ('Pottery Wheels', 'cat_wheels'),
                ('Clay Handbuilding', 'cat_handbuilding'),
                ('Glass Fusion', 'cat_glass'),
              ])
                CircleCategory(
                  label: label,
                  image: img(image),
                  size: 66,
                  onTap: () => pushRoot(context, ReserveTableScreen(activity: label)),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 22, 10, 0),
            child: IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(
                  child: _PhotoCard(
                    image: img('studio_card'),
                    title: 'Create in studio',
                    subtitle: 'A Creative Space For Everyone',
                    bullets: const [
                      'No appointment needed walk ins welcome!',
                      'Choose from hundreds of pottery & glass pieces',
                      'We provide all the materials and guidance',
                      'Fun for all ages & skill levels',
                      'We glaze & fire your piece',
                      'Pick it up in about a week',
                    ],
                    button: 'Plan your visit',
                    onTap: () => pushRoot(context, const ReserveTableScreen()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PhotoCard(
                    image: img('celebrate_card'),
                    title: 'Celebrate With Us',
                    bullets: const [
                      'Parties & Special Events',
                      'Adult Birthday Parties',
                      'Kids Birthday Parties',
                      'Bridal Showers & Bachelorette Parties',
                      'Private Events',
                    ],
                    button: 'Book your party',
                    onTap: () => pushRoot(context, const PartyBookingScreen()),
                  ),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 8, 0),
            child: Row(children: [
              for (final (label, image, page) in <(String, String, Widget)>[
                ('Parties & Events', 'parties', const PartiesScreen()),
                ('Kids Programs', 'kids', const KidsProgramsScreen()),
                ('Team Building', 'team', const TeamBuildingScreen()),
              ])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => pushTab(context, page),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        AspectRatio(
                          aspectRatio: 1.25,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(img(image), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: p(13, w: FontWeight.w500)),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: 22),
          Container(
            color: Z.beige,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Training Classes & workshops', style: p(16, w: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Available in both Online and Offline Formats', style: p(13.5, c: Z.sub)),
              const SizedBox(height: 8),
              const Bullets([
                'Pottery wheel and painting classes',
                'Clay building classes',
                'Glass Fusion workshops',
                'Adult & kids classes',
              ], size: 13.5, gap: 0),
              const SizedBox(height: 14),
              Row(children: [
                SizedBox(width: 124, child: ZButton('Enroll Now', height: 36, fontSize: 12.5, onPressed: () => pushTab(context, const TrainingScreen()))),
                const SizedBox(width: 12),
                SizedBox(
                    width: 124,
                    child: ZButton('Contact Us', outlined: true, height: 36, fontSize: 12.5, onPressed: () => pushTab(context, const ContactScreen()))),
              ]),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: Row(children: [
              Expanded(child: Text('Instagram feed', style: p(16, w: FontWeight.w600))),
              TextButton(onPressed: () => openUrl(context, Studio.instagram), child: Text('Follow', style: p(13, c: Z.orange))),
            ]),
          ),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => openUrl(context, Studio.instagram),
                child: Image.asset(img('insta${i + 1}'), width: 78, height: 82, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// White-outlined search pill sitting inside the teal app bar.
class SearchBarStrip extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onTap;
  final bool showFilter;
  final String hint;
  final VoidCallback? onFilter;
  const SearchBarStrip({super.key, required this.onTap, this.showFilter = false, this.hint = 'Search', this.onFilter});

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6), side: const BorderSide(color: Colors.white, width: 1.2)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 40,
              child: Row(children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text(hint, style: p(13, c: Colors.white))),
                if (showFilter)
                  IconButton(
                    tooltip: 'Filters',
                    onPressed: onFilter,
                    icon: const Icon(Icons.tune, color: Colors.white, size: 20),
                  ),
              ]),
            ),
          ),
        ),
      );
}

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();
  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  final _c = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = [
      (img('banner'), 'A flat ', '10%', ' Discount', 'On your total bill', 'Use code ${AppState.couponCode} at checkout'),
      (img('banner2'), 'Walk-ins ', 'welcome', '', 'No appointment needed', 'Pick a piece and start painting'),
      (img('celebrate_card'), 'Parties for ', 'all ages', '', 'Birthdays, showers & team events', 'Book your party today'),
    ];
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _c,
        itemCount: slides.length,
        itemBuilder: (_, i) {
          final (image, a, b, c, line2, line3) = slides[i];
          return GestureDetector(
            onTap: () => i == 0
                ? pushTab(context, const ShopHomeScreen())
                : i == 1
                    ? pushRoot(context, const ReserveTableScreen())
                    : pushRoot(context, const PartyBookingScreen()),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
              child: Stack(fit: StackFit.expand, children: [
                Image.asset(image, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 16, 0),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text.rich(TextSpan(style: p(16, w: FontWeight.w600, c: Colors.white), children: [
                      TextSpan(text: a),
                      TextSpan(text: b, style: p(22, w: FontWeight.w700, c: Colors.white)),
                      TextSpan(text: c),
                    ])),
                    Text(line2, style: p(15, w: FontWeight.w600, c: Colors.white)),
                    const SizedBox(height: 4),
                    Text(line3, style: p(11.5, c: Colors.white.withValues(alpha: 0.9))),
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String image, title, button;
  final String? subtitle;
  final List<String> bullets;
  final VoidCallback onTap;
  const _PhotoCard(
      {required this.image, required this.title, this.subtitle, required this.bullets, required this.button, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Z.border)),
        child: Stack(children: [
          Positioned.fill(child: Image.asset(image, fit: BoxFit.cover)),
          Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.55))),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: p(15, w: FontWeight.w600, c: Colors.white)),
              if (subtitle != null) Text(subtitle!, style: p(10.5, c: Colors.white)),
              const SizedBox(height: 8),
              for (final b in bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('•  ', style: p(10.5, c: Colors.white)),
                    Expanded(child: Text(b, style: p(10.5, c: Colors.white, h: 1.35))),
                  ]),
                ),
              const Spacer(),
              const SizedBox(height: 12),
              Center(child: SmallBtn(button.toUpperCase(), width: 132, onTap: onTap)),
            ]),
          ),
        ]),
      );
}

/// Search across products, studio events and pages (search field on Home).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _q = '';

  static final _pages = <(String, Widget)>[
    ('Training classes', const TrainingScreen()),
    ('Parties & Special Events', const PartiesScreen()),
    ('Kids Programs', const KidsProgramsScreen()),
    ('Team Building', const TeamBuildingScreen()),
    ('Studio Events', const StudioEventsScreen()),
    ('Reserve a Table', const ReserveTableScreen()),
    ('Party Booking', const PartyBookingScreen()),
    ('Contact Us', const ContactScreen()),
    ('About Us', const AboutScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final prods = q.isEmpty ? <Product>[] : products.where((x) => '${x.name} ${x.category} ${x.type}'.toLowerCase().contains(q)).toList();
    final evs = q.isEmpty ? <StudioEvent>[] : events.where((e) => e.title.toLowerCase().contains(q)).toList();
    final pages = q.isEmpty ? _pages : _pages.where((x) => x.$1.toLowerCase().contains(q)).toList();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), onPressed: () => Navigator.pop(context)),
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          onChanged: (v) => setState(() => _q = v),
          cursorColor: Colors.white,
          style: p(15, c: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search products, events, classes',
            hintStyle: p(14, c: Colors.white70),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
      body: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
        if (q.isNotEmpty && prods.isEmpty && evs.isEmpty && pages.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text('No results for “$_q”. Try “mug”, “party” or “glass”.', textAlign: TextAlign.center, style: p(14, c: Z.sub)),
          ),
        if (prods.isNotEmpty) _header('Products'),
        for (final x in prods)
          ListTile(
            leading: Image.asset(x.image, width: 48, height: 48, fit: BoxFit.cover),
            title: Text(x.name, style: p(14)),
            subtitle: Text('${x.category} · ${money(x.price)}', style: p(12, c: Z.sub)),
            onTap: () => pushRoot(context, ItemDetailsScreen(product: x)),
          ),
        if (evs.isNotEmpty) _header('Studio Events'),
        for (final e in evs)
          ListTile(
            leading: Image.asset(e.image, width: 48, height: 48, fit: BoxFit.cover),
            title: Text(e.title, style: p(14)),
            subtitle: Text(e.dateLabel, style: p(12, c: Z.sub)),
            onTap: () => pushRoot(context, EventDetailsScreen(event: e)),
          ),
        if (pages.isNotEmpty) _header(q.isEmpty ? 'Explore' : 'Pages'),
        for (final (label, page) in pages)
          ListTile(
            leading: const Icon(Icons.north_east, color: Z.teal),
            title: Text(label, style: p(14)),
            onTap: () => pushRoot(context, page),
          ),
      ]),
    );
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(t, style: p(13, w: FontWeight.w600, c: Z.teal)),
      );
}
