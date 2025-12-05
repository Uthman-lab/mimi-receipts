import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/statistics_bloc.dart';
import '../../shared/shared.dart';
import 'widgets/widgets.dart';
import '../../../../modules/receipt/domain/entities/shop.dart';
import '../../../../core/di/injection.dart';
import '../../../../modules/receipt/domain/usecases/usecases.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Shop? _selectedShop;
  List<Shop> _shops = [];
  bool _isLoadingShops = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
    context.read<StatisticsBloc>().add(const LoadStatistics());
  }

  Future<void> _loadShops() async {
    try {
      final getShops = getIt<GetShops>();
      final shops = await getShops();
      setState(() {
        _shops = shops;
        _isLoadingShops = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingShops = false;
      });
    }
  }

  void _onShopChanged(Shop? shop) {
    setState(() {
      _selectedShop = shop;
    });
    context.read<StatisticsBloc>().add(LoadStatistics(shopId: shop?.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.statistics),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildShopFilter(),
          ),
        ),
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
                context.read<StatisticsBloc>().add(
                  LoadStatistics(shopId: _selectedShop?.id),
                );
              },
            );
          }

          if (state is StatisticsLoaded) {
            final stats = state.statistics;
            final totalSpending = stats['totalSpending'] as double? ?? 0.0;
            final spendingByCategory =
                stats['spendingByCategory'] as Map<String, double>? ?? {};
            final spendingByShop =
                stats['spendingByShop'] as Map<String, double>? ?? {};
            final monthlySpending =
                stats['monthlySpending'] as Map<String, double>? ?? {};
            final spendingByItem =
                stats['spendingByItem'] as List<Map<String, dynamic>>? ?? [];
            final monthlyItemSpending =
                stats['monthlyItemSpending']
                    as Map<String, Map<String, double>>? ??
                {};
            final uniqueItemsCount = stats['uniqueItemsCount'] as int? ?? 0;
            final avgSpendingPerItem =
                stats['avgSpendingPerItem'] as double? ?? 0.0;
            final totalReceipts = stats['totalReceipts'] as int?;
            final avgReceiptAmount = stats['avgReceiptAmount'] as double?;

            if (totalSpending == 0) {
              return EmptyState(
                icon: Icons.bar_chart,
                message: AppStrings.noDataMessage,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<StatisticsBloc>().add(
                  LoadStatistics(shopId: _selectedShop?.id),
                );
              },
              child: ListView(
                padding: AppSpacing.edgeInsetsM,
                children: [
                  // Shop-specific insights
                  if (_selectedShop != null &&
                      totalReceipts != null &&
                      avgReceiptAmount != null)
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.store,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.paddingS),
                              Text(
                                _selectedShop!.name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.paddingM),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInsightCard(
                                  context,
                                  'Total Receipts',
                                  totalReceipts.toString(),
                                  Icons.receipt_long,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.paddingS),
                              Expanded(
                                child: _buildInsightCard(
                                  context,
                                  'Avg Receipt',
                                  PriceDisplay.format(avgReceiptAmount),
                                  Icons.attach_money,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (_selectedShop != null)
                    const SizedBox(height: AppSpacing.paddingL),
                  // Total spending
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
                  // Item insights
                  if (spendingByItem.isNotEmpty) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.topItems,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$uniqueItemsCount items',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          if (avgSpendingPerItem > 0) ...[
                            const SizedBox(height: AppSpacing.paddingXS),
                            Text(
                              'Avg: ${PriceDisplay.format(avgSpendingPerItem)} per item',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.paddingS),
                    AppCard(
                      padding: AppSpacing.edgeInsetsL,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.spendingByItem,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.paddingM),
                          ItemSpendingChart(spendingByItem: spendingByItem),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.paddingL),
                  ],
                  // Monthly item spending
                  if (monthlyItemSpending.isNotEmpty) ...[
                    _MonthlyItemStatsSection(
                      monthlyItemSpending: monthlyItemSpending,
                    ),
                    const SizedBox(height: AppSpacing.paddingL),
                  ],
                  // Monthly spending
                  if (monthlySpending.isNotEmpty)
                    AppChartContainer(
                      title: AppStrings.monthlySpending,
                      height: AppSizes.chartHeightLarge,
                      child: SpendingChart(monthlySpending: monthlySpending),
                    ),
                  if (monthlySpending.isNotEmpty)
                    const SizedBox(height: AppSpacing.paddingL),
                  // Category spending
                  if (spendingByCategory.isNotEmpty)
                    AppChartContainer(
                      title: AppStrings.spendingByCategory,
                      height: AppSizes.chartHeightLarge,
                      child: CategoryChart(
                        spendingByCategory: spendingByCategory,
                      ),
                    ),
                  if (spendingByCategory.isNotEmpty)
                    const SizedBox(height: AppSpacing.paddingL),
                  // Shop comparison (only show when not filtering by shop)
                  if (spendingByShop.isNotEmpty && _selectedShop == null)
                    AppChartContainer(
                      title: AppStrings.spendingByShop,
                      height: AppSizes.chartHeightLarge,
                      child: ShopComparisonChart(
                        spendingByShop: spendingByShop,
                      ),
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

  Widget _buildShopFilter() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<Shop>(
        value: _selectedShop,
        decoration: InputDecoration(
          labelText: AppStrings.filterByShop,
          prefixIcon: const Icon(Icons.filter_list),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items: [
          const DropdownMenuItem<Shop>(
            value: null,
            child: Text(AppStrings.allShops),
          ),
          ..._shops.map((shop) {
            return DropdownMenuItem<Shop>(value: shop, child: Text(shop.name));
          }),
        ],
        onChanged: _isLoadingShops ? null : _onShopChanged,
        isExpanded: true,
        hint: _isLoadingShops
            ? const Text(AppStrings.loading)
            : const Text(AppStrings.allShops),
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.paddingXS),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _MonthlyItemStatsSection extends StatefulWidget {
  final Map<String, Map<String, double>> monthlyItemSpending;

  const _MonthlyItemStatsSection({required this.monthlyItemSpending});

  @override
  State<_MonthlyItemStatsSection> createState() =>
      _MonthlyItemStatsSectionState();
}

class _MonthlyItemStatsSectionState extends State<_MonthlyItemStatsSection> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.edgeInsetsL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.monthlyItemSpending,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.paddingM),
          // Tabs
          Row(
            children: [
              Expanded(
                child: _buildTab(
                  context,
                  0,
                  AppStrings.itemMonthlyTrends,
                  Icons.show_chart,
                ),
              ),
              const SizedBox(width: AppSpacing.paddingS),
              Expanded(
                child: _buildTab(
                  context,
                  1,
                  AppStrings.itemMonthlyBreakdown,
                  Icons.table_chart,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.paddingM),
          // Content
          IndexedStack(
            index: _selectedTab,
            children: [
              ItemMonthlyChart(monthlyItemSpending: widget.monthlyItemSpending),
              ItemMonthlyTable(monthlyItemSpending: widget.monthlyItemSpending),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    int index,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingS),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: AppSpacing.paddingXS),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
