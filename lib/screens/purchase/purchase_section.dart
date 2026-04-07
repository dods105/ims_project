import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';

class PurchasePage extends ConsumerWidget {
  const PurchasePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('PURCHASE', style: AppTheme.displayLarge)),
      endDrawer: const AppDrawer(page: '/purchase'),
      body: Center(child: Text('Purchase Page')),
    );
  }
}
