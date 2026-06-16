import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io' show Platform;

class ApiClient {
  late final Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  ApiClient() {
    String baseUrl = 'http://localhost:3000';
    try {
      if (Platform.isAndroid) baseUrl = 'http://10.0.2.2:3000';
    } catch (e) {
      baseUrl = 'http://localhost:3000';
    }

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    // --- EL INTERCEPTOR ---
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Leemos el token de la bóveda
        final token = await secureStorage.read(key: 'jwt_token');
        
        // Si existe, lo inyectamos en la cabecera
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await secureStorage.delete(key: 'jwt_token');
          print('Token expirado. Redirigiendo a Login...');
        }
        return handler.next(e);
      },
    ));
  }
}