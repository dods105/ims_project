import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';

class AddingSectionPage extends ConsumerWidget {
  const AddingSectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('ADD PRODUCTS', style: AppTheme.displayLarge)),
      endDrawer: const AppDrawer(page: '/adding'),
      body: TextButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/inventory'),
        child: Text('Go Back to inventory'),
      ),
    );
  }
}
