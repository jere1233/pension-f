// lib/features/dashboard/presentation/widgets/balance_cards.dart - FIXED LAYOUT

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
    return (account.employeeContributions + account.employerContributions).toInt();
  }

  int _calculateYearsToRetirement() {
    return 35;
  }

  int _calculateProjectedRetirement(double currentBalance) {
    final years = _calculateYearsToRetirement();
    const dailySavings = 100.0;
    const daysPerYear = 365;
    final projectedSavings = dailySavings * daysPerYear * years;
    final growthOnBalance = currentBalance * (1 + 0.08 * years);
    return (growthOnBalance + projectedSavings).toInt();
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final account = accountProvider.defaultAccount;

    // Calculate totals from all active accounts
    double totalBalance = 0;
    double totalAvailableBalance = 0;
    double totalLockedBalance = 0;
    double totalInterest = 0;

    for (final acc in accountProvider.accounts) {
      if (!acc.isActive) continue;
      totalBalance += acc.currentBalance;
      totalAvailableBalance += acc.availableBalance;
      totalLockedBalance += acc.lockedBalance;
      totalInterest += acc.getTotalInterestEarned();
    }

    final projectedAt60 = _calculateProjectedRetirement(totalBalance);

    final cards = [
      _BalanceCard(
        title: 'Total Balance',
        amount: 'KES ${_formatAmount(totalBalance)}',
        subtitle: totalBalance > 0
            ? 'Available: KES ${_formatAmount(totalAvailableBalance)}\nLocked: KES ${_formatAmount(totalLockedBalance)}'
            : 'No balance',
        gradient: AppColors.cardGradient1,
        icon: Icons.account_balance_wallet,
      ),
      _BalanceCard(
        title: 'Total Interest Earned',
        amount: 'KES ${_formatAmount(totalInterest)}',
        subtitle: account != null
            ? 'Returns: ${_formatAmount(account.investmentReturns)}\nDividends: ${_formatAmount(account.dividendsEarned)}'
            : 'No earnings yet',
        gradient: AppColors.cardGradient2,
        icon: Icons.trending_up,
      ),
      _BalanceCard(
        title: 'Projected @ 60',
        amount: 'KES ${_formatAmount(projectedAt60.toDouble())}',
        subtitle: 'Based on current balance',
        gradient: AppColors.cardGradient3,
        icon: Icons.savings,
      ),
    ];

    return Column(
      children: [
        // Row 1: first 2 cards side by side — IntrinsicHeight ensures equal height
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 12),
              Expanded(child: cards[1]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Row 2: last card spans full width
        SizedBox(
          width: double.infinity,
          child: cards[2],
        ),
      ],
    );
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
        // Use mainAxisSize.min so the card doesn't over-expand vertically
        // but will still stretch to match its sibling via IntrinsicHeight
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 12),
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