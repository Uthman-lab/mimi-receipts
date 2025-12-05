import '../repositories/repositories.dart';

class GetLastItemPrice {
  final ReceiptRepository repository;

  GetLastItemPrice(this.repository);

  Future<double?> call(String itemName) {
    return repository.getLastItemPrice(itemName);
  }
}


