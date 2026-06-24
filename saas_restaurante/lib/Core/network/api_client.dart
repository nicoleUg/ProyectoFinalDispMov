import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; 
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
      if (!kIsWeb) {
        if (Platform.isAndroid || Platform.isIOS) {
          // Cambiado de 10.0.2.2 (solo emulador) a la IP local de tu PC en la red Wi-Fi para dar soporte a celulares reales.
          baseUrl = 'http://192.168.0.2:3000';
        }
      }
    } catch (e) {
      baseUrl = 'http://localhost:3000';
    }

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ));

    // [CORRECCIÓN]: Pasamos 'dio' como el segundo parámetro que exige tu AuthInterceptor
    dio.interceptors.add(AuthInterceptor(_secureStorageService, dio));
  }
}