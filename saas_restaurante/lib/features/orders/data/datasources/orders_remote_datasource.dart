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
      await Future.delayed(const Duration(seconds: 2));
      return true;
      
      /*
      final response = await dio.post('/orders', data: orderJson);
      return response.statusCode == 201;
      */
    } catch (e) {
      return false; 
    }
  }
}