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
    final picPath = ref.watch(profileProvider);
    final cs = Theme.of(context).colorScheme;

    final username = authAsync.value?.username ?? '';

    return Scaffold(
      appBar: AppBar(title: Text("MY ACCOUNT"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: picPath != null
                      ? FileImage(File(picPath))
                      : AssetImage('assets/images/default-pfp.png')
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
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.image, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                AccountActions.showEditNameDialog(
                  context,
                  ref,
                  username,
                  authAsync.value?.id ?? 0,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    username.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.edit, size: 18, color: cs.primary),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Change password button
            SizedBox(
              width: 220,
              child: TextButton(
                style: TextButton.styleFrom(backgroundColor: cs.primary),
                onPressed: () {
                  AccountActions.showChangePasswordDialog(
                    context,
                    authAsync.value?.id ?? 0,
                  );
                },
                child: Text(
                  "CHANGE PASSWORD",
                  style: TextStyle(color: cs.surface),
                ),
              ),
            ),

            SizedBox(height: 12),

            // Logout
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
      builder: (context) => AlertDialog(
        title: Text("CHANGE USERNAME"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: "New Username",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                // Update db
                await DatabaseHelper.instance.editUsername(userId, newName);
                // Update ui
                ref.read(authProvider.notifier).updateStateName(newName);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text("SAVE"),
          ),
        ],
      ),
    );
  }

  static void showChangePasswordDialog(BuildContext context, int userId) {
    final controller = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("CHANGE PASSWORD"),
            content: TextField(
              controller: controller,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: "New Password",
                hintText: "At least 6 characters",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("CANCEL"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final newPass = controller.text;

                  if (newPass.length >= 6) {
                    // Update database pass
                    await DatabaseHelper.instance.editPassword(userId, newPass);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Password updated successfully!"),
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Password must be at least 6 characters"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text("UPDATE"),
              ),
            ],
          );
        },
      ),
    );
  }
}
