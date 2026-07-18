import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    wOptions: WindowsOptions(),
    lOptions: LinuxOptions(),
    webOptions: WebOptions(
      dbName: 'drug_tracking_db',
      publicKey: 'drug_tracking_key',
    ),
  );

  static const _keyToken = 'token';
  static const _keyRole = 'role';
  static const _keyUserId = 'user_id';
  static const _keyProfileCompleted = 'profile_completed';
  static Future<void> setProfileCompleted(bool value) async {
    await _storage.write(
      key: _keyProfileCompleted,
      value: value.toString(),
    );
  }
  static Future<void> saveLoginData({
    required String token,
    required String role,
    required String userId,
    required bool profileCompleted,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _keyToken, value: token),
        _storage.write(key: _keyRole, value: role),
        _storage.write(key: _keyUserId, value: userId),
        _storage.write(
          key: _keyProfileCompleted,
          value: profileCompleted.toString(),
        ),
      ]);
    } catch (e) {
      debugPrint('[AuthStorage] saveLoginData error: $e');
      rethrow;
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (e) {
      debugPrint('[AuthStorage] getToken error: $e');
      return null;
    }
  }

  static Future<String?> getRole() async {
    try {
      return await _storage.read(key: _keyRole);
    } catch (e) {
      debugPrint('[AuthStorage] getRole error: $e');
      return null;
    }
  }

  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      debugPrint('[AuthStorage] getUserId error: $e');
      return null;
    }
  }

  static Future<bool> isProfileCompleted() async {
    try {
      final val = await _storage.read(key: _keyProfileCompleted);
      return val == 'true';
    } catch (e) {
      debugPrint('[AuthStorage] isProfileCompleted error: $e');
      return false;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('[AuthStorage] isLoggedIn error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('[AuthStorage] logout error: $e');
      try {
        await Future.wait([
          _storage.delete(key: _keyToken),
          _storage.delete(key: _keyRole),
          _storage.delete(key: _keyUserId),
          _storage.delete(key: _keyProfileCompleted),
        ]);
      } catch (fallbackError) {
        debugPrint('[AuthStorage] logout fallback error: $fallbackError');
      }
    }
  }

  static Future<Map<String, String?>> getAllData() async {
    try {
      return {
        'token': await getToken(),
        'role': await getRole(),
        'user_id': await getUserId(),
        'profile_completed': (await isProfileCompleted()).toString(),
      };
    } catch (e) {
      debugPrint('[AuthStorage] getAllData error: $e');
      return {};
    }
  }
}
