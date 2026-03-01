// lib/shared/routes/route_names.dart

class RouteNames {
  // ============================================================================
  // AUTHENTICATION ROUTES
  // ============================================================================
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String loginOtpVerification = '/login-otp-verification';
  static const String paymentStatus = '/payment-status';
  static const String setPermanentPassword = '/set-permanent-password';
  static const String termsAndConditions = '/terms-and-conditions';
  
  // Password & PIN Management
  static const String changePassword = '/change-password';
  static const String changePin = '/change-pin';
  static const String resetPin = '/reset-pin';
  
  // ============================================================================
  // MAIN APP ROUTES
  // ============================================================================
  static const String home = '/home';
  static const String transactions = '/transactions';
  static const String transactionDetail = '/transaction-detail';
  static const String calculator = '/calculator';
  static const String payments = '/payments';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  
  // ============================================================================
  // ACCOUNT MANAGEMENT ROUTES
  // ============================================================================
  static const String accounts = '/accounts';
  static const String accountDetail = '/account-detail';
  static const String addContribution = '/add-contribution';
  static const String depositFunds = '/deposit-funds';
  static const String withdrawFunds = '/withdraw-funds';
  static const String portfolio = '/portfolio';
  
  // ============================================================================
  // REPORTS ROUTES
  // ============================================================================
  static const String reports = '/reports';
  static const String reportDetail = '/report-detail';
  static const String generateReport = '/generate-report';
  
  // ============================================================================
  // PENSION MANAGEMENT FEATURES
  // ============================================================================
  static const String pensionPlans = '/pension-plans';
  static const String downloadStatement = '/download-statement';
  static const String retirementGoals = '/retirement-goals';
  
  // ============================================================================
  // SETTINGS ROUTES
  // ============================================================================
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
  static const String security = '/security';
  
  // ============================================================================
  // ADDITIONAL ROUTES
  // ============================================================================
  static const String beneficiaries = '/beneficiaries';
  static const String addBeneficiary = '/add-beneficiary';
  static const String accountStatement = '/account-statement';
  static const String support = '/support';
  static const String faq = '/faq';
  
  // Bank details
  static const String bankDetails = '/bank-details';
  
  // Recent deposits
  static const String recentDeposits = '/recent-deposits';
}