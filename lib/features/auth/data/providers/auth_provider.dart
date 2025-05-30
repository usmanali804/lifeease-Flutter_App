import 'package:flutter/material.dart';
import '../../../../core/auth/auth_service.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required AuthService authService,
    required UserService userService,
  }) : _authService = authService,
       _userService = userService;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.login(email, password);
      await _loadUserProfile();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      await _userService.register(name, email, password);
      await signIn(email, password);

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.logout();
      _currentUser = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _userService.getCurrentUser();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? profileImage,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_currentUser == null) throw Exception('No user logged in');

      final updatedUser = await _userService.updateProfile(
        userId: _currentUser!.id,
        name: name,
        email: email,
        profileImage: profileImage,
      );

      _currentUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
