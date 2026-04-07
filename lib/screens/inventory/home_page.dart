import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text("INVENTORY", style: AppTheme.displayLarge)),
      endDrawer: const AppDrawer(page: '/inventory'),
      body: Center(child: Text('${user?.id}')),
    );
  }
}
