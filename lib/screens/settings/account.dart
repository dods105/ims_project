import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class Account extends ConsumerWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);
    final picPath = ref.watch(profileProvider);
    final cs = Theme.of(context).colorScheme;

    final username = authAsync.value?.username ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("MY ACCOUNT"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile picture with edit button
            Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: picPath != null
                      ? FileImage(File(picPath))
                      : const AssetImage('assets/images/default-pfp.png')
                            as ImageProvider,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(profileProvider.notifier)
                        .pickProfilePicture(authAsync.value?.id ?? 0),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.image,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Username with edit icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  username.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.edit, size: 18, color: cs.primary),
              ],
            ),
            const SizedBox(height: 24),

            // Change password button
            SizedBox(
              width: 220,
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: cs.secondary),
                onPressed: () {
                  // TODO: change password dialog
                },
                child: Text(
                  "CHANGE PASSWORD",
                  style: TextStyle(color: cs.surface),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Logout
          ],
        ),
      ),
    );
  }
}
