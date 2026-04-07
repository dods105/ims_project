import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/inventory/home_page.dart';
import 'package:flutter_application_1/screens/settings/settings_main.dart';
import 'package:flutter_application_1/services/auth_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login/login_signup_page.dart';
import 'screens/history/history_section.dart';
import 'screens/adding/adding_section.dart';
import 'screens/purchase/purchase_section.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const AuthGate(),
      routes: {
        '/login': (BuildContext context) => LoginSignupPage(),
        '/inventory': (BuildContext context) => HomePage(),
        '/settings': (BuildContext context) => SettingsPage(),
        '/adding': (BuildContext context) => AddingSectionPage(),
        '/history': (BuildContext context) => HistoryPage(),
        '/purchase': (BuildContext context) => PurchasePage(),
        '/logout': (BuildContext context) => const AuthGate(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
