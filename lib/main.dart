import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/inventory/home_page.dart';
import 'package:flutter_application_1/screens/settings/settings_main.dart';
import 'package:flutter_application_1/screens/settings/ui-practice.dart';
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
      theme: AppTheme.lightTheme(
        fontFamily: display.fontFamily,
        fontScale: display.fontScale,
      ),
      darkTheme: AppTheme.darkTheme(
        fontFamily: display.fontFamily,
        fontScale: display.fontScale,
      ),
      home: const AuthGate(), // dont delete.
      // home: const HomePage(), //uncomment for inventrory page
      //home: const AddingSectionPage(), //uncomment for adding page
      // home: PurchasePage(), //uncomment for purchase page
      routes: {
        '/login': (context) => LoginSignupPage(),
        '/inventory': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/adding': (context) => AddingSectionPage(),
        '/history': (context) => HistoryPage(),
        '/purchase': (context) => purchase_section(),
        '/notification': (context) => NotificationPage(),
        '/logout': (context) => const AuthGate(),
        '/account': (context) => Account(),
        '/display': (context) => const Display(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
