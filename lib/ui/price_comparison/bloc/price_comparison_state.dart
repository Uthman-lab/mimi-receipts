part of 'price_comparison_bloc.dart';

abstract class PriceComparisonState extends Equatable {
  const PriceComparisonState();

  @override
  List<Object?> get props => [];
}

class PriceComparisonInitial extends PriceComparisonState {
  const PriceComparisonInitial();
}

class PriceComparisonLoading extends PriceComparisonState {
  const PriceComparisonLoading();
}

class PriceComparisonLoaded extends PriceComparisonState {
  final List<Map<String, dynamic>> priceHistory;

  const PriceComparisonLoaded(this.priceHistory);

  @override
  List<Object?> get props => [priceHistory];
}

class PriceComparisonError extends PriceComparisonState {
  final String message;

  const PriceComparisonError(this.message);

  @override
  List<Object?> get props => [message];
}

