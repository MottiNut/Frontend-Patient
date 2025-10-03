import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const _keyAuthToken = 'auth_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';

  // Keys para shared preferences (datos no sensibles)
  static const _keyRememberMe = 'remember_me';
  static const _keySavedEmail = 'saved_email';
  static const _keyBiometricEnabled = 'biometric_enabled';

  // ==================== TOKENS  ====================

  Future<void> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _keyAuthToken, value: token);
      debugPrint('✅ Auth token saved securely');
    } catch (e) {
      debugPrint('❌ Error saving auth token: $e');
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: _keyAuthToken);
    } catch (e) {
      debugPrint('❌ Error reading auth token: $e');
      return null;
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _secureStorage.write(key: _keyRefreshToken, value: token);
      debugPrint('✅ Refresh token saved securely');
    } catch (e) {
      debugPrint('❌ Error saving refresh token: $e');
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _keyRefreshToken);
    } catch (e) {
      debugPrint('❌ Error reading refresh token: $e');
      return null;
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      await _secureStorage.write(key: _keyUserId, value: userId);
    } catch (e) {
      debugPrint('❌ Error saving user ID: $e');
    }
  }

  Future<String?> getUserId() async {
    try {
      return await _secureStorage.read(key: _keyUserId);
    } catch (e) {
      debugPrint('❌ Error reading user ID: $e');
      return null;
    }
  }

  // ==================== PREFERENCIAS ====================

  Future<void> saveRememberMe(bool remember) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyRememberMe, remember);
      debugPrint('✅ Remember me preference saved: $remember');
    } catch (e) {
      debugPrint('❌ Error saving remember me: $e');
    }
  }

  Future<bool> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyRememberMe) ?? false;
    } catch (e) {
      debugPrint('❌ Error reading remember me: $e');
      return false;
    }
  }

  Future<void> saveSavedEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySavedEmail, email);
      debugPrint('✅ Email saved: $email');
    } catch (e) {
      debugPrint('❌ Error saving email: $e');
    }
  }

  Future<String?> getSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keySavedEmail);
    } catch (e) {
      debugPrint('❌ Error reading saved email: $e');
      return null;
    }
  }

  Future<void> saveBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyBiometricEnabled, enabled);
    } catch (e) {
      debugPrint('❌ Error saving biometric preference: $e');
    }
  }

  Future<bool> getBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyBiometricEnabled) ?? false;
    } catch (e) {
      debugPrint('❌ Error reading biometric preference: $e');
      return false;
    }
  }

  // ==================== LIMPIEZA ====================
  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('✅ All stored data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
    }
  }

  Future<void> clearTokens() async {
    try {
      await _secureStorage.delete(key: _keyAuthToken);
      await _secureStorage.delete(key: _keyRefreshToken);
      await _secureStorage.delete(key: _keyUserId);
      debugPrint('✅ Tokens cleared');
    } catch (e) {
      debugPrint('❌ Error clearing tokens: $e');
    }
  }

  Future<void> clearSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySavedEmail);
      await prefs.remove(_keyRememberMe);
      debugPrint('✅ Saved email cleared');
    } catch (e) {
      debugPrint('❌ Error clearing saved email: $e');
    }
  }

  // ==================== VERIFICACIÓN ====================
  Future<bool> hasActiveSession() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasSavedCredentials() async {
    final rememberMe = await getRememberMe();
    final email = await getSavedEmail();
    return rememberMe && email != null && email.isNotEmpty;
  }
}