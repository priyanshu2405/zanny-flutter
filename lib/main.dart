import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/auth.dart';
import 'state.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  runApp(ZanyApp(state: AppState()));
}

class ZanyApp extends StatelessWidget {
  final AppState state;
  const ZanyApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) => AppScope(
        notifier: state,
        child: MaterialApp(
          title: 'Zany Pottery & Glass',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          home: const SplashScreen(),
        ),
      );
}
