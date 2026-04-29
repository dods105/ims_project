import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../designs/drawer.dart';
import '../../designs/themes.dart';
import '../../designs/appbar.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBarDesign(page: 'Notification'),
      endDrawer: const AppDrawer(page: '/notification'),
      body: Center(child: Text('Notification Page')),
    );
  }
}
