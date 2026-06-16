import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';
import '../secure_storage/secure_storage_service.dart';

class ApiClient {
  final SecureStorageService _secureStorageService;
  late final Dio dio;

  ApiClient(this._secureStorageService) {
    String baseUrl = 'http://localhost:3000';
    try {
      if (Platform.isAndroid) baseUrl = 'http://10.0.2.2:3000';
    } catch (e) {
      baseUrl = 'http://localhost:3000';
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );

    dio.interceptors.add(AuthInterceptor(_secureStorageService, dio));
    
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
}