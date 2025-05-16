import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for managing authentication
class AuthService extends ChangeNotifier {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  
  final FlutterSecureStorage _secureStorage;
  
  bool _isLoggedIn = false;
  String? _userId;
  String? _userEmail;
  String? _userName;
  
  AuthService({FlutterSecureStorage? secureStorage}) 
      : _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    // Load saved auth state on initialization
    _loadAuthState();
  }
  
  /// Check if the user is logged in
  bool get isLoggedIn => _isLoggedIn;
  
  /// Get the user ID
  String? get userId => _userId;
  
  /// Get the user email
  String? get userEmail => _userEmail;
  
  /// Get the user name
  String? get userName => _userName;
  
  /// Load the saved authentication state from secure storage
  Future<void> _loadAuthState() async {
    try {
      final isLoggedInStr = await _secureStorage.read(key: _isLoggedInKey);
      _isLoggedIn = isLoggedInStr == 'true';
      
      if (_isLoggedIn) {
        _userId = await _secureStorage.read(key: _userIdKey);
        _userEmail = await _secureStorage.read(key: _userEmailKey);
        _userName = await _secureStorage.read(key: _userNameKey);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading auth state: $e');
    }
  }
  
  /// Simulate login with email and password
  /// This is a placeholder for Dynamic SDK integration
  Future<bool> login({required String email, required String password}) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, any email/password combination works
      _isLoggedIn = true;
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _userEmail = email;
      _userName = email.split('@').first;
      
      // Save auth state
      await _secureStorage.write(key: _isLoggedInKey, value: 'true');
      await _secureStorage.write(key: _userIdKey, value: _userId);
      await _secureStorage.write(key: _userEmailKey, value: _userEmail);
      await _secureStorage.write(key: _userNameKey, value: _userName);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }
  
  /// Simulate login with social provider
  /// This is a placeholder for Dynamic SDK integration
  Future<bool> loginWithSocial({required String provider}) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, any provider works
      _isLoggedIn = true;
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _userEmail = '$provider.user@example.com';
      _userName = '${provider.capitalize()}User';
      
      // Save auth state
      await _secureStorage.write(key: _isLoggedInKey, value: 'true');
      await _secureStorage.write(key: _userIdKey, value: _userId);
      await _secureStorage.write(key: _userEmailKey, value: _userEmail);
      await _secureStorage.write(key: _userNameKey, value: _userName);
      
      notifyListeners();
      return true;
    } catch (e) {
      print('Error logging in with $provider: $e');
      return false;
    }
  }
  
  /// Logout the user
  Future<void> logout() async {
    try {
      _isLoggedIn = false;
      _userId = null;
      _userEmail = null;
      _userName = null;
      
      // Clear auth state
      await _secureStorage.delete(key: _isLoggedInKey);
      await _secureStorage.delete(key: _userIdKey);
      await _secureStorage.delete(key: _userEmailKey);
      await _secureStorage.delete(key: _userNameKey);
      
      notifyListeners();
    } catch (e) {
      print('Error logging out: $e');
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
