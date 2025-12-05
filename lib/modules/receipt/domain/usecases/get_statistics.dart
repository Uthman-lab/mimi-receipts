import '../repositories/repositories.dart';

class GetStatistics {
  final ReceiptRepository repository;

  GetStatistics(this.repository);

  Future<Map<String, dynamic>> call({int? shopId}) {
    return repository.getStatistics(shopId: shopId);
  }
}


