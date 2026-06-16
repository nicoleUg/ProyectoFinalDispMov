import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';
import '../secure_storage/secure_storage_service.dart';

class ApiClient {
  final SecureStorageService _secureStorageService;
  late final Dio dio;

  ApiClient(this._secureStorageService) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
      ),
    );

    dio.interceptors.add(AuthInterceptor(_secureStorageService, dio));
    
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
}