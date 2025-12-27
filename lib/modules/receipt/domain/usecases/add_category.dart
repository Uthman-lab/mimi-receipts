import '../entities/entities.dart';
import '../repositories/repositories.dart';

class AddCategory {
  final ReceiptRepository repository;

  AddCategory(this.repository);

  Future<int> call(Category category) {
    return repository.addCategory(category);
  }
}





