import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'cart.dart';
import 'home.dart';

class ProductFilter {
  final MainCat main;
  final String category, type;
  final RangeValues price;
  final int minRating;
  const ProductFilter({
    this.main = MainCat.pottery,
    this.category = 'All',
    this.type = 'All',
    this.price = const RangeValues(1, 50),
    this.minRating = 0,
  });

  List<Product> apply(Iterable<Product> list) => list
      .where((x) =>
          x.main == main &&
          (category == 'All' || x.category == category) &&
          (type == 'All' || x.type == type) &&
          x.price >= price.start &&
          x.price <= price.end &&
          x.rating >= minRating)
      .toList();

  bool get isDefault => category == 'All' && type == 'All' && price == const RangeValues(1, 50) && minRating == 0;

  ProductFilter copy({MainCat? main, String? category, String? type, RangeValues? price, int? minRating}) => ProductFilter(
        main: main ?? this.main,
        category: category ?? this.category,
        type: type ?? this.type,
        price: price ?? this.price,
        minRating: minRating ?? this.minRating,
      );
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard(this.product, {super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final fav = s.isFav(product.id);
    return InkWell(
      onTap: () => pushRoot(context, ItemDetailsScreen(product: product)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AspectRatio(
          aspectRatio: 1.06,
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFBDBDBD)), borderRadius: BorderRadius.circular(6)),
            clipBehavior: Clip.antiAlias,
            child: Stack(fit: StackFit.expand, children: [
              Padding(padding: const EdgeInsets.all(6), child: Image.asset(product.image, fit: BoxFit.contain)),
              Positioned(top: 6, right: 6, child: FavButton(productId: product.id, fav: fav)),
            ]),
          ),
        ),
        const SizedBox(height: 6),
        Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: p(12.5, w: FontWeight.w500)),
        Text('Item No. ${product.itemNo}', style: p(10, c: Z.sub)),
        const SizedBox(height: 4),
        Row(children: [
          Expanded(child: Text(money(product.price), style: p(12.5, w: FontWeight.w600))),
          SmallBtn('Add', pill: true, width: 56, onTap: () {
            s.addToCart(product);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text('${product.name} added to cart'),
                action: SnackBarAction(
                    label: 'VIEW CART', textColor: Z.orangeSoft, onPressed: () => pushRoot(context, const CartScreen())),
              ));
          }),
        ]),
      ]),
    );
  }
}

class FavButton extends StatelessWidget {
  final String productId;
  final bool fav;
  final double size;
  const FavButton({super.key, required this.productId, required this.fav, this.size = 26});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: fav ? 'Remove from favorites' : 'Add to favorites',
        child: GestureDetector(
          onTap: () => AppScope.read(context).toggleFav(productId),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: fav ? Z.orange : Colors.white,
              shape: BoxShape.circle,
              border: fav ? null : Border.all(color: Z.text),
            ),
            child: Icon(fav ? Icons.favorite : Icons.favorite_border, size: size * 0.62, color: fav ? Colors.white : Z.text),
          ),
        ),
      );
}

SliverGrid _grid(List<Product> list) => SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      delegate: SliverChildBuilderDelegate((_, i) => ProductCard(list[i]), childCount: list.length),
    );

Widget _categoryBand(BuildContext context, String selected, ValueChanged<String> onTap) => Container(
      color: Z.grey,
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
        children: [
          for (final c in shopCategories)
            CircleCategory(label: c.name, image: c.image, selected: c.name == selected, onTap: () => onTap(c.name)),
        ],
      ),
    );

// ─── Figma p19 — Shop home ───────────────────────────────────────────────

class ShopHomeScreen extends StatelessWidget {
  const ShopHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final best = products.where((x) => x.bestSeller).toList();
    return Scaffold(
      appBar: ZAppBar(
        'Shop',
        actions: [
          IconButton(
            tooltip: 'Favorites',
            onPressed: () => pushTab(context, const FavoritesScreen()),
            icon: const Icon(Icons.favorite_border, size: 26),
          ),
          CartButton(onTap: () => pushRoot(context, const CartScreen())),
          const SizedBox(width: 4),
        ],
        bottom: SearchBarStrip(
          onTap: () => pushRoot(context, const SearchScreen()),
          hint: 'Search products',
          showFilter: true,
          onFilter: () => pushTab(context, const ProductsScreen(openFilters: true)),
        ),
      ),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 132,
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset(img('banner'), fit: BoxFit.cover),
                  Container(color: Colors.black26),
                  Padding(
                    padding: const EdgeInsets.only(left: 22),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text.rich(TextSpan(style: p(15, w: FontWeight.w600, c: Colors.white), children: [
                        const TextSpan(text: 'A flat '),
                        TextSpan(text: '10%', style: p(21, w: FontWeight.w700, c: Colors.white)),
                        const TextSpan(text: ' Discount'),
                      ])),
                      Text('On your total bill', style: p(14, w: FontWeight.w600, c: Colors.white)),
                      Text('Code ${AppState.couponCode}', style: p(11, c: Colors.white)),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _categoryBand(context, 'All', (c) => pushTab(context, ProductsScreen(initial: ProductFilter(category: c)))),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 4, 8),
            child: Row(children: [
              Expanded(child: Text('Best Seller', style: p(15, w: FontWeight.w600))),
              TextButton(
                onPressed: () => pushTab(context, const ProductsScreen()),
                child: Text('View All', style: p(11, c: Z.orange)),
              ),
            ]),
          ),
        ),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 12), sliver: _grid(best)),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ]),
    );
  }
}

// ─── Figma p21 — Favorites ───────────────────────────────────────────────

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final list = products.where((x) => s.isFav(x.id)).toList();
    return Scaffold(
      appBar: ZAppBar('Favorites', actions: [CartButton(onTap: () => pushRoot(context, const CartScreen()))]),
      body: list.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.favorite_border, size: 54, color: Z.orange),
                  const SizedBox(height: 12),
                  Text('No favorites yet', style: p(16, w: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Tap the heart on any product to save it here.', textAlign: TextAlign.center, style: p(13, c: Z.sub)),
                  const SizedBox(height: 18),
                  SizedBox(width: 200, child: ZButton('Browse Products', onPressed: () => pushTab(context, const ProductsScreen()))),
                ]),
              ),
            )
          : CustomScrollView(slivers: [
              SliverPadding(padding: const EdgeInsets.fromLTRB(12, 16, 12, 20), sliver: _grid(list)),
            ]),
    );
  }
}

// ─── Figma p22 — Products ────────────────────────────────────────────────

class ProductsScreen extends StatefulWidget {
  final ProductFilter initial;
  final bool openFilters;
  const ProductsScreen({super.key, this.initial = const ProductFilter(), this.openFilters = false});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late ProductFilter _f = widget.initial;

  @override
  void initState() {
    super.initState();
    if (widget.openFilters) WidgetsBinding.instance.addPostFrameCallback((_) => _openFilters());
  }

  Future<void> _openFilters() async {
    final r = await Navigator.of(context, rootNavigator: true)
        .push<ProductFilter>(MaterialPageRoute(builder: (_) => FiltersScreen(current: _f), fullscreenDialog: true));
    if (r != null) setState(() => _f = r);
  }

  @override
  Widget build(BuildContext context) {
    final list = _f.apply(products);
    return Scaffold(
      appBar: ZAppBar('Products', actions: [
        CartButton(onTap: () => pushRoot(context, const CartScreen())),
        IconButton(
          tooltip: 'Filters',
          onPressed: _openFilters,
          icon: Badge(isLabelVisible: !_f.isDefault, smallSize: 8, backgroundColor: Z.orange, child: const Icon(Icons.tune)),
        ),
      ]),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 12, 12),
            child: ToggleChips(
              labels: const ['Pottery', 'Glass Fusion'],
              selected: _f.main.index,
              onChanged: (i) => setState(() => _f = _f.copy(main: MainCat.values[i])),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _categoryBand(context, _f.category, (c) => setState(() => _f = _f.copy(category: c)))),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
            child: Row(children: [
              Expanded(child: Text(_f.category == 'All' ? 'All Products' : _f.category, style: p(15, w: FontWeight.w600))),
              Text('${list.length} items', style: p(11.5, c: Z.sub)),
            ]),
          ),
        ),
        if (list.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                Text('No products match these filters.', style: p(14, c: Z.sub)),
                TextButton(onPressed: () => setState(() => _f = ProductFilter(main: _f.main)), child: Text('Clear filters', style: p(14, c: Z.orange))),
              ]),
            ),
          )
        else
          SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 12), sliver: _grid(list)),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ]),
    );
  }
}

// ─── Figma p23 — Filters ─────────────────────────────────────────────────

class FiltersScreen extends StatefulWidget {
  final ProductFilter current;
  const FiltersScreen({super.key, required this.current});
  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late ProductFilter _f = widget.current;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: ZAppBar('Filters', close: true, actions: [
          TextButton(
            onPressed: () => setState(() => _f = const ProductFilter()),
            child: Text('Reset', style: p(14, c: Colors.white)),
          ),
        ]),
        body: ListView(padding: const EdgeInsets.fromLTRB(12, 8, 12, 24), children: [
          ZDropdown(
            label: 'Main category',
            value: _f.main == MainCat.pottery ? 'Pottery' : 'Glass fusion',
            items: const ['Pottery', 'Glass fusion'],
            onChanged: (v) => setState(() => _f = _f.copy(main: v == 'Pottery' ? MainCat.pottery : MainCat.glass)),
          ),
          ZDropdown(
            label: 'Product category',
            value: _f.category,
            items: [for (final c in shopCategories) c.name],
            onChanged: (v) => setState(() => _f = _f.copy(category: v)),
          ),
          ZDropdown(label: 'Product type', value: _f.type, items: productTypes, onChanged: (v) => setState(() => _f = _f.copy(type: v))),
          const FormLabel('Price Range', top: 22),
          RangeSlider(
            values: _f.price,
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: Z.orange,
            inactiveColor: const Color(0xFFBDBDBD),
            labels: RangeLabels(money(_f.price.start), money(_f.price.end)),
            onChanged: (v) => setState(() => _f = _f.copy(price: v)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Text('\$${_f.price.start.toStringAsFixed(2)}', style: p(12)),
              const Spacer(),
              Text('\$${_f.price.end.toStringAsFixed(2)}', style: p(12)),
            ]),
          ),
          const FormLabel('Rating', top: 22),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (var r = 1; r <= 5; r++)
              ChoiceChip(
                selected: _f.minRating == r,
                onSelected: (_) => setState(() => _f = _f.copy(minRating: _f.minRating == r ? 0 : r)),
                showCheckmark: false,
                backgroundColor: Colors.white,
                selectedColor: Z.orangeSoft,
                shape: StadiumBorder(side: BorderSide(color: _f.minRating == r ? Z.orange : Z.border)),
                label: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('$r', style: p(13)),
                  const SizedBox(width: 4),
                  const Icon(Icons.star_rounded, color: Z.star, size: 18),
                ]),
              ),
          ]),
          const SizedBox(height: 60),
          Row(children: [
            Expanded(child: ZButton('Clear All', outlined: true, onPressed: () => Navigator.pop(context, ProductFilter(main: _f.main)))),
            const SizedBox(width: 12),
            Expanded(child: ZButton('Apply', onPressed: () => Navigator.pop(context, _f))),
          ]),
        ]),
      );
}

// ─── Figma p24 — Item Details ────────────────────────────────────────────

class ItemDetailsScreen extends StatefulWidget {
  final Product product;
  const ItemDetailsScreen({super.key, required this.product});
  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  int _qty = 1;
  int _page = 0;
  int _colour = 0;
  static const _swatches = [Color(0xFFC98E8E), Color(0xFFCDBF95), Color(0xFF6E9E86)];
  static const _swatchNames = ['Thistle', 'Panna Cotta', 'Heron'];

  @override
  Widget build(BuildContext context) {
    final x = widget.product;
    final s = AppScope.of(context);
    final gallery = [x.image, x.image];
    return Scaffold(
      appBar: ZAppBar('Item Details', actions: [CartButton(onTap: () => pushRoot(context, const CartScreen())), const SizedBox(width: 4)]),
      body: ListView(padding: EdgeInsets.zero, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            height: 285,
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFF8A8A8A)), borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              PageView(
                onPageChanged: (i) => setState(() => _page = i),
                children: [for (final g in gallery) Padding(padding: const EdgeInsets.all(28), child: Image.asset(g, fit: BoxFit.contain))],
              ),
              if (x.main == MainCat.pottery)
                Positioned(
                  left: 14,
                  top: 16,
                  child: Column(children: [
                    for (var i = 0; i < _swatches.length; i++)
                      Semantics(
                        button: true,
                        selected: _colour == i,
                        label: 'Colour ${_swatchNames[i]}',
                        child: GestureDetector(
                          onTap: () => setState(() => _colour = i),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _swatches[i],
                              shape: BoxShape.circle,
                              border: Border.all(color: _colour == i ? Z.text : Colors.transparent, width: 2),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              Positioned(top: 12, right: 12, child: FavButton(productId: x.id, fav: s.isFav(x.id), size: 28)),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < gallery.length; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: i == _page ? Z.orange : const Color(0xFFD9D9D9)),
                    ),
                ]),
              ),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(x.name, style: p(19, w: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              color: Z.teal,
              child: Text('In stock', style: p(10.5, c: Colors.white)),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Text(money(x.price), style: p(17, w: FontWeight.w600)),
              const SizedBox(width: 14),
              Text(money(x.oldPrice), style: p(10.5, c: Z.sub, d: TextDecoration.lineThrough)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: Z.orange, borderRadius: BorderRadius.circular(3)),
                child: Text('-${x.discount}% OFF', style: p(11, w: FontWeight.w500, c: Colors.white)),
              ),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              Text('Order Quantity:', style: p(12.5)),
              const SizedBox(width: 14),
              QtyButtons(value: _qty, onChanged: (v) => setState(() => _qty = v)),
            ]),
          ]),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Description', style: p(15, w: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(x.description, style: p(12.5, h: 1.65)),
            const SizedBox(height: 12),
            Bullets(x.details, size: 12.5, gap: 0),
          ]),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(children: [
            Expanded(
              child: ZButton('Add to Cart', outlined: true, onPressed: () {
                s.addToCart(x, _qty);
                toast(context, '$_qty × ${x.name} added to cart');
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ZButton('Buy Now', onPressed: () {
                s.addToCart(x, _qty);
                pushRoot(context, const CartScreen());
              }),
            ),
          ]),
        ),
      ),
    );
  }
}
