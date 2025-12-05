import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../modules/receipt/domain/usecases/usecases.dart';

part 'price_comparison_event.dart';
part 'price_comparison_state.dart';

class PriceComparisonBloc extends Bloc<PriceComparisonEvent, PriceComparisonState> {
  final GetPriceHistory getPriceHistory;

  PriceComparisonBloc({required this.getPriceHistory}) : super(const PriceComparisonInitial()) {
    on<LoadPriceHistory>(_onLoadPriceHistory);
  }

  Future<void> _onLoadPriceHistory(
    LoadPriceHistory event,
    Emitter<PriceComparisonState> emit,
  ) async {
    emit(const PriceComparisonLoading());
    try {
      final priceHistory = await getPriceHistory(event.itemDescription);
      emit(PriceComparisonLoaded(priceHistory));
    } catch (e) {
      emit(PriceComparisonError(e.toString()));
    }
  }
}

