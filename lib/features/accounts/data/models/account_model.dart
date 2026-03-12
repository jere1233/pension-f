// lib/features/accounts/data/models/account_model.dart

import '../../domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.accountNumber,
    required super.accountType,
    required super.accountStatus,
    required super.riskProfile,
    required super.currency,
    required super.currentBalance,
    required super.availableBalance,
    required super.lockedBalance,
    required super.employeeContributions,
    required super.employerContributions,
    required super.voluntaryContributions,
    required super.interestEarned,
    required super.investmentReturns,
    required super.dividendsEarned,
    required super.totalWithdrawn,
    required super.taxWithheld,
    required super.kycVerified,
    required super.complianceStatus,
    required super.openedAt,
    super.lastContributionAt,
    super.lastWithdrawalAt,
    required super.createdAt,
    required super.updatedAt,
    super.transactions = const [],
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    // Parse transactions if available (backend returns array inside account)
    List<AccountTransaction> transactions = [];
    if (json['transactions'] is List) {
      transactions = (json['transactions'] as List)
          .map((tx) => AccountTransaction.fromJson(tx as Map<String, dynamic>))
          .toList();
    }

    return AccountModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] ?? 0),
      accountNumber: json['accountNumber']?.toString() ?? json['account_number']?.toString() ?? '',
      accountType: json['accountType']?.toString() ?? json['account_type']?.toString() ?? 'MANDATORY',
      accountStatus: json['accountStatus']?.toString() ?? json['account_status']?.toString() ?? 'ACTIVE',
      riskProfile: json['riskProfile']?.toString() ?? json['risk_profile']?.toString() ?? 'MEDIUM',
      currency: json['currency']?.toString() ?? 'KES',
      currentBalance: _parseDouble(json['currentBalance'] ?? json['current_balance']),
      availableBalance: _parseDouble(json['availableBalance'] ?? json['available_balance']),
      lockedBalance: _parseDouble(json['lockedBalance'] ?? json['locked_balance']),
      employeeContributions: _parseDouble(json['employeeContributions'] ?? json['employee_contributions']),
      employerContributions: _parseDouble(json['employerContributions'] ?? json['employer_contributions']),
      voluntaryContributions: _parseDouble(json['voluntaryContributions'] ?? json['voluntary_contributions']),
      interestEarned: _parseDouble(json['interestEarned'] ?? json['interest_earned']),
      investmentReturns: _parseDouble(json['investmentReturns'] ?? json['investment_returns']),
      dividendsEarned: _parseDouble(json['dividendsEarned'] ?? json['dividends_earned']),
      totalWithdrawn: _parseDouble(json['totalWithdrawn'] ?? json['total_withdrawn']),
      taxWithheld: _parseDouble(json['taxWithheld'] ?? json['tax_withheld']),
      kycVerified: json['kycVerified'] ?? json['kyc_verified'] ?? false,
      complianceStatus: json['complianceStatus']?.toString() ?? json['compliance_status']?.toString() ?? 'PENDING',
      openedAt: _parseDateTime(json['openedAt'] ?? json['opened_at']) ?? DateTime.now(),
      lastContributionAt: _parseDateTime(json['lastContributionAt'] ?? json['last_contribution_at']),
      lastWithdrawalAt: _parseDateTime(json['lastWithdrawalAt'] ?? json['last_withdrawal_at']),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']) ?? DateTime.now(),
      transactions: transactions,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'accountStatus': accountStatus,
      'riskProfile': riskProfile,
      'currency': currency,
      'currentBalance': currentBalance,
      'availableBalance': availableBalance,
      'lockedBalance': lockedBalance,
      'employeeContributions': employeeContributions,
      'employerContributions': employerContributions,
      'voluntaryContributions': voluntaryContributions,
      'interestEarned': interestEarned,
      'investmentReturns': investmentReturns,
      'dividendsEarned': dividendsEarned,
      'totalWithdrawn': totalWithdrawn,
      'taxWithheld': taxWithheld,
      'kycVerified': kycVerified,
      'complianceStatus': complianceStatus,
      'openedAt': openedAt.toIso8601String(),
      'lastContributionAt': lastContributionAt?.toIso8601String(),
      'lastWithdrawalAt': lastWithdrawalAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Account toEntity() => Account(
        id: id,
        accountNumber: accountNumber,
        accountType: accountType,
        accountStatus: accountStatus,
        riskProfile: riskProfile,
        currency: currency,
        currentBalance: currentBalance,
        availableBalance: availableBalance,
        lockedBalance: lockedBalance,
        employeeContributions: employeeContributions,
        employerContributions: employerContributions,
        voluntaryContributions: voluntaryContributions,
        interestEarned: interestEarned,
        investmentReturns: investmentReturns,
        dividendsEarned: dividendsEarned,
        totalWithdrawn: totalWithdrawn,
        taxWithheld: taxWithheld,
        kycVerified: kycVerified,
        complianceStatus: complianceStatus,
        openedAt: openedAt,
        lastContributionAt: lastContributionAt,
        lastWithdrawalAt: lastWithdrawalAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
        transactions: transactions,
      );

  factory AccountModel.fromEntity(Account account) => AccountModel(
        id: account.id,
        accountNumber: account.accountNumber,
        accountType: account.accountType,
        accountStatus: account.accountStatus,
        riskProfile: account.riskProfile,
        currency: account.currency,
        currentBalance: account.currentBalance,
        availableBalance: account.availableBalance,
        lockedBalance: account.lockedBalance,
        employeeContributions: account.employeeContributions,
        employerContributions: account.employerContributions,
        voluntaryContributions: account.voluntaryContributions,
        interestEarned: account.interestEarned,
        investmentReturns: account.investmentReturns,
        dividendsEarned: account.dividendsEarned,
        totalWithdrawn: account.totalWithdrawn,
        taxWithheld: account.taxWithheld,
        kycVerified: account.kycVerified,
        complianceStatus: account.complianceStatus,
        openedAt: account.openedAt,
        lastContributionAt: account.lastContributionAt,
        lastWithdrawalAt: account.lastWithdrawalAt,
        createdAt: account.createdAt,
        updatedAt: account.updatedAt,
        transactions: account.transactions,
      );
}