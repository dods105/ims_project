import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/themes.dart';
import '../../providers/display_provider.dart';

//comment
const _sizes = [
  (label: 'Small', scale: 0.85, fontSize: 15.0),
  (label: 'Medium', scale: 1.0, fontSize: 20.0),
  (label: 'Large', scale: 1.2, fontSize: 34.0),
];

class Display extends ConsumerWidget {
  const Display({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(displaySettingsProvider);
    final isDark = display.themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;
    final fontScale = display.fontScale;
    final notifier = ref.read(displayProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Display'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
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
                  const Spacer(),
                  Switch(
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
            const SizedBox(height: 30),

            _FontSizeCard(
              currentScale: fontScale,
              onSelect: (newScale) => notifier.setFontScale(newScale),
            ),
          ],
        ),
      ),
    );
  }
}

class _FontSizeCard extends StatelessWidget {
  final double currentScale;
  final Function(double) onSelect;

  const _FontSizeCard({required this.currentScale, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
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
              fontSize: 14 * currentScale,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _sizes.map((s) {
              final isSelected = (currentScale - s.scale).abs() < 0.01;

              return InkWell(
                onTap: () => onSelect(s.scale),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: isSelected ? cs.primary : cs.surface,
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
          Slider(
            value: currentScale,

            min: 0.85,
            max: 1.2,

            divisions: 2,
            onChanged: (value) {
              onSelect(value);
            },
          ),
        ],
      ),
    );
  }
}
