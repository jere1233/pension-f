///home/hp/JERE/pension-frontend/lib/features/accounts/data/services/account_service.dart

import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/account_model.dart';

class AccountService {
  final ApiClient _apiClient;

  AccountService({ApiClient? apiClient}) 
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================================
  // ACCOUNT CRUD OPERATIONS
  // ============================================================================

  /// Get all accounts for the current user
  /// GET /api/accounts
  Future<List<AccountModel>> getAccounts() async {
    try {
      final response = await _apiClient.get(ApiConstants.accounts);

      if (response.statusCode == 200) {
        final data = response.data;
        final accountsData = data['accounts'] as List;
        return accountsData.map((json) => AccountModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch accounts');
      }
    } catch (e) {
      throw Exception('Failed to fetch accounts: $e');
    }
  }

  /// Get account details by ID
  /// GET /api/accounts/:id
  Future<AccountModel> getAccountById(int id) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getAccountUrl(id.toString()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AccountModel.fromJson(data['account']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch account');
      }
    } catch (e) {
      throw Exception('Failed to fetch account: $e');
    }
  }

  // ============================================================================
  // CONTRIBUTIONS (🆕 NEW)
  // ============================================================================

  /// Add contribution to account
  /// POST /api/accounts/:id/contribution
  Future<AccountModel> addContribution({
    required int accountId,
    required double employeeAmount,
    double? employerAmount,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.getAccountContributionUrl(accountId.toString()),
        data: {
          'employeeAmount': employeeAmount,
          if (employerAmount != null) 'employerAmount': employerAmount,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AccountModel.fromJson(data['account']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to add contribution');
      }
    } catch (e) {
      throw Exception('Failed to add contribution: $e');
    }
  }

  // ============================================================================
  // EARNINGS (🆕 NEW)
  // ============================================================================

  /// Add earnings to account (interest, investment returns, dividends)
  /// POST /api/accounts/:id/earnings
  Future<AccountModel> addEarnings({
    required int accountId,
    required String type, // 'interest', 'investment_returns', 'dividends'
    required double amount,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.getAccountEarningsUrl(accountId.toString()),
        data: {
          'type': type,
          'amount': amount,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AccountModel.fromJson(data['account']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to add earnings');
      }
    } catch (e) {
      throw Exception('Failed to add earnings: $e');
    }
  }

  // ============================================================================
  // DEPOSITS (🆕 NEW - M-Pesa Integration)
  // ============================================================================

  /// Deposit funds via M-Pesa STK Push (authenticated)
  /// POST /api/payment/stk-push-by-phone
  /// Looks up account by phone and initiates payment
  Future<Map<String, dynamic>> depositFunds({
    required double amount,
    String? phone,
    String? description,
    String? planId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.stkPushByPhone,
        data: {
          'amount': amount,
          if (phone != null) 'phone': phone,
          if (description != null) 'description': description,
          if (planId != null) 'planId': planId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data['success'] ?? true,
          'message': data['message'],
          'CheckoutRequestID': data['CheckoutRequestID'],
          'transactionId': data['transactionId'],
          'transaction': data['transaction'],
        };
      } else {
        throw Exception(response.data['error'] ?? 'Failed to initiate deposit');
      }
    } catch (e) {
      throw Exception('Failed to deposit funds: $e');
    }
  }

  // ==========================================================================
  // BANK DETAILS
  // ==========================================================================

  /// Get bank details for an account
  /// GET /api/accounts/:id/bank-details
  Future<Map<String, dynamic>?> getBankDetails(int accountId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getAccountBankDetailsUrl(accountId.toString()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Accept either {"bankDetails": {...}} or {"data": {...}}
        if (data is Map<String, dynamic>) {
          return data['bankDetails'] ?? data['data'] ?? {};
        }
        return {};
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch bank details');
      }
    } catch (e) {
      throw Exception('Failed to fetch bank details: $e');
    }
  }

  /// Create or update bank details for an account
  /// POST /api/accounts/:id/bank-details
  Future<Map<String, dynamic>> createOrUpdateBankDetails({
    required int accountId,
    required String bankAccountName,
    required String bankAccountNumber,
    String? bankBranchName,
    String? bankBranchCode,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.getAccountBankDetailsUrl(accountId.toString()),
        data: {
          'bankAccountName': bankAccountName,
          'bankAccountNumber': bankAccountNumber,
          if (bankBranchName != null) 'bankBranchName': bankBranchName,
          if (bankBranchCode != null) 'bankBranchCode': bankBranchCode,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['bankDetails'] ?? data['data'] ?? {};
      } else {
        throw Exception(response.data['error'] ?? 'Failed to save bank details');
      }
    } catch (e) {
      throw Exception('Failed to save bank details: $e');
    }
  }

  /// Update bank details for an account (PUT)
  Future<Map<String, dynamic>> updateBankDetails({
    required int accountId,
    required String bankAccountName,
    required String bankAccountNumber,
    String? bankBranchName,
    String? bankBranchCode,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.getAccountBankDetailsUrl(accountId.toString()),
        data: {
          'bankAccountName': bankAccountName,
          'bankAccountNumber': bankAccountNumber,
          if (bankBranchName != null) 'bankBranchName': bankBranchName,
          if (bankBranchCode != null) 'bankBranchCode': bankBranchCode,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['bankDetails'] ?? data['data'] ?? {};
      } else {
        throw Exception(response.data['error'] ?? 'Failed to update bank details');
      }
    } catch (e) {
      throw Exception('Failed to update bank details: $e');
    }
  }

  /// Delete bank details for an account
  Future<bool> deleteBankDetails(int accountId) async {
    try {
      final response = await _apiClient.delete(
        ApiConstants.getAccountBankDetailsUrl(accountId.toString()),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete bank details: $e');
    }
  }

  // ============================================================================
  // WITHDRAWALS (🆕 NEW)
  // ============================================================================

  /// Withdraw funds from account
  /// POST /api/accounts/:id/withdraw
  Future<AccountModel> withdrawFunds({
    required int accountId,
    required double amount,
    required String withdrawalType,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.getAccountWithdrawUrl(accountId.toString()),
        data: {
          'amount': amount,
          'withdrawalType': withdrawalType,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AccountModel.fromJson(data['account']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to withdraw funds');
      }
    } catch (e) {
      throw Exception('Failed to withdraw funds: $e');
    }
  }

  // ============================================================================
  // ACCOUNT STATUS (🆕 NEW)
  // ============================================================================

  /// Update account status
  /// PUT /api/accounts/:id/status
  Future<AccountModel> updateAccountStatus({
    required int accountId,
    required String accountStatus, // 'ACTIVE', 'SUSPENDED', 'CLOSED', 'FROZEN', 'DECEASED'
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.getAccountStatusUrl(accountId.toString()),
        data: {
          'accountStatus': accountStatus,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return AccountModel.fromJson(data['account']);
      } else {
        throw Exception(response.data['error'] ?? 'Failed to update account status');
      }
    } catch (e) {
      throw Exception('Failed to update account status: $e');
    }
  }

  // ============================================================================
  // ACCOUNT SUMMARY (🆕 NEW)
  // ============================================================================

  /// Get account summary with all balances
  /// GET /api/accounts/:id/summary
  Future<Map<String, dynamic>> getAccountSummary(int accountId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getAccountSummaryUrl(accountId.toString()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['summary'];
      } else {
        throw Exception(response.data['error'] ?? 'Failed to fetch account summary');
      }
    } catch (e) {
      throw Exception('Failed to fetch account summary: $e');
    }
  }
}