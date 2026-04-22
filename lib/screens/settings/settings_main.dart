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
      appBar: AppBar(backgroundColor: Colors.blueAccent),
      body: Expanded(
        child: ListView(
          //padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Container(
              color: AppTheme.primaryBlue.withOpacity(0.1),

              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Center(
                  child: Text('SETTINGS', style: AppTheme.displayLarge),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: SettingsItems(label: 'MY ACCOUNT', route: '/account'),
            ),

            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: SettingsItems(label: 'DISPLAY', route: '/display'),
            ),

            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: SettingsItems(label: 'LANGUAGE', route: '/language'),
            ),

            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: SettingsItems(label: 'SOUND', route: '/sound'),
            ),

            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: SettingsItems(label: 'MANUAL', route: '/manual'),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'LOGOUT',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthGate()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsItems extends StatelessWidget {
  final String label;
  final String route;

  const SettingsItems({super.key, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppTheme.primaryBlue.withOpacity(0.1),
        ),

        child: Padding(
          padding: EdgeInsets.all(15),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
