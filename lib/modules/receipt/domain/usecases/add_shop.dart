import '../entities/entities.dart';
import '../repositories/repositories.dart';

class AddShop {
  final ReceiptRepository repository;

  AddShop(this.repository);

  Future<int> call(Shop shop) {
    return repository.addShop(shop);
  }
}



