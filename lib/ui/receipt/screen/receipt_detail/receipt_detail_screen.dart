import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/receipt_bloc.dart';
import '../../../shared/shared.dart';
import '../../../../modules/receipt/domain/entities/receipt.dart';
import '../add_receipt/add_receipt_screen.dart';
import 'widgets/widgets.dart';

class ReceiptDetailScreen extends StatelessWidget {
  final int receiptId;

  const ReceiptDetailScreen({
    super.key,
    required this.receiptId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.receiptDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final state = context.read<ReceiptBloc>().state;
              if (state is ReceiptLoaded) {
                final receipt = state.receipts.firstWhere((r) => r.id == receiptId);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddReceiptScreen(receipt: receipt),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text(AppStrings.delete),
                  content: const Text('Are you sure you want to delete this receipt?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(AppStrings.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReceiptBloc>().add(DeleteReceiptEvent(receiptId));
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: const Text(AppStrings.delete),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ReceiptBloc, ReceiptState>(
        builder: (context, state) {
          if (state is ReceiptLoading) {
            return const LoadingIndicator();
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
            final receipt = state.receipts.firstWhere((r) => r.id == receiptId);
            return SingleChildScrollView(
              padding: AppSpacing.edgeInsetsM,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReceiptHeader(receipt: receipt),
                  const SizedBox(height: AppSpacing.paddingL),
                  ReceiptItemsList(items: receipt.items),
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

