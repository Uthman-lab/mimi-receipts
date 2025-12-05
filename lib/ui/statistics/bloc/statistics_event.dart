part of 'statistics_bloc.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadStatistics extends StatisticsEvent {
  final int? shopId;

  const LoadStatistics({this.shopId});

  @override
  List<Object?> get props => [shopId];
}


