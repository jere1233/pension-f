// lib/features/dashboard/presentation/widgets/balance_cards.dart - UPDATED

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../accounts/presentation/providers/account_provider.dart'; 
import '../../../accounts/domain/entities/account.dart'; 
import '../../domain/entities/dashboard_stats.dart';
import '../../../../core/constants/app_colors.dart';

class BalanceCards extends StatelessWidget {
  final DashboardStats? stats;
  final User? user;

  const BalanceCards({
    super.key,
    this.stats,
    this.user,
  });

  int _calculateMonthlyContribution(Account? account) {
    if (account == null) return 0;
    // Calculate based on employee + employer contributions
    return (account.employeeContributions + account.employerContributions).toInt();
  }

  int _calculateYearsToRetirement() {
    // Calculate based on user's date of birth and retirement age (65)
    // This would need dateOfBirth in User entity
    return 35; 
  }

  int _calculateProjectedRetirement(double currentBalance) {
    final years = _calculateYearsToRetirement();
    // Simple 8% annual growth calculation
    return (currentBalance * (1 + 0.08 * years)).toInt();
  }

  @override
  Widget build(BuildContext context) {
    // 🆕 Get account data from AccountProvider
    final accountProvider = context.watch<AccountProvider>();
    final account = accountProvider.defaultAccount;

    // Use real account data if available, fallback to stats
    final balance = account?.currentBalance ?? stats?.balance ?? 0;
    final monthlyContrib = account != null
      ? _calculateMonthlyContribution(account)
      : (stats?.totalContributions ?? 0).toInt();
    final yearsToRetirement = _calculateYearsToRetirement();
    final projectedAt65 = _calculateProjectedRetirement(balance);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _BalanceCard(
          title: 'Total Balance',
          // Per request: show number of logins here — use completedTransactions as fallback
          amount: '${stats?.completedTransactions ?? 0}',
          subtitle: 'total balance across all plans',
          gradient: AppColors.cardGradient1,
          icon: Icons.account_balance_wallet,
        ),
        _BalanceCard(
          title: 'Total Contributions',
          // Per request: show current pension account balance
          amount: 'KES ${_formatAmount(balance)}',
          subtitle: account != null
              ? 'Account: ${account.accountNumber}'
              : 'Across all plans',
          gradient: AppColors.cardGradient2,
          icon: Icons.arrow_downward,
        ),
        _BalanceCard(
          title: 'Total Earnings',
          // Per request: show interest accrued
          amount: 'KES ${_formatAmount(account?.interestEarned ?? 0)}',
          subtitle: account != null
              ? 'Interest: ${_formatAmount(account.interestEarned)}\nReturns: ${_formatAmount(account.investmentReturns)}'
              : 'No earnings yet',
          gradient: AppColors.cardGradient3,
          icon: Icons.trending_up,
        ),
        _BalanceCard(
          title: 'Account Details',
          // Show pension account details as requested
          amount: account != null ? account.accountNumber : 'No account',
          subtitle: account != null ? 'Type: ${account.accountType}' : 'No account available',
          gradient: AppColors.cardGradient4,
          icon: Icons.access_time,
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final LinearGradient gradient;
  final IconData icon;

  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                icon,
                size: 18,
                color: Colors.white60,
              ),
            ],
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white70,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}