import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../modules/receipt/domain/usecases/usecases.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetStatistics getStatistics;

  StatisticsBloc({required this.getStatistics}) : super(const StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(LoadStatistics event, Emitter<StatisticsState> emit) async {
    emit(const StatisticsLoading());
    try {
      final statistics = await getStatistics(shopId: event.shopId);
      emit(StatisticsLoaded(statistics));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }
}

