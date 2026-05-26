// login_signup_page.dart
//handles both login and new account creation.
//
// On login mode:
//   1. User enters username + password
//   2. _handleSubmit() validates input (validate username and password)
//   3. DatabaseHelper.checkUser() checks credentials if exists
//   4. On success: authProvider.login() - AuthGate redirects to HomePage
//
// On sign-up mode:
//   1. User enters username + password
//   2. _handleSubmit() validates, then checks username uniqueness with DatabaseHelper.instance.usernameExists(username);
//   3. DatabaseHelper.createUser() inserts the new record
//   4. logs the new user in

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database_helper.dart';
import '../../models/login/user.dart';
import '../../designs/themes.dart';
import '../../services/session_manager.dart';

class LoginSignupPage extends ConsumerStatefulWidget {
  const LoginSignupPage({super.key});

  @override
  ConsumerState<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends ConsumerState<LoginSignupPage> {
  bool isLoginMode = true;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // called when user clicks login/sign up button
  Future<void> _handleSubmit() async {
    if (_isLoading) return;
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    String? usernameError = validateUsername(username);
    String? passwordError = validatePassword(password);

    if (usernameError != null || passwordError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(usernameError ?? passwordError!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (isLoginMode) {
        final user = await DatabaseHelper.instance.checkUser(
          username,
          password,
        );
        if (user != null) {
          if (mounted) await ref.read(authProvider.notifier).login(user);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid username or password'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        final exists = await DatabaseHelper.instance.usernameExists(username);
        if (exists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Username already exists'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          final newUser = User(username: username, password: password);
          final createdUser = await DatabaseHelper.instance.createUser(newUser);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Account created successfully!'),
                backgroundColor: AppTheme.primaryBlue,
              ),
            );
            await ref.read(authProvider.notifier).login(createdUser);
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // check if password is atleast 6 in length
  //if empty password or less than 6, return an error
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  //check if username field is empty, if empty, return an error
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your username';
    return null;
  }

  void _toggleMode() {
    setState(() {
      isLoginMode = !isLoginMode;
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  Future<String?> _getLastUserProfilePic() async {
    //Check who logged in last
    final lastId = await SessionManager.getLastLoggedInUserId();
    if (lastId == null) return null;

    //Fetch their picture path from SQLite
    return await DatabaseHelper.instance.getProfilePicById(lastId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // get last user profile pic and display
              FutureBuilder<String?>(
                future: isLoginMode
                    ? _getLastUserProfilePic()
                    : Future.value(null),
                builder: (context, snapshot) {
                  final imagePath = snapshot.data;

                  // Decide the image source dynamically
                  ImageProvider avatarImage = const AssetImage(
                    'assets/images/default-pfp.png',
                  );
                  if (isLoginMode &&
                      imagePath != null &&
                      imagePath.isNotEmpty) {
                    final file = File(imagePath);
                    if (file.existsSync()) {
                      avatarImage = FileImage(file);
                    }
                  }

                  return CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.deepPurpleAccent,
                    child: CircleAvatar(
                      radius: 75,
                      backgroundColor: const Color.fromARGB(192, 229, 229, 242),
                      backgroundImage: avatarImage,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(
                isLoginMode ? 'Welcome Back!' : 'Welcome',
                textAlign: TextAlign.center,
                style: AppTheme.displayLarge,
              ),
              const SizedBox(height: 20),

              // username textfield
              Center(
                child: SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      fillColor: const Color.fromARGB(
                        160,
                        196,
                        192,
                        215,
                      ).withOpacity(0.5),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // password textfield
              Center(
                child: SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      fillColor: const Color.fromARGB(
                        160,
                        196,
                        192,
                        215,
                      ).withOpacity(0.5),
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              Center(
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isLoginMode ? 'Login' : 'Sign Up',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                  ),
                ),
              ),
              // switch between log in and sign up
              TextButton(
                onPressed: _toggleMode,
                style: TextButton.styleFrom(minimumSize: const Size(100, 40)),
                child: Text(
                  isLoginMode
                      ? "Don't have an account? Sign Up"
                      : 'Already have an account? Login',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
