import 'package:dio/dio.dart';
import '../../../Core/network/api_client.dart';

class OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSource(this.apiClient);

  Future<void> syncOrderWithBackend(Map<String, dynamic> orderJson) async {
    try {
      final response = await apiClient.dio.post(
        '/orders',
        data: orderJson,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Orden enviada a NestJS con éxito: ${response.data}');
      } else {
        throw Exception('Error en el servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error de conexión con NestJS: ${e.message}');
      throw Exception('Fallo la sincronización de la orden');
    }
  }
}