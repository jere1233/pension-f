import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/routes/route_names.dart';
import '../widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class PaymentStatusScreen extends StatefulWidget {
  final String transactionId;

  const PaymentStatusScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  Timer? _statusCheckTimer;
  int _checkAttempts = 0;
  final int _maxAttempts = 20; // Check for ~2 minutes (6 seconds * 20)
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startStatusCheck();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusCheck() {
    // Start checking payment status every 6 seconds
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_checkAttempts >= _maxAttempts) {
        timer.cancel();
        _showTimeoutDialog();
        return;
      }
      _checkPaymentStatus();
      _checkAttempts++;
    });

    // Also check immediately
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.checkRegistrationStatus(widget.transactionId);

    setState(() => _isChecking = false);

    if (success && mounted) {
      _statusCheckTimer?.cancel();
      
      Fluttertoast.showToast(
        msg: "Payment successful! Please set your permanent password.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );

      context.go(RouteNames.setPermanentPassword);
    }
  }

  void _showTimeoutDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Status'),
        content: const Text(
          'We\'re still waiting for payment confirmation. You can continue checking or proceed to login if payment was completed.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteNames.login);
            },
            child: const Text('Go to Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _checkAttempts = 0;
                _startStatusCheck();
              });
            },
            child: const Text('Continue Checking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.authBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.payment,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Title
                const Text(
                  'Payment Processing',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'Please complete the M-Pesa payment on your phone.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Loading Indicator
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Status Text
                Text(
                  'Checking payment status...',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Attempt ${_checkAttempts + 1} of $_maxAttempts',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Steps to complete payment:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Check your phone for M-Pesa prompt\n'
                        '2. Enter your M-Pesa PIN\n'
                        '3. Wait for confirmation\n'
                        '4. We\'ll automatically complete your registration',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Manual Check Button
                CustomButton(
                  text: 'Check Payment Status',
                  onPressed: _isChecking ? null : _checkPaymentStatus,
                  isLoading: _isChecking,
                  backgroundColor: Colors.white,
                  textColor: AppColors.primary,
                ),
                
                const SizedBox(height: 16),
                
                // Cancel Button
                TextButton(
                  onPressed: () {
                    _statusCheckTimer?.cancel();
                    context.go(RouteNames.login);
                  },
                  child: const Text(
                    'Cancel & Return to Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}