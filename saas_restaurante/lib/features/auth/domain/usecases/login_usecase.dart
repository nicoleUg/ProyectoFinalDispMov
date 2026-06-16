
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(String email, String password) async {
    //aca pueder ir validaciones de email pero por falta de tiempo no se hara :c

    return await repository.login(email: email, password: password);
  }
}