import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/theme.dart';
import 'core/di/injection.dart';
import 'ui/receipt/bloc/receipt_bloc.dart';
import 'ui/statistics/bloc/statistics_bloc.dart';
import 'ui/price_comparison/bloc/price_comparison_bloc.dart';
import 'ui/receipt/screen/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ReceiptBloc>(
          create: (_) => getIt<ReceiptBloc>()..add(const LoadReceipts()),
        ),
        BlocProvider<StatisticsBloc>(
          create: (_) => getIt<StatisticsBloc>(),
        ),
        BlocProvider<PriceComparisonBloc>(
          create: (_) => getIt<PriceComparisonBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Receipt Tracker',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
