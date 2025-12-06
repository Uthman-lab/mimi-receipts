import '../entities/entities.dart';
import '../repositories/repositories.dart';

class AddReceipt {
  final ReceiptRepository repository;

  AddReceipt(this.repository);

  Future<int> call(Receipt receipt) {
    return repository.addReceipt(receipt);
  }
}



