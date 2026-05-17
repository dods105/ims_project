import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database_helper.dart';
import '../../models/login/user.dart';
import '../../designs/themes.dart';

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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /*
  saves user information to the database
  and retrieves user info from the database
   */
  Future<void> _handleSubmit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // is the username empty?
    String? usernameError = validateUsername(username);

    //is the password empty? or is it less than 6 in length?
    String? passwordError = validatePassword(password);

    // if username or password condtions are not satisfied,
    // display error and do not sign up/ log in
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

    if (isLoginMode) {
      /*
      if user clicks log in
      verify if username and password exist in the Db
      proceed to log the user

      if not, displaye error
     */
      final user = await DatabaseHelper.instance.checkUser(username, password);
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
      /*
        Sign in
       */
      final exists = await DatabaseHelper.instance.usernameExists(username);
      if (exists) {
        /**if name exist tell the user, and do not proceed with account creation */
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Username already exists'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        /**
         * username does not exist in the databse yet, proceed to create an account
         */
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
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

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

  @override
  Widget build(BuildContext context) {
    final picPath = ref.watch(profileProvider);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile
              CircleAvatar(
                radius: 80,
                backgroundColor: Colors.deepPurpleAccent,
                child: CircleAvatar(
                  radius: 75,
                  backgroundColor: const Color.fromARGB(192, 229, 229, 242),
                  backgroundImage: (!isLoginMode || picPath == null)
                      ? const AssetImage('assets/images/default-pfp.png')
                      : FileImage(File(picPath)) as ImageProvider,
                ),
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

              // button -> log in or sign up
              Center(
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      isLoginMode ? 'Login' : 'Sign Up',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
