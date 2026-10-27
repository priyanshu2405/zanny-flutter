import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zany_pottery/main.dart';
import 'package:zany_pottery/state.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  test('cart totals, coupon and free-shipping threshold', () {
    final s = AppState();
    expect(s.total, 0);
    s.addToCart(s.orders.first.lines.first.product, 2); // 2 × 10.99
    expect(s.delivery, AppState.deliveryFee);
    expect(s.applyCoupon('zany10'), isTrue);
    expect(s.discount, closeTo(2.198, 0.001));
    s.addToCart(s.orders.first.lines.first.product, 3); // 5 × 10.99 = 54.95
    expect(s.delivery, 0);
  });

  testWidgets('app boots to the splash screen', (tester) async {
    await tester.pumpWidget(ZanyApp(state: AppState()));
    expect(find.bySemanticsLabel('Zany Pottery and Glass'), findsWidgets);
    await tester.pump(const Duration(seconds: 3));
  });
}
