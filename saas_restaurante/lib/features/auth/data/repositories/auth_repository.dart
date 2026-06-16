import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../Core/network/api_client.dart';

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
}