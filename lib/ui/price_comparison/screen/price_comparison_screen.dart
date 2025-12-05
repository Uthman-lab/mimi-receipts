import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../price_comparison/bloc/price_comparison_bloc.dart';
import '../../shared/shared.dart';
import 'widgets/widgets.dart';

class PriceComparisonScreen extends StatefulWidget {
  const PriceComparisonScreen({super.key});

  @override
  State<PriceComparisonScreen> createState() => _PriceComparisonScreenState();
}

class _PriceComparisonScreenState extends State<PriceComparisonScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchPriceHistory() {
    if (_searchController.text.isEmpty) {
      return;
    }
    context.read<PriceComparisonBloc>().add(
      LoadPriceHistory(_searchController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.priceComparison)),
      body: BlocBuilder<PriceComparisonBloc, PriceComparisonState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: AppSpacing.edgeInsetsM,
                child: Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: AppStrings.searchItem,
                        controller: _searchController,
                        onChanged: (_) {},
                      ),
                    ),
                    const SizedBox(width: AppSpacing.paddingM),
                    AppButton(
                      label: 'Search',
                      width: 100,
                      onPressed: _searchPriceHistory,
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildStateWidget(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStateWidget(PriceComparisonState state) {
    if (state is PriceComparisonLoading) {
      return const LoadingIndicator(message: AppStrings.loading);
    }

    if (state is PriceComparisonError) {
      return AppErrorWidget(
        message: state.message,
        onRetry: () {
          _searchPriceHistory();
        },
      );
    }

    if (state is PriceComparisonLoaded) {
      if (state.priceHistory.isEmpty) {
        return EmptyState(
          icon: Icons.search_off,
          message: AppStrings.noPriceDataMessage,
        );
      }

      return SingleChildScrollView(
        padding: AppSpacing.edgeInsetsM,
        child: AppChartContainer(
          title: AppStrings.priceHistory,
          height: AppSizes.chartHeightLarge,
          child: PriceHistoryChart(priceHistory: state.priceHistory),
        ),
      );
    }

    return EmptyState(
      icon: Icons.search,
      message: 'Enter an item name to search for price history',
    );
  }
}
