import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceDisplay extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final String? prefix;

  const PriceDisplay({
    super.key,
    required this.amount,
    this.style,
    this.prefix,
  });

  static String format(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = format(amount);
    final displayText = prefix != null ? '$prefix $formattedPrice' : formattedPrice;
    
    return Text(
      displayText,
      style: style ?? Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}



