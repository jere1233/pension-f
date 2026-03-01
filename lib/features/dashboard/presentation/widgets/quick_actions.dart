// lib/features/dashboard/presentation/widgets/quick_actions.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/routes/route_names.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    // 6 cards in a 3-column grid = 2 perfect rows, zero empty cells
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      children: [
        _QuickActionCard(
          icon: Icons.credit_card,
          title: 'Add Plan',
          gradient: AppColors.cardGradient1,
          onTap: () {
            context.push(RouteNames.pensionPlans);
          },
        ),
        _QuickActionCard(
          icon: Icons.file_download,
          title: 'Statement',
          gradient: AppColors.cardGradient2,
          onTap: () {
            context.push(RouteNames.downloadStatement);
          },
        ),
        _QuickActionCard(
          icon: Icons.history,
          title: 'History',
          gradient: AppColors.cardGradient1,
          onTap: () {
            context.push(RouteNames.transactions);
          },
        ),
        _QuickActionCard(
          icon: Icons.trending_up,
          title: 'Goals',
          gradient: AppColors.cardGradient2,
          onTap: () {
            context.push(RouteNames.retirementGoals);
          },
        ),
        _QuickActionCard(
          icon: Icons.description,
          title: 'Reports',
          gradient: AppColors.cardGradient3,
          onTap: () {
            context.push(RouteNames.reports);
          },
        ),
        // NEW: Remove Plan card fills the empty 6th cell
        _QuickActionCard(
          icon: Icons.remove_circle_outline_rounded,
          title: 'Remove Plan',
          gradient: AppColors.cardGradient4,
          onTap: () {
            context.push(RouteNames.pensionPlans);
          },
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}