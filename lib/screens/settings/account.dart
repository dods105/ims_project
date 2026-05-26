// account.dart

// Flow:
//   Account.build()
//     reads authProvider for username / userId
//     reads profileProvider for the current avatar path
//     tapping the avatar calls profileProvider.pickProfilePicture()
//     tapping the username calls AccountActions.showEditNameDialog()
//     tapping CHANGE PASSWORD calls AccountActions.showChangePasswordDialog()
//
// AccountActions.showEditNameDialog()
//   validates non-empty and uniqueness
//   DatabaseHelper.editUsername() which lead to authProvider.updateUsername()
//
// AccountActions.showChangePasswordDialog()
//   validates min 6 chars
//   DatabaseHelper.editPassword() which lead to authProvider.updatePassword()

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../database/database_helper.dart';

class Account extends ConsumerWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authProvider);

    final picPath = ref.watch(profileProvider).value;
    final cs = Theme.of(context).colorScheme;

    final user = authAsync.value;
    final username = user?.username ?? '';
    final userId = user?.id;

    if (userId == null) {
      // Shouldn't happen — AuthGate prevents reaching this screen when
      // logged out — but guard anyway to avoid using id 0.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("MY ACCOUNT"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: picPath != null
                      ? FileImage(File(picPath)) as ImageProvider
                      : const AssetImage('assets/images/default-pfp.png'),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(profileProvider.notifier)
                        .pickProfilePicture(userId),
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

            GestureDetector(
              onTap: () => AccountActions.showEditNameDialog(
                context,
                ref,
                username,
                userId,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    username.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit, size: 18, color: cs.primary),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: 220,
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: cs.primary),
                onPressed: () => AccountActions.showChangePasswordDialog(
                  context,
                  ref,
                  userId,
                ),
                child: Text(
                  "CHANGE PASSWORD",
                  style: TextStyle(color: cs.surface),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountActions {
  static void showEditNameDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    int userId,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("CHANGE USERNAME"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "New Username",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == currentName) {
                Navigator.pop(ctx);
                return;
              }
              // Check uniqueness before saving.
              final taken = await DatabaseHelper.instance.usernameExists(
                newName,
              );
              if (taken) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('That username is already taken'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }
              await DatabaseHelper.instance.editUsername(userId, newName);
              // updateUsername (not the removed updateStateName).
              await ref.read(authProvider.notifier).updateUsername(newName);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }

  static void showChangePasswordDialog(
    BuildContext context,
    WidgetRef ref,
    int userId,
  ) {
    final controller = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("CHANGE PASSWORD"),
          content: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: "New Password",
              hintText: "At least 6 characters",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => obscure = !obscure),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final newPass = controller.text;
                if (newPass.length < 6) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                await DatabaseHelper.instance.editPassword(userId, newPass);
                await ref.read(authProvider.notifier).updatePassword();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text("Password updated successfully!"),
                    ),
                  );
                }
              },
              child: const Text("UPDATE"),
            ),
          ],
        ),
      ),
    );
  }
}
