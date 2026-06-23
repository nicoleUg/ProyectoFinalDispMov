import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const _accessTokenKey = 'jwt_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async => await _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() async => await _storage.read(key: _refreshTokenKey);

  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  static const _tableIdKey = 'scanned_table_id';
  static String? _memTableId;

  Future<void> saveTableId(String tableId) async {
    _memTableId = tableId;
    try {
      await _storage.write(key: _tableIdKey, value: tableId);
    } catch (e) {
      print('[SecureStorageService] Error al escribir tableId en secure storage: $e');
    }
  }

  Future<String?> getTableId() async {
    try {
      final val = await _storage.read(key: _tableIdKey);
      if (val != null) {
        _memTableId = val;
        return val;
      }
    } catch (e) {
      print('[SecureStorageService] Error al leer tableId de secure storage: $e');
    }
    return _memTableId;
  }

  Future<void> clearTableId() async {
    _memTableId = null;
    try {
      await _storage.delete(key: _tableIdKey);
    } catch (e) {
      print('[SecureStorageService] Error al borrar tableId de secure storage: $e');
    }
  }
}