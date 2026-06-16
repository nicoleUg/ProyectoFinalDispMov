import 'package:dio/dio.dart';

abstract class MenuRemoteDataSource {
  Future<Map<String, dynamic>> fetchMenu();
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final Dio dio;
  MenuRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> fetchMenu() async {
    final response = await dio.get('/menu');
    return response.data;
  }
}