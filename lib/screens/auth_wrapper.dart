import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'exercise_screens.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _showSignUp = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    _listenToAuthChanges();
  }

  Future<void> _checkAuthState() async {
    final user = SupabaseService.currentUser;
    setState(() {
      _isAuthenticated = user != null;
      _isLoading = false;
    });
  }

  void _listenToAuthChanges() {
    SupabaseService.authStateChanges.listen((authState) {
      final user = authState.session?.user;
      if (mounted) {
        setState(() {
          _isAuthenticated = user != null;
        });
      }
    });
  }

  void _handleSignInSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _handleSignUpSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _toggleAuthMode() {
    setState(() {
      _showSignUp = !_showSignUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const ExerciseSelectScreen();
    }

    if (_showSignUp) {
      return SignUpScreen(
        onSignUpSuccess: _handleSignUpSuccess,
        onNavigateToSignIn: _toggleAuthMode,
      );
    }

    return SignInScreen(
      onSignInSuccess: _handleSignInSuccess,
      onNavigateToSignUp: _toggleAuthMode,
    );
  }
}
