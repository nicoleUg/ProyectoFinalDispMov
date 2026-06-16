import '../repositories/menu_repository.dart';

class SyncMenuUseCase {
  final MenuRepository repository;
  SyncMenuUseCase(this.repository);
  Future<void> call() => repository.syncMenuWithServer();
}