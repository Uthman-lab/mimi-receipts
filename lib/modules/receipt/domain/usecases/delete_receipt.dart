import '../repositories/repositories.dart';

class DeleteReceipt {
  final ReceiptRepository repository;

  DeleteReceipt(this.repository);

  Future<void> call(int id) {
    return repository.deleteReceipt(id);
  }
}


