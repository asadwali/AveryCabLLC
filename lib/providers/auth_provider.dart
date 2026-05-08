import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userEmail = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;

  /// Returns null on success, error message on failure.
  String? login(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return 'Please fill in all fields';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    // Demo: accept any well-formed credentials
    _isLoggedIn = true;
    _userEmail = email;
    notifyListeners();
    return null;
  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = '';
    notifyListeners();
  }
}
