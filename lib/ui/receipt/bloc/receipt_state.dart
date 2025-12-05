part of 'receipt_bloc.dart';

abstract class ReceiptState extends Equatable {
  const ReceiptState();

  @override
  List<Object?> get props => [];
}

class ReceiptInitial extends ReceiptState {
  const ReceiptInitial();
}

class ReceiptLoading extends ReceiptState {
  const ReceiptLoading();
}

class ReceiptLoaded extends ReceiptState {
  final List<Receipt> receipts;

  const ReceiptLoaded(this.receipts);

  @override
  List<Object?> get props => [receipts];
}

class ReceiptError extends ReceiptState {
  final String message;

  const ReceiptError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReceiptOperationSuccess extends ReceiptState {
  final String message;

  const ReceiptOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

