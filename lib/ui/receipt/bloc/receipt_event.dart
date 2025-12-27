part of 'receipt_bloc.dart';

abstract class ReceiptEvent extends Equatable {
  const ReceiptEvent();

  @override
  List<Object?> get props => [];
}

class LoadReceipts extends ReceiptEvent {
  const LoadReceipts();
}

class AddReceiptEvent extends ReceiptEvent {
  final Receipt receipt;

  const AddReceiptEvent(this.receipt);

  @override
  List<Object?> get props => [receipt];
}

class UpdateReceiptEvent extends ReceiptEvent {
  final Receipt receipt;

  const UpdateReceiptEvent(this.receipt);

  @override
  List<Object?> get props => [receipt];
}

class DeleteReceiptEvent extends ReceiptEvent {
  final int id;

  const DeleteReceiptEvent(this.id);

  @override
  List<Object?> get props => [id];
}






