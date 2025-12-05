import 'package:get_it/get_it.dart';
import '../../modules/receipt/data/database/database_helper.dart';
import '../../modules/receipt/data/datasources/datasources.dart';
import '../../modules/receipt/data/repositories/repositories.dart';
import '../../modules/receipt/domain/repositories/repositories.dart';
import '../../modules/receipt/domain/usecases/usecases.dart';
import '../../ui/receipt/bloc/receipt_bloc.dart';
import '../../ui/statistics/bloc/statistics_bloc.dart';
import '../../ui/price_comparison/bloc/price_comparison_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Database
  getIt.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);

  // Data sources
  getIt.registerLazySingleton<ReceiptLocalDataSource>(
    () => ReceiptLocalDataSource(getIt<DatabaseHelper>()),
  );

  // Repositories
  getIt.registerLazySingleton<ReceiptRepository>(
    () => ReceiptRepositoryImpl(getIt<ReceiptLocalDataSource>()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetReceipts(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(() => AddReceipt(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(() => UpdateReceipt(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(() => DeleteReceipt(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(() => GetStatistics(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(
    () => GetPriceHistory(getIt<ReceiptRepository>()),
  );
  getIt.registerLazySingleton(() => GetShopNames(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(() => GetItemNames(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(
    () => GetLastItemPrice(getIt<ReceiptRepository>()),
  );
  getIt.registerLazySingleton(() => GetShops(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(() => AddShop(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(() => UpdateShop(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(() => DeleteShop(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(
    () => GetReceiptsByShop(getIt<ReceiptRepository>()),
  );
  getIt.registerLazySingleton(() => GetCategories(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(() => AddCategory(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(() => UpdateCategory(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(() => DeleteCategory(getIt<ReceiptRepository>()));
  getIt.registerLazySingleton(
    () => CategoryHasReceiptItems(getIt<ReceiptRepository>()),
  );

  // BLoCs
  getIt.registerFactory(
    () => ReceiptBloc(
      getReceipts: getIt<GetReceipts>(),
      addReceipt: getIt<AddReceipt>(),
      updateReceipt: getIt<UpdateReceipt>(),
      deleteReceipt: getIt<DeleteReceipt>(),
    ),
  );

  getIt.registerFactory(
    () => StatisticsBloc(getStatistics: getIt<GetStatistics>()),
  );

  getIt.registerFactory(
    () => PriceComparisonBloc(getPriceHistory: getIt<GetPriceHistory>()),
  );
}
