// lib/shared/routes/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/login_otp_verification_screen.dart';
import '../../features/authentication/presentation/screens/payment_status_screen.dart';
import '../../features/authentication/presentation/screens/set_permanent_password_screen.dart';
import '../../features/authentication/presentation/screens/terms_and_conditions_screen.dart';
import '../../features/authentication/presentation/screens/change_password_screen.dart';
import '../../features/authentication/presentation/screens/change_pin_screen.dart';
import '../../features/authentication/presentation/screens/reset_pin_screen.dart';
import '../../features/authentication/presentation/screens/set_pin_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transactions/presentation/screens/transaction_detail_screen.dart';
import '../../features/transfer/presentation/screens/transfer_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/pension_plans/presentation/screens/pension_plans_screen.dart';
import '../../features/statements/presentation/screens/download_statement_screen.dart';
import '../../features/retirement/presentation/screens/retirement_goals_screen.dart';
import '../../features/accounts/presentation/screens/accounts_list_screen.dart';
import '../../features/accounts/presentation/screens/account_detail_screen.dart';
import '../../features/accounts/presentation/screens/contribution_screen.dart';
import '../../features/accounts/presentation/screens/deposit_screen.dart';
import '../../features/accounts/presentation/screens/bank_details_screen.dart';
import '../../features/transactions/presentation/screens/recent_deposits_screen.dart';
import '../../features/accounts/presentation/screens/portfolio_screen.dart';
import '../../features/reports/presentation/screens/reports_list_screen.dart';
import '../../features/reports/presentation/screens/report_detail_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.login,
    routes: [
      // ============================================================================
      // AUTHENTICATION ROUTES
      // ============================================================================
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // ============================================================================
      // PASSWORD & PIN MANAGEMENT (AUTHENTICATED)
      // ============================================================================
      GoRoute(
        path: RouteNames.changePassword,
        name: RouteNames.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.changePin,
        name: RouteNames.changePin,
        builder: (context, state) => const ChangePinScreen(),
      ),
      GoRoute(
        path: '/set-pin',
        name: 'setPin',
        builder: (context, state) => const SetPinScreen(),
      ),
      
      // ============================================================================
      // RESET PIN (UNAUTHENTICATED)
      // ============================================================================
      GoRoute(
        path: RouteNames.resetPin,
        name: RouteNames.resetPin,
        builder: (context, state) => const ResetPinScreen(),
      ),
      
      // ============================================================================
      // TERMS AND CONDITIONS
      // ============================================================================
      GoRoute(
        path: RouteNames.termsAndConditions,
        name: RouteNames.termsAndConditions,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TermsAndConditionsScreen(
            htmlContent: extra?['htmlContent'],
            showAcceptButton: extra?['showAcceptButton'] ?? false,
            onAccept: extra?['onAccept'],
          );
        },
      ),
      
      // ============================================================================
      // OTP VERIFICATION - UNIFIED SCREEN
      // ============================================================================
      
      // Primary OTP route (for login with optional password setting)
      GoRoute(
        path: RouteNames.loginOtpVerification,
        name: RouteNames.loginOtpVerification,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return LoginOtpVerificationScreen(
            identifier: extra?['identifier'] ?? '',
            verificationType: extra?['verificationType'] ?? 'login',
          );
        },
      ),
      
      // Legacy OTP route - redirects to loginOtpVerification
      GoRoute(
        path: RouteNames.otpVerification,
        name: RouteNames.otpVerification,
        redirect: (context, state) {
          // Redirect to the new unified OTP screen
          return RouteNames.loginOtpVerification;
        },
      ),
      
      // ============================================================================
      // PAYMENT STATUS
      // ============================================================================
      GoRoute(
        path: '${RouteNames.paymentStatus}/:transactionId',
        name: RouteNames.paymentStatus,
        builder: (context, state) {
          final transactionId = state.pathParameters['transactionId']!;
          return PaymentStatusScreen(transactionId: transactionId);
        },
      ),
      
      // ============================================================================
      // SET PERMANENT PASSWORD (After Registration)
      // ============================================================================
      GoRoute(
        path: RouteNames.setPermanentPassword,
        name: RouteNames.setPermanentPassword,
        builder: (context, state) => const SetPermanentPasswordScreen(),
      ),
      
      // ============================================================================
      // DASHBOARD (HOME)
      // ============================================================================
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        builder: (context, state) => const DashboardScreen(),
      ),
      
      // ============================================================================
      // ACCOUNT MANAGEMENT ROUTES
      // ============================================================================
      GoRoute(
        path: RouteNames.accounts,
        name: RouteNames.accounts,
        builder: (context, state) => const AccountsListScreen(),
      ),
      GoRoute(
        path: '${RouteNames.accountDetail}/:id',
        name: RouteNames.accountDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AccountDetailScreen(accountId: id);
        },
      ),
      GoRoute(
        path: '${RouteNames.addContribution}/:id',
        name: RouteNames.addContribution,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ContributionScreen(accountId: id);
        },
      ),
      GoRoute(
        path: '${RouteNames.bankDetails}/:id',
        name: RouteNames.bankDetails,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BankDetailsScreen(accountId: id);
        },
      ),
      GoRoute(
        path: RouteNames.recentDeposits,
        name: RouteNames.recentDeposits,
        builder: (context, state) => const RecentDepositsScreen(),
      ),
      GoRoute(
        path: '${RouteNames.depositFunds}/:id',
        name: RouteNames.depositFunds,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DepositScreen(accountId: id);
        },
      ),
      GoRoute(
        path: RouteNames.portfolio,
        name: RouteNames.portfolio,
        builder: (context, state) => const PortfolioScreen(),
      ),
      
      // ============================================================================
      // REPORTS ROUTES
      // ============================================================================
      GoRoute(
        path: RouteNames.reports,
        name: RouteNames.reports,
        builder: (context, state) => const ReportsListScreen(),
      ),
      GoRoute(
        path: '${RouteNames.reportDetail}/:id',
        name: RouteNames.reportDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReportDetailScreen(reportId: id);
        },
      ),
      
      // ============================================================================
      // TRANSACTION ROUTES
      // ============================================================================
      GoRoute(
        path: RouteNames.transactions,
        name: RouteNames.transactions,
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: '${RouteNames.transactionDetail}/:id',
        name: RouteNames.transactionDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailScreen(transactionId: id);
        },
      ),
      
      // ============================================================================
      // TRANSFER & PAYMENT ROUTES
      // ============================================================================
      GoRoute(
        path: RouteNames.transfer,
        name: RouteNames.transfer,
        builder: (context, state) => const TransferScreen(),
      ),
      GoRoute(
        path: RouteNames.payments,
        name: RouteNames.payments,
        builder: (context, state) => const PaymentsScreen(),
      ),
      
      // ============================================================================
      // PROFILE & NOTIFICATIONS
      // ============================================================================
      GoRoute(
        path: RouteNames.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        name: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      
      // ============================================================================
      // PENSION MANAGEMENT FEATURES
      // ============================================================================
      GoRoute(
        path: RouteNames.pensionPlans,
        name: RouteNames.pensionPlans,
        builder: (context, state) => const PensionPlansScreen(),
      ),
      GoRoute(
        path: RouteNames.downloadStatement,
        name: RouteNames.downloadStatement,
        builder: (context, state) => const DownloadStatementScreen(),
      ),
      GoRoute(
        path: RouteNames.retirementGoals,
        name: RouteNames.retirementGoals,
        builder: (context, state) => const RetirementGoalsScreen(),
      ),
    ],
    
    // Error builder
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Route: ${state.uri.path}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}