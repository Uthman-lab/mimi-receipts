import '../entities/entities.dart';
import '../repositories/repositories.dart';

class GetReceipts {
  final ReceiptRepository repository;

  GetReceipts(this.repository);

  Future<List<Receipt>> call() {
    return repository.getReceipts();
  }
}



