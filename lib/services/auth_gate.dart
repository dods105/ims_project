// auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login/login_signup_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/inventory/home_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //watch the auth state(user activity) and this rebuilds automatically when user logs in or out
    final authState = ref.watch(authProvider);

    return authState.when(
      //while the auth provider is still loading, show a spinner
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      //if there is an error retrieving the user data, show an error message
      error: (e, _) =>
          const Scaffold(body: Center(child: Text('Something Went Wrong'))),
      //user != null
      // a session was found (user logged in the app previously) or user login/sign up in the log in screen was successful so route to the inventory page.,
      data: (user) {
        if (user != null) {
          return const HomePage();
        }
        return const LoginSignupPage();
      },
    );
  }
}
