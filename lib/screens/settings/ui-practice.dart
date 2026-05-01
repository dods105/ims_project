import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/themes.dart';
import '../../providers/display_provider.dart';

class Practice extends ConsumerWidget {
  const Practice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(displaySettingsProvider);
    final isDark = display.themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;
    final fontScale = display.fontScale;

    final notifier = ref.read(displayProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('Practice'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // theme toggle
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: cs.outline,
              ),
              padding: const EdgeInsets.all(16),

              child: Row(
                children: [
                  Icon(Icons.dark_mode_rounded, color: cs.primary),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mode",
                        style: TextStyle(
                          fontSize: 14 * fontScale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        isDark ? 'Dark Mode' : 'Light Mode',
                        style: TextStyle(
                          fontSize: 12 * fontScale,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Switch(
                    inactiveThumbColor: cs.primary,
                    inactiveTrackColor: Colors.white,
                    value: isDark,
                    onChanged: (value) {
                      notifier.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // font size
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: cs.outline,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Size',
                    style: TextStyle(
                      fontSize: 14 * fontScale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [_FontSize()],
                  ),
                ],
              ),
            ),
            // font style
          ],
        ),
      ),
    );
  }
}

const _sizes = [
  (label: 'Small', scale: 0.85, fontSize: 18.0),
  (label: 'Medium', scale: 1.0, fontSize: 26.0),
  (label: 'Large', scale: 1.2, fontSize: 34.0),
];

class _FontSize extends StatelessWidget {
  const _FontSize({super.key});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _sizes.map((s) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: cs.surfaceVariant,
          ),
          alignment: Alignment.center,
          child: Center(
            child: Text(
              'A',
              style: TextStyle(
                fontSize: s.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
