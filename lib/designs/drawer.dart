import 'package:flutter/material.dart';
import 'themes.dart';

class AppDrawer extends StatelessWidget {
  final String page;
  const AppDrawer({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isShortScreen = screenHeight < 600;

    final double avatarRadius = isShortScreen ? 36 : 60;
    final double headerVerticalPadding = isShortScreen ? 14 : 30;

    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.65,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(60),
          bottomLeft: Radius.circular(60),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(gradient: AppTheme.drawerGradientBlue),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: headerVerticalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundImage: const AssetImage(
                        'assets/images/godzilla.gif',
                      ),
                      radius: avatarRadius,
                      backgroundColor: AppTheme.primaryBlue.withValues(
                        alpha: 0.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // FittedBox prevents title from overflowing on narrow drawers
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'INVENZILLA',
                        style: AppTheme.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'inventory manager',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: Colors.white.withValues(alpha: 0.1),
                indent: 24,
                endIndent: 24,
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _NavItem(
                      icon: Icons.add_box_rounded,
                      label: 'ADD',
                      route: '/adding',
                      page: page,
                    ),
                    _NavItem(
                      icon: Icons.inventory_2_rounded,
                      label: 'INVENTORY',
                      route: '/inventory',
                      page: page,
                    ),
                    _NavItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'HISTORY',
                      route: '/history',
                      page: page,
                    ),
                    _NavItem(
                      icon: Icons.shopping_cart,
                      label: 'PURCHASE',
                      route: '/purchase',
                      page: page,
                    ),
                    _NavItem(
                      icon: Icons.notifications,
                      label: 'NOTIFICATION',
                      route: '/notification',
                      page: page,
                    ),
                  ],
                ),
              ),

              _NavItem(
                icon: Icons.settings_rounded,
                label: 'SETTINGS',
                route: '/settings',
                page: page,
              ),

              SizedBox(height: isShortScreen ? 16 : 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String page;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = page == route;

    return Padding(
      padding: const EdgeInsets.only(left: 25, top: 4, bottom: 4),
      child: InkWell(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        onTap: () {
          if (route == '/settings') {
            Navigator.pushNamed(context, route);
          } else {
            Navigator.pushReplacementNamed(context, route);
          }
        },
        child: Container(
          // Use horizontal padding that won't overflow on narrow drawers
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: active
                ? AppTheme.drawerHighlight.withOpacity(0.7)
                : AppTheme.surfaceGradient.withOpacity(0.5),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,

            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTheme.drawerText,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, size: 22, color: AppTheme.grey300),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
