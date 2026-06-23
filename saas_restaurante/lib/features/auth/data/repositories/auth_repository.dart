import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../Core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  AuthRepository(this.apiClient, this.secureStorage);

  Future<void> register(String email, String password, String name) async {
    try {
      await apiClient.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final token = response.data['access_token'];

      await secureStorage.write(key: 'jwt_token', value: token);
      
    } catch (e) {
      throw Exception('Credenciales inválidas');
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await secureStorage.read(key: 'jwt_token');
    return token != null;
  }

  Future<UserModel?> getLoggedInUser() async {
    final token = await secureStorage.read(key: 'jwt_token');
    if (token == null) return null;
    return _getUserFromToken(token);
  }

  UserModel? _getUserFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decodedStr = utf8.decode(base64Url.decode(normalized));
      final decodedJson = json.decode(decodedStr);
      return UserModel(
        id: decodedJson['sub']?.toString() ?? '',
        email: decodedJson['email'] ?? '',
        fullName: decodedJson['name'] ?? '',
        role: decodedJson['role'] ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}