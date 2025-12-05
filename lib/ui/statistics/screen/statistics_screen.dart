import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/statistics_bloc.dart';
import '../../shared/shared.dart';
import 'widgets/widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StatisticsBloc>().add(const LoadStatistics());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.statistics),
      ),
      body: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsLoading) {
              return const LoadingIndicator(message: AppStrings.loading);
            }

            if (state is StatisticsError) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<StatisticsBloc>().add(const LoadStatistics());
                },
              );
            }

            if (state is StatisticsLoaded) {
              final stats = state.statistics;
              final totalSpending = stats['totalSpending'] as double? ?? 0.0;
              final spendingByCategory = stats['spendingByCategory'] as Map<String, double>? ?? {};
              final spendingByShop = stats['spendingByShop'] as Map<String, double>? ?? {};
              final monthlySpending = stats['monthlySpending'] as Map<String, double>? ?? {};

              if (totalSpending == 0) {
                return EmptyState(
                  icon: Icons.bar_chart,
                  message: AppStrings.noDataMessage,
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<StatisticsBloc>().add(const LoadStatistics());
                },
                child: ListView(
                  padding: AppSpacing.edgeInsetsM,
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.totalSpending,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.paddingXS),
                          PriceDisplay(
                            amount: totalSpending,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.paddingL),
                    if (monthlySpending.isNotEmpty)
                      AppChartContainer(
                        title: AppStrings.monthlySpending,
                        height: AppSizes.chartHeightLarge,
                        child: SpendingChart(monthlySpending: monthlySpending),
                      ),
                    if (monthlySpending.isNotEmpty) const SizedBox(height: AppSpacing.paddingL),
                    if (spendingByCategory.isNotEmpty)
                      AppChartContainer(
                        title: AppStrings.spendingByCategory,
                        height: AppSizes.chartHeightLarge,
                        child: CategoryChart(spendingByCategory: spendingByCategory),
                      ),
                    if (spendingByCategory.isNotEmpty) const SizedBox(height: AppSpacing.paddingL),
                    if (spendingByShop.isNotEmpty)
                      AppChartContainer(
                        title: AppStrings.spendingByShop,
                        height: AppSizes.chartHeightLarge,
                        child: ShopComparisonChart(spendingByShop: spendingByShop),
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      
    );
  }
}

