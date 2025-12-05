import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/receipt_bloc.dart';
import '../../../shared/shared.dart';
import '../add_receipt/add_receipt_screen.dart';
import '../receipt_detail/receipt_detail_screen.dart';
import '../../../statistics/screen/statistics_screen.dart';
import 'widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.receipts),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ReceiptBloc, ReceiptState>(
        builder: (context, state) {
          if (state is ReceiptLoading) {
            return const LoadingIndicator(message: AppStrings.loading);
          }

          if (state is ReceiptError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<ReceiptBloc>().add(const LoadReceipts());
              },
            );
          }

          if (state is ReceiptLoaded) {
            final receipts = state.receipts;
            final totalSpending = receipts.fold<double>(
              0.0,
              (sum, receipt) => sum + receipt.totalAmount,
            );

            if (receipts.isEmpty) {
              return EmptyState(
                icon: Icons.receipt_long,
                message: AppStrings.noReceiptsMessage,
                actionLabel: AppStrings.addReceipt,
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddReceiptScreen(),
                    ),
                  );
                },
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ReceiptBloc>().add(const LoadReceipts());
              },
              child: ListView(
                padding: AppSpacing.edgeInsetsM,
                children: [
                  StatisticsSummary(
                    totalSpending: totalSpending,
                    totalReceipts: receipts.length,
                  ),
                  const SizedBox(height: AppSpacing.paddingL),
                  ...receipts.map((receipt) => ReceiptCard(
                        receipt: receipt,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReceiptDetailScreen(receiptId: receipt.id!),
                            ),
                          );
                        },
                      )),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReceiptScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addReceipt),
      ),
    );
  }
}

