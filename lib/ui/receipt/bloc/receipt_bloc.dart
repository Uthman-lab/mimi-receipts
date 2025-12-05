import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../modules/receipt/domain/entities/entities.dart';
import '../../../modules/receipt/domain/usecases/usecases.dart';

part 'receipt_event.dart';
part 'receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final GetReceipts getReceipts;
  final AddReceipt addReceipt;
  final UpdateReceipt updateReceipt;
  final DeleteReceipt deleteReceipt;

  ReceiptBloc({
    required this.getReceipts,
    required this.addReceipt,
    required this.updateReceipt,
    required this.deleteReceipt,
  }) : super(const ReceiptInitial()) {
    on<LoadReceipts>(_onLoadReceipts);
    on<AddReceiptEvent>(_onAddReceipt);
    on<UpdateReceiptEvent>(_onUpdateReceipt);
    on<DeleteReceiptEvent>(_onDeleteReceipt);
  }

  Future<void> _onLoadReceipts(LoadReceipts event, Emitter<ReceiptState> emit) async {
    emit(const ReceiptLoading());
    try {
      final receipts = await getReceipts();
      emit(ReceiptLoaded(receipts));
    } catch (e) {
      emit(ReceiptError(e.toString()));
    }
  }

  Future<void> _onAddReceipt(AddReceiptEvent event, Emitter<ReceiptState> emit) async {
    try {
      await addReceipt(event.receipt);
      emit(const ReceiptOperationSuccess('Receipt added successfully'));
      add(const LoadReceipts());
    } catch (e) {
      emit(ReceiptError(e.toString()));
    }
  }

  Future<void> _onUpdateReceipt(UpdateReceiptEvent event, Emitter<ReceiptState> emit) async {
    try {
      await updateReceipt(event.receipt);
      emit(const ReceiptOperationSuccess('Receipt updated successfully'));
      add(const LoadReceipts());
    } catch (e) {
      emit(ReceiptError(e.toString()));
    }
  }

  Future<void> _onDeleteReceipt(DeleteReceiptEvent event, Emitter<ReceiptState> emit) async {
    try {
      await deleteReceipt(event.id);
      emit(const ReceiptOperationSuccess('Receipt deleted successfully'));
      add(const LoadReceipts());
    } catch (e) {
      emit(ReceiptError(e.toString()));
    }
  }
}

