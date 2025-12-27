import '../repositories/repositories.dart';

class GetItemNames {
  final ReceiptRepository repository;

  GetItemNames(this.repository);

  Future<List<String>> call() {
    return repository.getItemNames();
  }
}






