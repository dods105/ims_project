import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/login/user.dart';
import '../services/session_manager.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    final userId = await SessionManager.getSavedUserId();
    final username = await SessionManager.getSavedUsername();

    if (userId != null && username != null) {
      return User(id: userId, username: username, password: '');
    }
    return null;
  }

  Future<void> login(User user) async {
    await SessionManager.saveSession(user.id!, user.username);
    state = AsyncData(user);
  }

  Future<void> logout() async {
    await SessionManager.clearSession();
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
