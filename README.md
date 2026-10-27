# Zany Pottery & Glass — Flutter app (Android + iOS)

Built from the ZANY Figma export (mobile frames, PDF pages 1–41 and 43).
Colours, Poppins typography, layouts and imagery are taken from the file.

## Run

```bash
./setup.sh      # creates android/ + ios/, adds internet, camera and photo permissions
flutter run
```
Needs Flutter 3.27+ (Dart 3.6+). On Windows, run the commands in `setup.sh` by hand.
Run `flutter test` for the basic smoke/cart tests.

## Screen map (Figma page → file)

| Figma | Screen | File |
|---|---|---|
| p1–p4 | Splash, Sign In, Create account, OTP (+ Forgot/Reset password) | `screens/auth.dart` |
| p5, p41 | Home, side menu, bottom bar, search | `screens/home.dart`, `screens/shell.dart` |
| p6–p9, p38, p39 | Training, Parties, Kids Programs, Team Building, About, Contact (+ Enroll, Policy pages) | `screens/info_pages.dart` |
| p10–p14 | Reserve a Table (3 steps), Party Booking (2 steps), booking confirmation | `screens/reserve.dart` |
| p15–p17 | Studio Events list / calendar, Event Details | `screens/events.dart` |
| p18 | My Bookings | `screens/bookings.dart` |
| p19–p24 | Shop, Favorites, Products, Filters, Item Details | `screens/shop.dart` |
| p25–p30 | Cart, Order details, Checkout, Payment method, Payment, Success | `screens/cart.dart` |
| p31–p33 | My Orders, Order Details, Feedback dialog (+ Track Order) | `screens/orders.dart` |
| p34–p37, p40 | Settings, My Profile (photo upload), Edit Profile, Change Password, Notifications | `screens/account.dart` |

## Where to change things
- Brand tokens: `lib/theme.dart` (`Z` colours, `p()` text style).
- Content & sample data: `lib/data.dart` (events, products, form options, studio contact).
- App state (in-memory, no backend): `lib/state.dart`.

## Decisions where the design was inconsistent
1. One bottom bar everywhere: Home / My Bookings / My Orders / Account. Favorites lives in the shop header and side menu.
2. "Studio Events" added to the side menu (it had no entry point).
3. Design events are dated June 2026; past events show "This event has ended".
4. Contact details follow the Figma (zanypottery@gmail.com), which differ from the live site.
5. Lorem ipsum replaced with realistic copy; typos fixed (Favorate, gidance, Search restaurant, Tr→Fr).
6. Assumed rules: free shipping from $50 (else $7.99), coupon `ZANY10` = 10% off, parties booked 14+ days ahead.
7. Added (not in Figma): Enroll form, Track Order, Privacy/Terms placeholder text, reset-password step.

Payments, OTP and bookings are simulated — any 6-digit OTP verifies and no card is charged.
