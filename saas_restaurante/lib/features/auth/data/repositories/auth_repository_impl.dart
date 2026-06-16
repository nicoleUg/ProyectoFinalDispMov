import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_local_datasource.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    final response = await remoteDataSource.login(email, password);

    final UserModel user = response['user'];
    final String accessToken = response['accessToken'];
    final String refreshToken = response['refreshToken'];

    await localDataSource.saveTokens(
      accessToken: accessToken, 
      refreshToken: refreshToken
    );

    return user;
  }

  @override
  Future<void> logout() async {
    await localDataSource.deleteTokens();
  }

  @override
  Future<UserEntity?> checkAuthenticatedUser() async {
    final token = await localDataSource.getAccessToken();
    if (token != null) {
      return null; 
    }
    return null;
  }
}