import '../entities/entities.dart';
import '../repositories/repositories.dart';

class GetReceiptsByShop {
  final ReceiptRepository repository;

  GetReceiptsByShop(this.repository);

  Future<List<Receipt>> call(int shopId) {
    return repository.getReceiptsByShopId(shopId);
  }
}



