import '../repositories/repositories.dart';

class DeleteShop {
  final ReceiptRepository repository;

  DeleteShop(this.repository);

  Future<void> call(int shopId) {
    return repository.deleteShop(shopId);
  }
}

