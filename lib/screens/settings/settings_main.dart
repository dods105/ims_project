import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/themes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/display_provider.dart';
import 'package:flutter_application_1/services/auth_gate.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authProvider);
    final display = ref.watch(displaySettingsProvider);
    final s = display.fontScale;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.brandBlue,
        foregroundColor: AppTheme.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SETTINGS',
          style: TextStyle(
            color: AppTheme.white,
            fontSize: 22 * s,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _SettingsItem(
            icon: Icons.smartphone_rounded,
            label: 'MY ACCOUNT',
            route: '/account',
            fontScale: s,
          ),
          const SizedBox(height: 12),
          _SettingsItem(
            icon: Icons.brightness_6_rounded,
            label: 'DISPLAY',
            route: '/display',
            fontScale: s,
          ),
          const SizedBox(height: 12),
          _SettingsItem(
            icon: Icons.translate_rounded,
            label: 'LANGUAGE',
            route: '/language',
            fontScale: s,
          ),
          const SizedBox(height: 12),
          _SettingsItem(
            icon: Icons.volume_up_rounded,
            label: 'SOUND',
            route: '/sound',
            fontScale: s,
          ),
          const SizedBox(height: 12),
          _SettingsItem(
            icon: Icons.menu_book_rounded,
            label: 'MANUAL',
            route: '/manual',
            fontScale: s,
          ),

          const SizedBox(height: 48),

          Center(
            child: SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandBlue,
                  foregroundColor: AppTheme.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const AuthGate()),
                      (route) => false,
                    );
                  }
                },
                child: Text(
                  'LOGOUT',
                  style: TextStyle(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final double fontScale;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderDefault),
          ),
          child: Row(
            children: [
              // Icon circle
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.blueLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.brandBlue, size: 20),
              ),
              const SizedBox(width: 14),
              // Label
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14 * fontScale,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.brandBlue,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Chevron
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
