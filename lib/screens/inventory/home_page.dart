import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../designs/drawer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "INVENTORY",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
      ),
      endDrawer: const AppDrawer(page: '/inventory'),
      backgroundColor: colorScheme.background,
      body: Center(
        child: Text(
          "Inventory Section!",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}
