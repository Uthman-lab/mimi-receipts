import '../repositories/repositories.dart';
import '../entities/entities.dart';

class GetShops {
  final ReceiptRepository repository;

  GetShops(this.repository);

  Future<List<Shop>> call() {
    return repository.getShops();
  }
}

