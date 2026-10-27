import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'account.dart';
import 'auth.dart';
import 'bookings.dart';
import 'events.dart';
import 'home.dart';
import 'info_pages.dart';
import 'orders.dart';
import 'shop.dart';

/// Lets drawer items and cross-tab links drive the shell.
class ShellController {
  static _MainShellState? _state;

  /// Switch to [tab]; if [root] is given it replaces that tab's stack
  /// (drawer destinations show the menu icon because they are a root).
  static void go(int tab, {Widget? root}) => _state?._go(tab, root: root);
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  final _keys = List.generate(4, (_) => GlobalKey<NavigatorState>());
  final _roots = <Widget>[const HomeScreen(), const MyBookingsScreen(), const MyOrdersScreen(), const MyProfileScreen()];

  @override
  void initState() {
    super.initState();
    ShellController._state = this;
  }

  @override
  void dispose() {
    if (ShellController._state == this) ShellController._state = null;
    super.dispose();
  }

  void _go(int tab, {Widget? root}) {
    setState(() => _tab = tab);
    final nav = _keys[tab].currentState;
    if (nav == null) return;
    if (root != null) {
      nav.pushAndRemoveUntil(PageRouteBuilder(pageBuilder: (_, __, ___) => root, transitionDuration: Duration.zero), (_) => false);
    } else {
      nav.popUntil((r) => r.isFirst);
    }
  }

  void _onTap(int i) {
    if (i == _tab) {
      // Re-tapping a tab returns it to its default screen (a drawer page may be the root).
      _go(i, root: _roots[i]);
    } else {
      setState(() => _tab = i);
    }
  }

  Future<void> _handleBack() async {
    final nav = _keys[_tab].currentState;
    if (nav != null && await nav.maybePop()) return;
    if (_tab != 0) {
      setState(() => _tab = 0);
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        key: shellScaffoldKey,
        drawer: const ZanyDrawer(),
        body: IndexedStack(
          index: _tab,
          children: [
            for (var i = 0; i < 4; i++)
              Navigator(
                key: _keys[i],
                onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => _roots[i]),
              ),
          ],
        ),
        bottomNavigationBar: ZBottomNav(index: _tab, onTap: _onTap),
      ),
    );
  }
}

/// Orange bottom bar from the Figma (white icons, underline on the active tab).
class ZBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const ZBottomNav({super.key, required this.index, required this.onTap});

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.edit_calendar_outlined, 'My Bookings'),
    (Icons.shopping_bag_outlined, 'My Orders'),
    (Icons.person_outline, 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Z.orange,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: Semantics(
                  selected: i == index,
                  button: true,
                  label: _items[i].$2,
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Icon(_items[i].$1, color: Colors.white, size: 26),
                      const SizedBox(height: 4),
                      Text(_items[i].$2, style: p(11, w: FontWeight.w500, c: Colors.white)),
                      const SizedBox(height: 6),
                      Container(height: 3, width: 54, color: i == index ? Colors.white : Colors.transparent),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

/// Figma p41 — side menu.
class ZanyDrawer extends StatelessWidget {
  const ZanyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    void go(int tab, [Widget? root]) {
      Navigator.of(context).pop();
      ShellController.go(tab, root: root);
    }

    Widget item(IconData icon, String label, VoidCallback onTap) => ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(label, style: p(14, c: Colors.white)),
          onTap: onTap,
          dense: true,
          visualDensity: const VisualDensity(vertical: -0.5),
        );

    return Drawer(
      backgroundColor: Z.teal,
      shape: const RoundedRectangleBorder(),
      width: 290,
      child: SafeArea(
        child: ListView(padding: const EdgeInsets.symmetric(vertical: 12), children: [
          item(Icons.home_outlined, 'Home', () => go(0, const HomeScreen())),
          item(Icons.school_outlined, 'Training classes', () => go(0, const TrainingScreen())),
          item(Icons.cake_outlined, 'Parties & Special Events', () => go(0, const PartiesScreen())),
          item(Icons.child_care_outlined, 'Kids Programs', () => go(0, const KidsProgramsScreen())),
          item(Icons.groups_outlined, 'Team Building', () => go(0, const TeamBuildingScreen())),
          item(Icons.event_outlined, 'Studio Events', () => go(0, const StudioEventsScreen())),
          item(Icons.edit_calendar_outlined, 'My Bookings', () => go(1, const MyBookingsScreen())),
          item(Icons.local_cafe_outlined, 'Products', () => go(0, const ShopHomeScreen())),
          item(Icons.favorite_border, 'Favorites', () => go(0, const FavoritesScreen())),
          item(Icons.receipt_long_outlined, 'My Orders', () => go(2, const MyOrdersScreen())),
          item(Icons.person_outline, 'My Profile', () => go(3, const MyProfileScreen())),
          item(Icons.settings_outlined, 'Setting', () => go(3, const SettingsScreen())),
          item(Icons.contact_phone_outlined, 'Contact Us', () => go(0, const ContactScreen())),
          item(Icons.info_outline, 'About Us', () => go(0, const AboutScreen())),
          item(Icons.notifications_none, 'Notifications', () => go(0, const NotificationsScreen())),
          item(Icons.logout, 'Logout', () async {
            final shell = shellScaffoldKey.currentContext!;
            Navigator.of(context).pop();
            final ok = await confirm(shell, 'Log out?', 'You’ll need to sign in again to see your bookings and orders.',
                yes: 'Log out', no: 'Cancel');
            if (!ok || !shell.mounted) return;
            AppScope.read(shell).logout();
            Navigator.of(shell, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SignInScreen()),
              (_) => false,
            );
          }),
        ]),
      ),
    );
  }
}
