import 'package:dio/dio.dart';

abstract class OrdersRemoteDataSource {
  Future<bool> sendOrderToServer(Map<String, dynamic> orderJson);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final Dio dio;
  OrdersRemoteDataSourceImpl(this.dio);

  @override
  Future<bool> sendOrderToServer(Map<String, dynamic> orderJson) async {
    try {
      final response = await dio.post('/orders', data: orderJson);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error al enviar pedido al servidor remoto: $e');
      return false; 
    }
  }
}