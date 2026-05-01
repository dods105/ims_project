import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/themes.dart';
import '../../providers/display_provider.dart';

const _sizes = [
  (label: 'Small', scale: 0.85, fontSize: 18.0),
  (label: 'Medium', scale: 1.0, fontSize: 26.0),
  (label: 'Large', scale: 1.2, fontSize: 34.0),
];

class Practice extends ConsumerWidget {
  const Practice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Assuming your provider returns a state with fontScale and themeMode
    final display = ref.watch(displaySettingsProvider);
    final isDark = display.themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;
    final fontScale = display.fontScale;
    final notifier = ref.read(displayProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Practice'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Theme Toggle Card
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: cs.surfaceVariant.withOpacity(
                  0.3,
                ), // Changed for better visibility
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

            // Font Size Selection Card
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
        color: cs.surfaceVariant.withOpacity(0.3),
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
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _sizes.map((s) {
              final isSelected = currentScale == s.scale;

              return InkWell(
                onTap: () => onSelect(s.scale),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // Highlight the container if selected
                    color: isSelected ? cs.primaryContainer : cs.surfaceVariant,
                    border: isSelected
                        ? Border.all(color: cs.primary, width: 2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontSize: s.fontSize,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? cs.onPrimaryContainer
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
