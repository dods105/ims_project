import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes.dart';
import '../providers/auth_provider.dart';

class AppBarDesign extends ConsumerWidget implements PreferredSizeWidget {
  final String page;

  const AppBarDesign({super.key, required this.page});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final profile = ref.watch(profileProvider);
    final name = ref.watch(authProvider);

    return AppBar(
      leading: Row(
        children: [
          const SizedBox(width: 8),
          //store profile
          //CircleAvatar(
          //radius: 16,
          //       backgroundImage: profile != null
          //  ? FileImage(File(profile))
          //: const AssetImage('assets/images/default_profile.png')
          //    as ImageProvider,
          //),
          //store name
          const SizedBox(width: 8),
          Text(
            name.value?.username ?? '',
            style: AppTheme.subtitleLight.copyWith(fontSize: 12),
          ),
        ],
      ),
      // current page
      title: Text(page.toUpperCase(), style: AppTheme.displayMedium),
      centerTitle: true,
    );
  }
}
