import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('HISTORY', style: AppTheme.displayLarge)),
      endDrawer: const AppDrawer(page: '/history'),
      body: Center(child: Text('History Page')),
    );
  }
}
