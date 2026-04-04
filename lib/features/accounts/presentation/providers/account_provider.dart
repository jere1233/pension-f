// lib/features/accounts/presentation/providers/account_provider.dart

import 'package:flutter/material.dart';
import '../../domain/entities/account.dart';
import '../../data/services/account_service.dart';
import '../../data/models/account_model.dart';

enum AccountStatus {
  initial,
  loading,
  loaded,
  error,
}

class AccountProvider extends ChangeNotifier {
  final AccountService _accountService;

  AccountProvider({required AccountService accountService})
      : _accountService = accountService;

  // State
  AccountStatus _status = AccountStatus.initial;
  List<Account> _accounts = [];
  Account? _selectedAccount;
  Map<String, dynamic>? _accountSummary;
  final Map<int, Map<String, dynamic>?> _bankDetailsCache = {};
  String? _errorMessage;

  // Getters
  AccountStatus get status => _status;
  List<Account> get accounts => _accounts;
  Account? get selectedAccount => _selectedAccount;
  Map<String, dynamic>? get accountSummary => _accountSummary;
  Map<int, Map<String, dynamic>?> get bankDetailsCache => _bankDetailsCache;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AccountStatus.loading;
  bool get hasAccounts => _accounts.isNotEmpty;

  // Get default account (first MANDATORY account or first account)
  Account? get defaultAccount {
    if (_accounts.isEmpty) return null;
    
    // Try to find MANDATORY account
    try {
      return _accounts.firstWhere(
        (account) => account.accountType.toUpperCase() == 'MANDATORY'
      );
    } catch (e) {
      // If no MANDATORY account, return first account
      return _accounts.first;
    }
  }

  // Calculate total balance across all accounts
  double get totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.currentBalance);
  }

  // Calculate total contributions
  double get totalContributions {
    return _accounts.fold(0.0, (sum, account) => sum + account.totalContributions);
  }

  // Calculate total earnings
  double get totalEarnings {
    return _accounts.fold(0.0, (sum, account) => sum + account.totalEarnings);
  }

  /// Fetch all accounts
  Future<void> fetchAccounts() async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final accountModels = await _accountService.getAccounts();
      _accounts = accountModels.map((model) => model.toEntity()).toList();
      
      // Set selected account to default if not set
      if (_selectedAccount == null && _accounts.isNotEmpty) {
        _selectedAccount = defaultAccount;
      }

      _status = AccountStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Fetch account by ID
  Future<void> fetchAccountById(int id) async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final accountModel = await _accountService.getAccountById(id);
      _selectedAccount = accountModel.toEntity();

      // Update account in list if it exists
      final index = _accounts.indexWhere((acc) => acc.id == id);
      if (index != -1) {
        _accounts[index] = _selectedAccount!;
      }

      _status = AccountStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Fetch bank details for an account
  Future<Map<String, dynamic>?> fetchBankDetails(int accountId) async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final details = await _accountService.getBankDetails(accountId);
      _bankDetailsCache[accountId] = details;

      _status = AccountStatus.loaded;
      notifyListeners();
      return details;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Create or update bank details
  Future<bool> saveBankDetails({
    required int accountId,
    required String bankAccountName,
    required String bankAccountNumber,
    String? bankBranchName,
    String? bankBranchCode,
  }) async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final details = await _accountService.createOrUpdateBankDetails(
        accountId: accountId,
        bankAccountName: bankAccountName,
        bankAccountNumber: bankAccountNumber,
        bankBranchName: bankBranchName,
        bankBranchCode: bankBranchCode,
      );

      _bankDetailsCache[accountId] = details;
      _status = AccountStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update bank details (PUT)
  Future<bool> updateBankDetails({
    required int accountId,
    required String bankAccountName,
    required String bankAccountNumber,
    String? bankBranchName,
    String? bankBranchCode,
  }) async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final details = await _accountService.updateBankDetails(
        accountId: accountId,
        bankAccountName: bankAccountName,
        bankAccountNumber: bankAccountNumber,
        bankBranchName: bankBranchName,
        bankBranchCode: bankBranchCode,
      );

      _bankDetailsCache[accountId] = details;
      _status = AccountStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Delete bank details
  Future<bool> deleteBankDetails(int accountId) async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final success = await _accountService.deleteBankDetails(accountId);
      if (success) {
        _bankDetailsCache.remove(accountId);
      }

      _status = AccountStatus.loaded;
      notifyListeners();
      return success;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Add contribution
  Future<bool> addContribution({
    required int accountId,
    required double employeeAmount,
    double? employerAmount,
    String? description,
  }) async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final accountModel = await _accountService.addContribution(
        accountId: accountId,
        employeeAmount: employeeAmount,
        employerAmount: employerAmount,
        description: description,
      );

      // Update account in list
      final account = accountModel.toEntity();
      final index = _accounts.indexWhere((acc) => acc.id == accountId);
      if (index != -1) {
        _accounts[index] = account;
      }

      if (_selectedAccount?.id == accountId) {
        _selectedAccount = account;
      }

      _status = AccountStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// 🆕 Deposit funds (M-Pesa STK Push)
  Future<Map<String, dynamic>?> depositFunds({
    required double amount,
    String? phone,
    String? description,
    String? planId,
  }) async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _accountService.depositFunds(
        amount: amount,
        phone: phone,
        description: description,
        planId: planId,
      );

      _status = AccountStatus.loaded;
      notifyListeners();
      
      return result;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Add earnings (interest, investment returns, dividends)
  Future<bool> addEarnings({
    required int accountId,
    required String type,
    required double amount,
    String? description,
  }) async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final accountModel = await _accountService.addEarnings(
        accountId: accountId,
        type: type,
        amount: amount,
        description: description,
      );

      // Update account in list
      final account = accountModel.toEntity();
      final index = _accounts.indexWhere((acc) => acc.id == accountId);
      if (index != -1) {
        _accounts[index] = account;
      }

      if (_selectedAccount?.id == accountId) {
        _selectedAccount = account;
      }

      _status = AccountStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Withdraw funds
  Future<bool> withdrawFunds({
    required int accountId,
    required double amount,
    required String withdrawalType,
    String? description,
  }) async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final accountModel = await _accountService.withdrawFunds(
        accountId: accountId,
        amount: amount,
        withdrawalType: withdrawalType,
        description: description,
      );

      // Update account in list
      final account = accountModel.toEntity();
      final index = _accounts.indexWhere((acc) => acc.id == accountId);
      if (index != -1) {
        _accounts[index] = account;
      }

      if (_selectedAccount?.id == accountId) {
        _selectedAccount = account;
      }

      _status = AccountStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Update account status
  Future<bool> updateAccountStatus({
    required int accountId,
    required String accountStatus,
  }) async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final accountModel = await _accountService.updateAccountStatus(
        accountId: accountId,
        accountStatus: accountStatus,
      );

      // Update account in list
      final account = accountModel.toEntity();
      final index = _accounts.indexWhere((acc) => acc.id == accountId);
      if (index != -1) {
        _accounts[index] = account;
      }

      if (_selectedAccount?.id == accountId) {
        _selectedAccount = account;
      }

      _status = AccountStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Fetch account summary
  Future<void> fetchAccountSummary(int accountId) async {
    try {
      _status = AccountStatus.loading;
      _errorMessage = null;
      notifyListeners();

      _accountSummary = await _accountService.getAccountSummary(accountId);

      _status = AccountStatus.loaded;
      notifyListeners();
    } catch (e) {
      _status = AccountStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Select an account
  void selectAccount(Account account) {
    _selectedAccount = account;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh accounts
  Future<void> refresh() async {
    await fetchAccounts();
  }

  /// Clear all data
  void clearData() {
    _accounts = [];
    _selectedAccount = null;
    _accountSummary = null;
    _errorMessage = null;
    _status = AccountStatus.initial;
    notifyListeners();
  }
}