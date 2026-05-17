import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/purchase/listof_purchase.dart';
import 'package:flutter_application_1/screens/settings/settings_main.dart';
import 'package:flutter_application_1/services/auth_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login/login_signup_page.dart';
import 'screens/history/history_section.dart';
import 'screens/adding/adding_section.dart';
import 'screens/purchase/purchase_section.dart';
import 'screens/settings/account.dart';
import 'screens/settings/display.dart';
import 'designs/themes.dart';
import 'providers/display_provider.dart';
import 'screens/notification/notification.dart';
import 'screens/inventory/home_page.dart';

// Walang Binago si Jehron
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(displaySettingsProvider);

    return MaterialApp(
      themeMode: display.themeMode,
      theme: AppTheme.lightTheme(fontFamily: display.fontFamily),
      darkTheme: AppTheme.darkTheme(fontFamily: display.fontFamily),
      // Display font size scales all text; theme uses base sizes (scale 1.0 inside ThemeData).
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(display.fontScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthGate(),
      routes: {
        '/login': (context) => LoginSignupPage(),
        '/inventory': (context) => HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/adding': (context) => AddingSectionPage(),
        '/history': (context) => HistoryPage(),
        '/purchase': (context) => PurchaseSection(),
        '/notification': (context) => NotificationPage(),
        '/logout': (context) => const AuthGate(),
        '/account': (context) => Account(),
        '/display': (context) => const Display(),
        '/purchaseList': (context) => const ListofPurchase(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
