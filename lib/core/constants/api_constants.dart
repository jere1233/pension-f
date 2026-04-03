// lib/core/constants/api_constants.dart - DASHBOARD SECTION

class ApiConstants {
  static const String baseUrl = 'https://autonest-backend.onrender.com';
  
  // Timeouts
  static const int connectionTimeout = 30000; 
  static const int receiveTimeout = 30000; 

  // ============================================================================
  // AUTHENTICATION ENDPOINTS
  // ============================================================================
  static const String login = '/api/auth/login';
  static const String loginOtp = '/api/auth/login/otp';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh';
  static const String verifyToken = '/api/auth/verify';
  static const String setPassword = '/api/auth/set-password';
  
  // OTP Management
  static const String resendOtp = '/api/auth/resend-otp';
  
  // Password Management
  static const String changePassword = '/api/auth/change-password';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String forgotPasswordVerify = '/api/auth/forgot-password/verify';
  
  // PIN Management
  static const String changePin = '/api/auth/change-pin';
  static const String resetPin = '/api/auth/reset-pin';
  static const String resetPinVerify = '/api/auth/reset-pin/verify';
  static const String setPin = '/api/auth/set-pin';
  static const String setPinVerify = '/api/auth/set-pin/verify';
  
  // Registration Status
  static const String checkRegisterStatus = '/api/auth/register/status';
  
  // Admin
  static const String promote = '/api/auth/makeadmin';
  // demote endpoint requires user id in path (e.g. /api/auth/demote/{id})
  static const String demote = '/api/auth/demote';
  
  // USSD
  static const String ussdLogin = '/api/auth/ussd-login';
  
  // ============================================================================
  // ACCOUNT ENDPOINTS
  // ============================================================================
  static const String accounts = '/api/accounts';
  static const String accountTypes = '/api/account-types';
  
  // ============================================================================
  // DASHBOARD ENDPOINTS - ✅ VERIFIED CORRECT
  // ============================================================================
  static const String dashboardUser = '/api/dashboard/user';
  static const String dashboardTransactions = '/api/dashboard/transactions';
  static const String dashboardStats = '/api/dashboard/stats';  
  
  // ============================================================================
  // USER ENDPOINTS
  // ============================================================================
  static const String users = '/api/users';
  static const String userNamesByPhone = '/api/users/user-names-by-phone';
  static const String currentUser = '/api/auth/verify';
  
  // ============================================================================
  // TRANSACTION ENDPOINTS
  // ============================================================================
  static const String transactions = '/api/transactions';
  static const String userTransactions = '/api/dashboard/transactions';
  
  // ============================================================================
  // PAYMENT ENDPOINTS
  // ============================================================================
  static const String initiatePayment = '/api/payment/initiate';
  static const String checkPaymentStatus = '/api/payment/status';
  static const String paymentCallback = '/api/payment/callback';
  static const String stkPushByPhone = '/api/payment/stk-push-by-phone';
  
  // ============================================================================
  // TERMS & CONDITIONS
  // ============================================================================
  static const String termsAndConditions = '/api/terms-and-conditions';
  
  // ============================================================================
  // REPORTS
  // ============================================================================
  static const String reports = '/api/reports';
  static const String generateTransactionReport = '/api/reports/generate-transaction';
  static const String generateCustomerReport = '/api/reports/generate-customer';
  
  // ============================================================================
  // HEALTH CHECK
  // ============================================================================
  static const String health = '/api/health';
  
  // ============================================================================
  // NOTIFICATIONS
  // ============================================================================
  static const String notifications = '/api/notifications';
   
    // ============================================================================
    // BANK DETAILS
    // ============================================================================
    static String getAccountBankDetailsUrl(String accountId) => '$accounts/$accountId/bank-details';
  
    // ============================================================================
    // TRANSACTIONS - USER RECENT DEPOSITS
    // ============================================================================
    static const String userRecentDeposits = '/api/transactions/user/recent-deposits';
  // ============================================================================
  // HELPER METHODS - ACCOUNTS
  // ============================================================================
  
  /// Get account by ID: GET /api/accounts/:id
  static String getAccountUrl(String accountId) => '$accounts/$accountId';

    /// Get transactions for account: GET /api/accounts/:id/transactions
    static String getAccountTransactionsUrl(String accountId) => '$accounts/$accountId/transactions';
  
  /// Add contribution: POST /api/accounts/:id/contribution
  static String getAccountContributionUrl(String accountId) => 
      '$accounts/$accountId/contribution';
  
  /// Add earnings: POST /api/accounts/:id/earnings
  static String getAccountEarningsUrl(String accountId) => 
      '$accounts/$accountId/earnings';
  
  /// Deposit funds: POST /api/accounts/:id/deposit
  static String getAccountDepositUrl(String accountId) => 
      '$accounts/$accountId/deposit';
  
  /// Withdraw funds: POST /api/accounts/:id/withdraw
  static String getAccountWithdrawUrl(String accountId) => 
      '$accounts/$accountId/withdraw';
  
  /// Update status: PUT /api/accounts/:id/status
  static String getAccountStatusUrl(String accountId) => 
      '$accounts/$accountId/status';
  
  /// Get summary: GET /api/accounts/:id/summary
  static String getAccountSummaryUrl(String accountId) => 
      '$accounts/$accountId/summary';
  
  // ============================================================================
  // HELPER METHODS - ACCOUNT TYPES
  // ============================================================================
  
  /// Get account type by ID: GET /api/account-types/:id
  static String getAccountTypeUrl(String accountTypeId) => 
      '$accountTypes/$accountTypeId';
  
  // ============================================================================
  // HELPER METHODS - OTHER
  // ============================================================================
  
  /// Get user by ID
  static String getUserUrl(String userId) => '$users/$userId';
  
  /// Get transaction by ID
  static String getTransactionUrl(String transactionId) => 
      '$transactions/$transactionId';
  
  /// Get payment status
  static String getPaymentStatusUrl(String transactionId) => 
      '$checkPaymentStatus/$transactionId';
  
  /// Get registration status
  static String getRegisterStatusUrl(String transactionId) => 
      '$checkRegisterStatus/$transactionId';
  
  /// Get report by ID
  static String getReportUrl(String reportId) => '$reports/$reportId';
  
  /// Get full URL
  static String getFullUrl(String endpoint) => baseUrl + endpoint;
}  