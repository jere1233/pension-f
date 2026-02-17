import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/account_provider.dart';
import '../../domain/entities/account.dart';

class DepositModal extends StatefulWidget {
  const DepositModal({super.key});

  @override
  State<DepositModal> createState() => _DepositModalState();
}

class _DepositModalState extends State<DepositModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  Account? _selected;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = context.watch<AccountProvider>();
    final accounts = accountProvider.accounts;

    if (_selected == null && accounts.isNotEmpty) {
      _selected = accountProvider.defaultAccount;
    }

    return AlertDialog(
      title: const Text('Deposit Funds'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (accounts.isNotEmpty)
              DropdownButtonFormField<Account>(
                value: _selected,
                items: accounts.map((a) => DropdownMenuItem(value: a, child: Text('${a.accountNumber} — ${a.accountType}'))).toList(),
                onChanged: (v) => setState(() => _selected = v),
                decoration: const InputDecoration(labelText: 'Account'),
                validator: (v) => v == null ? 'Select an account' : null,
              ),
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
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone (e.g. +2547...)'),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter phone' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        // DISABLED: Deposit action temporarily removed
        /*
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final amount = double.parse(_amountCtrl.text);
            final phone = _phoneCtrl.text;
            if (_selected == null) return;

            final result = await accountProvider.depositFunds(
              accountId: _selected!.id,
              amount: amount,
              phone: phone,
            );

            if (result != null && result['success'] == true) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deposit initiated')));
              Navigator.of(context).pop();
            } else {
              final msg = result?['message'] ?? accountProvider.errorMessage ?? 'Failed to initiate deposit';
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
            }
          },
          child: const Text('Deposit'),
        ),
        */
      ],
    );
  }
}
