import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/themes.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_application_1/services/auth_gate.dart';

class Account extends ConsumerStatefulWidget {
  const Account({super.key});

  @override
  ConsumerState<Account> createState() => _Account();
}

class _Account extends ConsumerState<Account> {
  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Account")),
      body: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("Go back"),
      ),
    );
  }
}
