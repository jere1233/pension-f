import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class ResetPinScreen extends StatefulWidget {
  const ResetPinScreen({super.key});

  @override
  State<ResetPinScreen> createState() => _ResetPinScreenState();
}

class _ResetPinScreenState extends State<ResetPinScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  bool _isLoading = false;
  bool _otpSent = false;
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;
  
  int _resendCountdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _requestOtp() async {
    if (_phoneController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final response = await authProvider.requestResetPin(_phoneController.text);
      
      if (response['success'] == true) {
        setState(() => _otpSent = true);
        _startResendCountdown();
        Fluttertoast.showToast(
          msg: 'OTP sent to your phone',
          backgroundColor: AppColors.success,
        );
      } else {
        String err = (response['message'] ?? '').toLowerCase();
        String msg = response['message'] ?? 'Failed to send OTP';
        if (err.contains('expired')) {
          msg = '⏰ Previous code expired – new one sent';
        }
        Fluttertoast.showToast(
          msg: msg,
          backgroundColor: AppColors.error,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: AppColors.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAndResetPin() async {
    if (_otpController.text.length != 6) {
      Fluttertoast.showToast(msg: 'OTP must be 6 digits');
      return;
    }
    
    if (_newPinController.text.length != 4) {
      Fluttertoast.showToast(msg: 'PIN must be 4 digits');
      return;
    }
    
    if (_newPinController.text != _confirmPinController.text) {
      Fluttertoast.showToast(msg: 'PINs do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final response = await authProvider.verifyResetPin(
        _phoneController.text,
        _otpController.text,
        _newPinController.text,
      );
      
      if (response['success'] == true) {
        Fluttertoast.showToast(
          msg: 'PIN reset successfully',
          backgroundColor: AppColors.success,
        );
        if (mounted) context.go('/login');
      } else {
        String err = (response['message'] ?? '').toLowerCase();
        String msg = response['message'] ?? 'Failed to reset PIN';
        if (err.contains('expired') || err.contains('invalid')) {
          msg = '❌ Invalid or expired code. Please request a new OTP.';
        }
        Fluttertoast.showToast(
          msg: msg,
          backgroundColor: AppColors.error,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: AppColors.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final response = await authProvider.requestResetPin(_phoneController.text);
      
      if (response['success'] == true) {
        _startResendCountdown();
        Fluttertoast.showToast(
          msg: 'OTP resent successfully',
          backgroundColor: AppColors.success,
        );
      } else {
        Fluttertoast.showToast(
          msg: response['message'] ?? 'Failed to resend OTP',
          backgroundColor: AppColors.error,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        backgroundColor: AppColors.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _otpSent ? 'Reset PIN' : 'Forgot PIN',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient1,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_open,
                size: 50,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title & Description
            Text(
              _otpSent ? 'Create New PIN' : 'Reset Your PIN',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            Text(
              _otpSent
                  ? 'Enter the OTP and set your new PIN'
                  : 'Enter your phone number to receive a verification code',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            if (!_otpSent) ...[
              // Phone Number Input
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '0712345678',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Send OTP Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Send OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ] else ...[
              // OTP Input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.3),
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Code expires in 10 minutes',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // New PIN
              _buildPinField(
                controller: _newPinController,
                label: 'New PIN',
                obscureText: _obscureNewPin,
                onToggleVisibility: () => setState(() => _obscureNewPin = !_obscureNewPin),
              ),
              
              const SizedBox(height: 20),
              
              // Confirm PIN
              _buildPinField(
                controller: _confirmPinController,
                label: 'Confirm PIN',
                obscureText: _obscureConfirmPin,
                onToggleVisibility: () => setState(() => _obscureConfirmPin = !_obscureConfirmPin),
              ),
              
              const SizedBox(height: 24),
              
              // Resend OTP
              Center(
                child: TextButton(
                  onPressed: _resendCountdown > 0 ? null : _resendOtp,
                  child: Text(
                    _resendCountdown > 0
                        ? 'Resend OTP in ${_resendCountdown}s'
                        : 'Resend OTP',
                    style: TextStyle(
                      color: _resendCountdown > 0 ? Colors.grey : AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Reset PIN Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyAndResetPin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Reset PIN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      obscureText: obscureText,
      maxLength: 4,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 4,
      ),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textSecondary,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}