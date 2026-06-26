// display.dart

// Layout:
// Theme Mode toggle (Switch)
// _FontSizeCard (clickable "A" buttons)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/display_provider.dart';

// The three available font size options shown as "A" buttons.
// scale = the textScaler value applied app-wide.
// fontSize = the size of the "A" preview inside the button.
const _sizes = [
  (label: 'Small', scale: 0.78, fontSize: 13.0),
  (label: 'Medium', scale: 0.88, fontSize: 17.0),
  (label: 'Large', scale: 1.02, fontSize: 26.0),
];

class Display extends ConsumerWidget {
  const Display({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(displaySettingsProvider);
    final isDark = display.themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;
    final notifier = ref.read(displayProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Display'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            //Theme Mode card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: cs.outline,
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.dark_mode_rounded, color: cs.primary),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Theme Mode",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                        isDark ? 'Dark Mode' : 'Light Mode',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Switch(
                    value: isDark,
                    onChanged: (value) {
                      // true = dark, false = light.
                      notifier.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Font Size card
            _FontSizeCard(
              currentScale: display.fontScale,
              onSelect: (newScale) => notifier.setFontScale(newScale),
            ),
          ],
        ),
      ),
    );
  }
}

// Displays three "A" buttons representing Small / Medium / Large font sizes.
//the currently active size is highlighted with the blue
class _FontSizeCard extends StatelessWidget {
  final double currentScale;
  final Function(double) onSelect;

  const _FontSizeCard({required this.currentScale, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final outerMq = MediaQuery.of(context);

    return MediaQuery(
      data: outerMq.copyWith(textScaler: TextScaler.linear(1.0)),
      child: Container(
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
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _sizes.map((s) {
                final isSelected =
                    (currentScale - s.scale).abs() < 0.05 ||
                    (s.label == 'Medium' && (currentScale - 1.0).abs() < 0.02);

                return InkWell(
                  onTap: () => onSelect(s.scale),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      //highlight the selected option with blue                      color: isSelected ? cs.primary : cs.surface,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: s.fontSize,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? cs.onPrimary : cs.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
