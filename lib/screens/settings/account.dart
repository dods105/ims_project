// account.dart

// Flow:
// - reads authProvider for username / userId
// - reads profileProvider for the current avatar path
// - tapping the avatar calls profileProvider.pickProfilePicture()
// - tapping the username calls AccountActions.showEditNameDialog()
//- tapping CHANGE PASSWORD calls AccountActions.showChangePasswordDialog()

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

    // just a guard if ever there is an error and user becomes null to avoid crash
    if (userId == null) {
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
  //shows dialog to rename the user.
  //checks uniqueness in the DB before saving so two accounts sharing the same username never happen
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
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newName = controller.text.trim();

              //skip the save if the field is empty or unchanged.
              if (newName.isEmpty || newName == currentName) {
                Navigator.pop(context);
                return;
              }
              // Check uniqueness before saving.
              final taken = await DatabaseHelper.instance.usernameExists(
                newName,
              );
              if (taken) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('That username is already taken'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }
              // store new username to the db
              await DatabaseHelper.instance.editUsername(userId, newName);
              // updateUsername across the app UI
              await ref.read(authProvider.notifier).updateUsername(newName);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("SAVE"),
          ),
        ],
      ),
    );
  }

  //shows a dialog to set a new password.
  static void showChangePasswordDialog(
    BuildContext context,
    WidgetRef ref,
    int userId,
  ) {
    final controller = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
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
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),

            // update password button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final newPass = controller.text;

                //check if length is at least 6, if not, dont allow change
                if (newPass.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // calls editPassword in the database to hash the new password and save to db
                await DatabaseHelper.instance.editPassword(userId, newPass);
                // update the password throught the app, especially the one stored in sharedpref
                await ref.read(authProvider.notifier).updatePassword();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
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
