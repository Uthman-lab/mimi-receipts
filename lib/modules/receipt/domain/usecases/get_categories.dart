import '../repositories/repositories.dart';
import '../entities/entities.dart';

class GetCategories {
  final ReceiptRepository repository;

  GetCategories(this.repository);

  Future<List<Category>> call() {
    return repository.getCategories();
  }
}



