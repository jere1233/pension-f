// lib/features/accounts/domain/entities/account.dart

import 'package:equatable/equatable.dart';

class AccountTransaction {
  final String id;
  final String type;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String? description;

  const AccountTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.description,
  });

  factory AccountTransaction.fromJson(Map<String, dynamic> json) {
    return AccountTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'unknown',
      amount: _parseDouble(json['amount']),
      status: json['status']?.toString() ?? 'pending',
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      description: json['description']?.toString(),
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

  bool get isDeposit => type.toLowerCase() == 'deposit';
  bool get isInterest => type.toLowerCase() == 'interest' || type.toLowerCase() == 'interest_earned';
  bool get isCompleted => status.toLowerCase() == 'completed' || status.toLowerCase() == 'success';
}

class Account extends Equatable {
  final int id;
  final String accountNumber;
  final String accountType;
  final String accountStatus;
  final String riskProfile;
  final String currency;
  final double currentBalance;
  final double availableBalance;
  final double lockedBalance;
  final double employeeContributions;
  final double employerContributions;
  final double voluntaryContributions;
  final double interestEarned;
  final double investmentReturns;
  final double dividendsEarned;
  final double totalWithdrawn;
  final double taxWithheld;
  final bool kycVerified;
  final String complianceStatus;
  final DateTime openedAt;
  final DateTime? lastContributionAt;
  final DateTime? lastWithdrawalAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AccountTransaction> transactions;

  const Account({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.accountStatus,
    required this.riskProfile,
    required this.currency,
    required this.currentBalance,
    required this.availableBalance,
    required this.lockedBalance,
    required this.employeeContributions,
    required this.employerContributions,
    required this.voluntaryContributions,
    required this.interestEarned,
    required this.investmentReturns,
    required this.dividendsEarned,
    required this.totalWithdrawn,
    required this.taxWithheld,
    required this.kycVerified,
    required this.complianceStatus,
    required this.openedAt,
    this.lastContributionAt,
    this.lastWithdrawalAt,
    required this.createdAt,
    required this.updatedAt,
    this.transactions = const [],
  });

  // Helper getters
  double get totalContributions =>
      employeeContributions + employerContributions + voluntaryContributions;

  double get totalEarnings =>
      interestEarned + investmentReturns + dividendsEarned;

  // Contribution calculations from transactions with fallback
  double getWeekContributions() {
    if (transactions.isEmpty) {
      // Fallback: use pre-calculated total if no transactions
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      if (lastContributionAt != null && lastContributionAt!.isAfter(weekAgo)) {
        return totalContributions;
      }
      return 0.0;
    }
    // Sum completed deposit transactions from the past 7 days
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return transactions
        .where((tx) => tx.isDeposit && tx.isCompleted && tx.createdAt.isAfter(weekAgo))
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);
  }

  double getYtdContributions() {
    if (transactions.isEmpty) {
      // Fallback: use pre-calculated total if no transactions
      final yearStart = DateTime(DateTime.now().year, 1, 1);
      if (lastContributionAt != null && lastContributionAt!.isAfter(yearStart)) {
        return totalContributions;
      }
      return 0.0;
    }
    // Sum completed deposit transactions from Jan 1 to now
    final yearStart = DateTime(DateTime.now().year, 1, 1);
    return transactions
        .where((tx) => tx.isDeposit && tx.isCompleted && tx.createdAt.isAfter(yearStart))
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);
  }

  double getTotalInterestEarned() {
    if (transactions.isEmpty) {
      // Fallback: use pre-calculated interest
      return interestEarned;
    }
    // Sum completed interest transactions
    final interest = transactions
        .where((tx) => tx.isInterest && tx.isCompleted)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);
    // Return max of calculated interest or pre-calculated (in case some is not in transactions)
    return interest > 0 ? interest : interestEarned;
  }

  bool get isActive => accountStatus.toUpperCase() == 'ACTIVE';
  bool get isSuspended => accountStatus.toUpperCase() == 'SUSPENDED';
  bool get isClosed => accountStatus.toUpperCase() == 'CLOSED';
  bool get isFrozen => accountStatus.toUpperCase() == 'FROZEN';

  bool get isMandatory => accountType.toUpperCase() == 'MANDATORY';
  bool get isVoluntary => accountType.toUpperCase() == 'VOLUNTARY';
  bool get isEmployer => accountType.toUpperCase() == 'EMPLOYER';

  @override
  List<Object?> get props => [
        id,
        accountNumber,
        accountType,
        accountStatus,
        riskProfile,
        currency,
        currentBalance,
        availableBalance,
        lockedBalance,
        employeeContributions,
        employerContributions,
        voluntaryContributions,
        interestEarned,
        investmentReturns,
        dividendsEarned,
        totalWithdrawn,
        taxWithheld,
        kycVerified,
        complianceStatus,
        openedAt,
        lastContributionAt,
        lastWithdrawalAt,
        createdAt,
        updatedAt,
        transactions,
      ];

  Account copyWith({
    int? id,
    String? accountNumber,
    String? accountType,
    String? accountStatus,
    String? riskProfile,
    String? currency,
    double? currentBalance,
    double? availableBalance,
    double? lockedBalance,
    double? employeeContributions,
    double? employerContributions,
    double? voluntaryContributions,
    double? interestEarned,
    double? investmentReturns,
    double? dividendsEarned,
    double? totalWithdrawn,
    double? taxWithheld,
    bool? kycVerified,
    String? complianceStatus,
    DateTime? openedAt,
    DateTime? lastContributionAt,
    DateTime? lastWithdrawalAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AccountTransaction>? transactions,
  }) {
    return Account(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      accountType: accountType ?? this.accountType,
      accountStatus: accountStatus ?? this.accountStatus,
      riskProfile: riskProfile ?? this.riskProfile,
      currency: currency ?? this.currency,
      currentBalance: currentBalance ?? this.currentBalance,
      availableBalance: availableBalance ?? this.availableBalance,
      lockedBalance: lockedBalance ?? this.lockedBalance,
      employeeContributions: employeeContributions ?? this.employeeContributions,
      employerContributions: employerContributions ?? this.employerContributions,
      voluntaryContributions: voluntaryContributions ?? this.voluntaryContributions,
      interestEarned: interestEarned ?? this.interestEarned,
      investmentReturns: investmentReturns ?? this.investmentReturns,
      dividendsEarned: dividendsEarned ?? this.dividendsEarned,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      taxWithheld: taxWithheld ?? this.taxWithheld,
      kycVerified: kycVerified ?? this.kycVerified,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      openedAt: openedAt ?? this.openedAt,
      lastContributionAt: lastContributionAt ?? this.lastContributionAt,
      lastWithdrawalAt: lastWithdrawalAt ?? this.lastWithdrawalAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactions: transactions ?? this.transactions,
    );
  }
}