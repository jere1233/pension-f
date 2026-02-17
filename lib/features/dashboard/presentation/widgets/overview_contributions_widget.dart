import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../../core/constants/app_colors.dart';

class OverviewContributionsWidget extends StatefulWidget {
  const OverviewContributionsWidget({super.key});

  @override
  State<OverviewContributionsWidget> createState() => _OverviewContributionsWidgetState();
}

class _OverviewContributionsWidgetState extends State<OverviewContributionsWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountProvider>().accounts;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final yearStart = DateTime(now.year, 1, 1);

    double weekTotal = 0;
    double ytdTotal = 0;
    double totalInterest = 0;
    double totalContributions = 0;

    for (final acc in accounts) {
      // Only count contributions for active accounts
      if (!acc.isActive) continue;
      // Weekly
      if (acc.lastContributionAt != null && acc.lastContributionAt!.isAfter(weekAgo)) {
        weekTotal += acc.totalContributions;
      }
      // YTD
      if (acc.lastContributionAt != null && acc.lastContributionAt!.isAfter(yearStart)) {
        ytdTotal += acc.totalContributions;
      }
      totalInterest += acc.interestEarned;
      totalContributions += acc.totalContributions;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatTile(label: 'This Week', value: weekTotal),
                _StatTile(label: 'Year to Date', value: ytdTotal),
              ],
            ),
            const SizedBox(height: 24),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Interest'),
                Tab(text: 'Total Contribution'),
              ],
            ),
            SizedBox(
              height: 80,
              child: TabBarView(
                controller: _tabController,
                children: [
                  Center(
                    child: Text(
                      'KES ${totalInterest.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  Center(
                    child: Text(
                      'KES ${totalContributions.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final double value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          'KES ${value.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
        ),
      ],
    );
  }
}
