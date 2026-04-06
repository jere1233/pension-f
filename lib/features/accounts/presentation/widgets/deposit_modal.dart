import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/sms_permission_dialog.dart';
import '../../../../core/utils/permission_service.dart';
import '../providers/account_provider.dart';

class DepositModal extends StatefulWidget {
  const DepositModal({super.key});

  @override
  State<DepositModal> createState() => _DepositModalState();
}

class _DepositModalState extends State<DepositModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedPlanId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();

    return AlertDialog(
      title: const Text('Deposit Funds'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pension Plan Selection (Optional)
            DropdownButtonFormField<String>(
              value: _selectedPlanId,
              items: const [
                DropdownMenuItem(value: 'basic', child: Text('Basic Plan')),
                DropdownMenuItem(value: 'growth', child: Text('Growth Plan')),
                DropdownMenuItem(value: 'premium', child: Text('Premium Plan')),
              ],
              onChanged: (v) => setState(() => _selectedPlanId = v),
              decoration:
                  const InputDecoration(labelText: 'Pension Plan (Optional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (KES)'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter amount';
                final val = double.tryParse(v);
                if (val == null || val <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(labelText: 'Phone (e.g. +2547...)'),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter phone' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed:
              _isSubmitting ? null : () => _handleDeposit(accountProvider),
          child: _isSubmitting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white)),
                )
              : const Text('Deposit'),
        ),
      ],
    );
  }

  Future<void> _handleDeposit(AccountProvider accountProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Check SMS permissions before proceeding
    final hasPermissions = await PermissionService.checkSmsPermissions();
    if (!hasPermissions) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SmsPermissionDialog(
          onPermissionGranted: () => _proceedWithDeposit(accountProvider),
          onPermissionDenied: () => _proceedWithDeposit(
              accountProvider), // Allow deposit even without permissions
        ),
      );
      return;
    }

    // Permissions granted, proceed directly
    _proceedWithDeposit(accountProvider);
  }

  Future<void> _proceedWithDeposit(AccountProvider accountProvider) async {
    setState(() => _isSubmitting = true);

    final amount = double.parse(_amountCtrl.text);
    final phone = _phoneCtrl.text;

    // Build description matching web version: "Contribution to [planId]"
    final description = _selectedPlanId != null
        ? 'Contribution to $_selectedPlanId'
        : 'Pension contribution';

    final result = await accountProvider.depositFunds(
      amount: amount,
      phone: phone,
      planId: _selectedPlanId,
      description: description,
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result != null && result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('✅ Payment request sent. Please enter your M-Pesa PIN.')),
      );
      Navigator.of(context).pop();
    } else {
      final msg = result?['message'] ??
          accountProvider.errorMessage ??
          'Failed to initiate deposit';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $msg')),
      );
    }
  }
}
