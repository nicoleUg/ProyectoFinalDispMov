import 'package:dio/dio.dart';

abstract class OrdersRemoteDataSource {
  Future<bool> sendOrderToServer(Map<String, dynamic> orderJson);
  Future<String?> getOrderStatus(String orderId);
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

  @override
  Future<String?> getOrderStatus(String orderId) async {
    try {
      final response = await dio.get('/orders/$orderId');
      if (response.statusCode == 200 && response.data != null) {
        return response.data['status']?.toString();
      }
    } catch (e) {
      print('Error al obtener estado del pedido $orderId del servidor: $e');
    }
    return null;
  }
}