part of 'price_comparison_bloc.dart';

abstract class PriceComparisonEvent extends Equatable {
  const PriceComparisonEvent();

  @override
  List<Object?> get props => [];
}

class LoadPriceHistory extends PriceComparisonEvent {
  final String itemDescription;

  const LoadPriceHistory(this.itemDescription);

  @override
  List<Object?> get props => [itemDescription];
}






