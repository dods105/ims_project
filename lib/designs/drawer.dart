import 'package:flutter/material.dart';
import 'themes.dart';

class AppDrawer extends StatelessWidget {
  final String page;
  const AppDrawer({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.60,
      shape: RoundedRectangleBorder(
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
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: const AssetImage(
                        'assets/images/godzilla.gif',
                      ),
                      radius: 60,
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.2),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'INVENZILLA',
                      style: AppTheme.pageTitleLight.copyWith(
                        fontSize: 20,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'inventory manager',
                      style: AppTheme.subtitleLight.copyWith(
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.white.withOpacity(0.1),
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
                  ],
                ),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'SETTINGS',
                route: '/settings',
                page: page,
              ),
              const SizedBox(height: 40),
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
    //final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    //print(currentRoute);
    final bool active = page == route;

    return Padding(
      padding: const EdgeInsets.only(left: 25, top: 4, bottom: 4),
      child: InkWell(
        onTap: () => Navigator.pushReplacementNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
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
              Text(label, style: AppTheme.drawerText),
              const SizedBox(width: 14),
              Icon(icon, size: 22, color: AppTheme.grey300),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
