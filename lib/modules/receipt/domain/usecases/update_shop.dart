import '../entities/entities.dart';
import '../repositories/repositories.dart';

class UpdateShop {
  final ReceiptRepository repository;

  UpdateShop(this.repository);

  Future<void> call(Shop shop) {
    return repository.updateShop(shop);
  }
}


