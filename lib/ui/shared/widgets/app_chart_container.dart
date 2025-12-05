import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'app_card.dart';

class AppChartContainer extends StatelessWidget {
  final Widget child;
  final String? title;
  final double? height;

  const AppChartContainer({
    super.key,
    required this.child,
    this.title,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.edgeInsetsL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.paddingM),
          ],
          SizedBox(
            height: height ?? AppSizes.chartHeight,
            child: child,
          ),
        ],
      ),
    );
  }
}

