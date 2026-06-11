
import 'package:dio/dio.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio; 

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login', 
        data: {
          'email': email,
          'password': password,
        },
      );

      return {
        'user': UserModel.fromJson(response.data['user']),
        'accessToken': response.data['accessToken'],
        'refreshToken': response.data['refreshToken'],
      };
    } on DioException catch (e) {
      throw Exception('Error al iniciar sesión: ${e.response?.data['message'] ?? 'Error desconocido'}');
    }
  }
}