import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import 'dart:io';

class AppBarDesign extends ConsumerWidget implements PreferredSizeWidget {
  final String page;

  const AppBarDesign({super.key, required this.page});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final name = ref.watch(authProvider).value?.username ?? '';
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      title: Row(
        children: [
          const SizedBox(width: 8),
          // store profile
          CircleAvatar(
            radius: 16,
            backgroundImage: profile != null
                ? FileImage(File(profile))
                : const AssetImage('assets/images/default-pfp.png')
                      as ImageProvider,
          ),
          //store name
          const SizedBox(width: 8),
          Text(name, style: AppTheme.bodyMedium.copyWith(letterSpacing: 0.85)),
          const Spacer(),
          Text(
            page.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 25,
              letterSpacing: 0.85,
            ),
          ),
          const Spacer(),
        ],
      ),

      // current page
    );
  }
}
