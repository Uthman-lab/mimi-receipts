import '../repositories/repositories.dart';

class DeleteCategory {
  final ReceiptRepository repository;

  DeleteCategory(this.repository);

  Future<void> call(int categoryId) {
    return repository.deleteCategory(categoryId);
  }
}



