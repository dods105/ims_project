import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/themes.dart';
import '../../designs/drawer.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_application_1/services/auth_gate.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: Text('SETTINGS', style: AppTheme.displayLarge)),
      endDrawer: AppDrawer(page: '/settings'),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          //padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            SettingsItems(label: 'My Account'),
            const SizedBox(height: 12),
            SettingsItems(label: 'Display'),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                await ref.read(authProvider.notifier).logout();

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                    (route) => false,
                  );
                }
              },
              child: SettingsItems(label: 'Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsItems extends StatelessWidget {
  final String label;

  const SettingsItems({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        color: AppTheme.primaryBlue,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Text(label, style: AppTheme.drawerText),
        ),
      ),
    );
  }
}
