import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/utils/sms_service.dart';
import 'shared/routes/app_router.dart';
import 'features/authentication/data/datasources/auth_remote_datasource.dart';
import 'features/authentication/presentation/providers/auth_provider.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/usecases/get_all_transactions_usecase.dart';
import 'features/transactions/domain/usecases/get_transaction_detail_usecase.dart';
import 'features/transactions/presentation/providers/transaction_provider.dart';
import 'features/accounts/data/services/account_service.dart'; 
import 'features/accounts/presentation/providers/account_provider.dart';
import 'features/reports/data/datasources/report_remote_datasource.dart';
import 'features/reports/data/repositories/report_repository_impl.dart';
import 'features/reports/domain/usecases/generate_transaction_report.dart';
import 'features/reports/domain/usecases/generate_customer_report.dart';
import 'features/reports/domain/usecases/get_reports.dart';
import 'features/reports/domain/usecases/get_report_by_id.dart';
import 'features/reports/domain/usecases/delete_report.dart';
import 'features/reports/presentation/providers/report_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SMS Service
  final smsService = SmsService();
  await smsService.initialize();
  
  await Hive.initFlutter();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI to edge-to-edge with transparent bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const AutoNest());
}

class AutoNest extends StatelessWidget {
  const AutoNest({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final apiClient = ApiClient();
    final logger = Logger();
    final networkInfo = NetworkInfoImpl(Connectivity());
    
    // Initialize data sources
    final authDataSource = AuthRemoteDataSource(apiClient: apiClient);
    final dashboardDataSource = DashboardRemoteDataSourceImpl(
      dio: apiClient.dio,
      logger: logger,
    );
    
    final reportDataSource = ReportRemoteDataSourceImpl(
      dio: apiClient.dio,
      logger: logger,
    );

    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authDataSource: authDataSource,
            dio: apiClient.dio,
          )..checkAuthStatus(),
        ),
        
        // Dashboard Provider
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(
            repository: DashboardRepositoryImpl(
              remoteDataSource: dashboardDataSource,
              networkInfo: networkInfo,
              logger: logger,
            ),
          ),
        ),
        
        // Transactions Provider
        ChangeNotifierProvider(
          create: (_) {
            final transactionRemote = TransactionRemoteDataSourceImpl(dio: apiClient.dio);
            final transactionRepo = TransactionRepositoryImpl(remoteDataSource: transactionRemote);
            final getAll = GetAllTransactionsUseCase(transactionRepo);
            final getDetail = GetTransactionDetailUseCase(transactionRepo);
            return TransactionProvider(
              getAllTransactionsUseCase: getAll,
              getTransactionDetailUseCase: getDetail,
            );
          },
        ),
        
        // Account Provider
        ChangeNotifierProvider(
          create: (_) => AccountProvider(
            accountService: AccountService(),
          ),
        ),
        
        // Reports Provider
        ChangeNotifierProvider(
          create: (_) {
            final reportRepository = ReportRepositoryImpl(
              remoteDataSource: reportDataSource,
              logger: logger,
            );
            
            return ReportProvider(
              generateTransactionReportUseCase: GenerateTransactionReport(reportRepository),
              generateCustomerReportUseCase: GenerateCustomerReport(reportRepository),
              getReportsUseCase: GetReports(reportRepository),
              getReportByIdUseCase: GetReportById(reportRepository),
              deleteReportUseCase: DeleteReport(reportRepository),
            );
          },
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'AutoNest',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}