import '../entities/entities.dart';
import '../repositories/repositories.dart';

class UpdateReceipt {
  final ReceiptRepository repository;

  UpdateReceipt(this.repository);

  Future<void> call(Receipt receipt) {
    return repository.updateReceipt(receipt);
  }
}






