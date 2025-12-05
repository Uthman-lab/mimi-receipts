import '../repositories/repositories.dart';

class GetPriceHistory {
  final ReceiptRepository repository;

  GetPriceHistory(this.repository);

  Future<List<Map<String, dynamic>>> call(String itemDescription) {
    return repository.getPriceHistory(itemDescription);
  }
}

