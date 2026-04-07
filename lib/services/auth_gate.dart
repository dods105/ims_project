import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login/login_signup_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/inventory/home_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          const Scaffold(body: Center(child: Text('Something Went Wrong'))),
      data: (user) {
        if (user != null) {
          return const HomePage();
        }
        return const LoginSignupPage();
      },
    );
  }
}
