import 'package:flutter/material.dart';
import '../constants/constants.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Card(
      color: color,
      elevation: elevation ?? 2,
      margin: margin ?? EdgeInsets.zero,
      child: Padding(
        padding: padding ?? AppSpacing.edgeInsetsM,
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: card,
      );
    }

    return card;
  }
}



