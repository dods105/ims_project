import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../designs/themes.dart';
import '../../providers/display_provider.dart';

class Display extends ConsumerWidget {
  const Display({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(displaySettingsProvider);
    final notifier = ref.read(displayProvider.notifier);
    final isDark = display.themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: AppTheme.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'DISPLAY',
          style: TextStyle(
            color: cs.onPrimary,
            fontSize: 22 * display.fontScale,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _SectionCard(
            child: _ModeRow(
              isDark: isDark,
              fontScale: display.fontScale,
              onToggle: (val) =>
                  notifier.setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
            ),
          ),

          const SizedBox(height: 20),

          _SectionLabel(text: 'FONT SIZE', fontScale: display.fontScale),
          const SizedBox(height: 10),
          _SectionCard(
            child: _FontSizeSection(
              currentScale: display.fontScale,
              onChanged: notifier.setFontScale,
            ),
          ),

          const SizedBox(height: 20),

          _SectionLabel(text: 'FONT STYLE', fontScale: display.fontScale),
          const SizedBox(height: 10),
          _SectionCard(
            child: _FontStyleSection(
              currentFont: display.fontFamily,
              fontScale: display.fontScale,
              onChanged: notifier.setFontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

//
class _ModeRow extends StatelessWidget {
  final bool isDark;
  final double fontScale;
  final ValueChanged<bool> onToggle;

  const _ModeRow({
    required this.isDark,
    required this.fontScale,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: cs.primary),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Mode",
                style: TextStyle(
                  fontSize: 14 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                isDark ? "Dark Mode" : "Light Mode",
                style: TextStyle(
                  fontSize: 12 * fontScale,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        Switch(value: isDark, onChanged: onToggle),
      ],
    );
  }
}

const _sizes = [
  (label: 'Small', scale: 0.85, fontSize: 18.0),
  (label: 'Medium', scale: 1.0, fontSize: 26.0),
  (label: 'Large', scale: 1.2, fontSize: 34.0),
];

class _FontSizeSection extends StatelessWidget {
  final double currentScale;
  final ValueChanged<double> onChanged;

  const _FontSizeSection({required this.currentScale, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _sizes.map((s) {
            final selected = (currentScale - s.scale).abs() < 0.05;
            return GestureDetector(
              onTap: () => onChanged(s.scale),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.blueLight
                      : AppTheme.inputBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? AppTheme.brandBlue
                        : AppTheme.borderDefault,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontSize: s.fontSize,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppTheme.brandBlue
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                'A',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Slider(
                  value: currentScale,
                  min: 0.80,
                  max: 1.25,
                  divisions: 9,
                  activeColor: AppTheme.brandBlue,
                  inactiveColor: AppTheme.borderDefault,
                  onChanged: onChanged,
                ),
              ),
              Text(
                'A',
                style: TextStyle(
                  fontSize: 20,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _sizes.map((s) {
              final selected = (currentScale - s.scale).abs() < 0.05;
              return SizedBox(
                width: 88,
                child: Center(
                  child: Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: selected ? AppTheme.brandBlue : AppTheme.textMuted,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FontStyleSection extends StatelessWidget {
  final String currentFont;
  final double fontScale;
  final ValueChanged<String> onChanged;

  const _FontStyleSection({
    required this.currentFont,
    required this.fontScale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: AppTheme.availableFonts.map((font) {
        final isSelected = font == currentFont;

        return ListTile(
          onTap: () => onChanged(font),
          title: Text(
            font,
            style: TextStyle(
              fontFamily: _mapFont(font),
              fontSize: 14 * fontScale,
              color: cs.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: isSelected ? Icon(Icons.check, color: cs.primary) : null,
        );
      }).toList(),
    );
  }

  String? _mapFont(String name) {
    switch (name) {
      case 'Roboto':
        return 'Roboto';
      case 'Times New Roman':
        return 'Playfair Display';
      case 'Arial':
        return 'Source Sans 3';
      case 'Cambria':
        return 'Lora';
      default:
        return null;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderDefault),
      ),
      padding: const EdgeInsets.all(14),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final double fontScale;

  const _SectionLabel({required this.text, required this.fontScale});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12 * fontScale,
          fontWeight: FontWeight.bold,
          color: cs.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
