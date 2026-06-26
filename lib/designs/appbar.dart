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
    final profileAsync = ref.watch(profileProvider);
    final name = ref.watch(authProvider).value?.username ?? '';

    return AppBar(
      title: Row(
        children: [
          const SizedBox(width: 8),
          // store profile
          // gets the profile pic if there is any, if none, get the dafault
          profileAsync.when(
            data: (profilePath) => CircleAvatar(
              radius: 16,
              backgroundImage: profilePath != null && profilePath.isNotEmpty
                  ? FileImage(File(profilePath))
                  : const AssetImage('assets/images/default-pfp.png')
                        as ImageProvider,
            ),
            // While loading the path from SQLite, show a default profile
            loading: () => const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/default-pfp.png'),
            ),

            error: (_, __) => const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/default-pfp.png'),
            ),
          ),
          //store name
          const SizedBox(width: 8),
          Text(name, style: AppTheme.bodyMedium.copyWith(letterSpacing: 0.85)),
          const Spacer(),
          Text(
            page.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 0.85,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
