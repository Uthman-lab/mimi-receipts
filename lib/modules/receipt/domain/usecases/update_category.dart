import '../entities/entities.dart';
import '../repositories/repositories.dart';

class UpdateCategory {
  final ReceiptRepository repository;

  UpdateCategory(this.repository);

  Future<void> call(Category category) {
    return repository.updateCategory(category);
  }
}

