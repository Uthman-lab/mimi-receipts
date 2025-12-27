import '../repositories/repositories.dart';

class GetShopNames {
  final ReceiptRepository repository;

  GetShopNames(this.repository);

  Future<List<String>> call() {
    return repository.getShopNames();
  }
}






