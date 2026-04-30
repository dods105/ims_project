import 'package:flutter/material.dart';
import 'package:flutter_application_1/designs/appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../designs/drawer.dart';
import '../../designs/appbar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    //fakk jehron
    return Scaffold(
      appBar: AppBarDesign(page: "INVENTORY"),
      endDrawer: const AppDrawer(page: '/inventory'),
      backgroundColor: colorScheme.background,
      body: Center(
        child: Text(
          "Inventory Edited for demo!",
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}
