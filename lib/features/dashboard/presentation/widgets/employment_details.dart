// lib/features/dashboard/presentation/widgets/employment_details.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../authentication/domain/entities/user.dart';

class EmploymentDetails extends StatelessWidget {
  final User? user;

  const EmploymentDetails({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final employer = user?.employer ?? 'N/A';
    final occupation = user?.occupation ?? 'N/A';
    final salary = user?.salary ?? 0;
    final contributionRate = user?.contributionRate != null
        ? '${user!.contributionRate!.toStringAsFixed(1)}%'
        : 'N/A';
    final retirementAge = user?.retirementAge ?? 60;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Employment Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailRow(label: 'Employer', value: employer),
          _DetailRow(label: 'Occupation', value: occupation),
          _DetailRow(
            label: 'Status',
            value: 'Employed',
            valueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Employed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ),
          _DetailRow(
            label: 'Monthly Salary',
            value: 'KES ${salary.toStringAsFixed(0)}',
          ),
          const Divider(height: 24),
          _DetailRow(
            label: 'Contribution Rate',
            value: contributionRate,
          ),
          if (retirementAge > 0)
            _DetailRow(
              label: 'Retirement Age',
              value: retirementAge.toString(),
            ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          valueWidget ??
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
        ],
      ),
    );
  }
}