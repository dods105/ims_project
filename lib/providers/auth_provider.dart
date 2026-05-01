import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/login/user.dart';
import '../services/session_manager.dart';
import 'profile_provider.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final userId = await SessionManager.getSavedUserId();
    final username = await SessionManager.getSavedUsername();

    if (userId != null && username != null) {
      await ref.read(profileProvider.notifier).load(userId);
      return User(id: userId, username: username, password: '');
    }
    return null;
  }

  Future<void> login(User user) async {
    await SessionManager.saveSession(user.id!, user.username);
    await ref.read(profileProvider.notifier).load(user.id!);
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await SessionManager.clearSession();
    state = const AsyncData(null);
  }

  Future<void> updateUsername(String newName) async {
    final currentUser = state.value;
    if (currentUser != null) {
      final updatedUser = User(
        id: currentUser.id,
        username: newName,
        password: '',
      );
      state = AsyncData(updatedUser);

      await SessionManager.saveSession(currentUser.id!, newName);
    }
  }

  Future<void> updatePassword(String newHashedPassword) async {
    final currentUser = state.value;
    if (currentUser != null) {
      state = AsyncData(
        User(id: currentUser.id, username: currentUser.username, password: ''),
      );
    }
  }

  Future<void> updateStateName(String newName) async {
    final currentUser = state.value;
    if (currentUser != null) {
      // update with new name but keep id
      state = AsyncData(
        User(id: currentUser.id, username: newName, password: ''),
      );
      await SessionManager.saveSession(currentUser.id!, newName);
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
