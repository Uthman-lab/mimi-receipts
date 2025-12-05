import '../repositories/repositories.dart';

class CategoryHasReceiptItems {
  final ReceiptRepository repository;

  CategoryHasReceiptItems(this.repository);

  Future<bool> call(int categoryId) {
    return repository.categoryHasReceiptItems(categoryId);
  }
}

