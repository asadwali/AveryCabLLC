import 'package:avery_cab_app/controllers/auth.controller.dart';
import 'package:avery_cab_app/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userEmail = '';

  User? _user;

  List<dynamic>? _users;

  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  bool get isAdmin => _userEmail == Constants.admin_email;

  User? get user => _user;

  List<dynamic>? get users => _users;

  AuthProvider() {
    init();
  }

  void init() async {
    final User? user = AuthController.getAuthUser();
    
    if (user != null) {
      _userEmail = user.email ?? '';
      _isLoggedIn = true;

      _user = user;

      notifyListeners();
    }

    final users = await AuthController.getAuthUsers();
    _users = users;

    notifyListeners();
  }

  Future<List<dynamic>> getUsers() async{
    final users = await AuthController.getAuthUsers();

    return users;
  }

  /// Returns null on success, error message on failure.
  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Please fill in all fields';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    try {
      final User? user = await AuthController.login(email, password);

      if (user != null) {
        _isLoggedIn = true;
        _userEmail = email;

        _user = user;

        notifyListeners();
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Please fill in all fields';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    try {  
      final User? user = await AuthController.register(
        email,
        password,
      );

      if (user == null) {
        _isLoggedIn = true;
        _userEmail = email;
        notifyListeners();
      }

      return null;
    } catch (e) {
      return e.toString();
    }


  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = '';

    AuthController.logout();
    notifyListeners();
  }
}
