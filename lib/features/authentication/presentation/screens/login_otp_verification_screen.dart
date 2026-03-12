import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/routes/route_names.dart';
import '../widgets/custom_button.dart';
import '../widgets/password_text_field.dart';
import '../providers/auth_provider.dart';

class LoginOtpVerificationScreen extends StatefulWidget {
  final String identifier;
  final String verificationType;

  const LoginOtpVerificationScreen({
    super.key,
    required this.identifier,
    required this.verificationType,
  });

  @override
  State<LoginOtpVerificationScreen> createState() => _LoginOtpVerificationScreenState();
}

class _LoginOtpVerificationScreenState extends State<LoginOtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final _newPasswordController = TextEditingController();
  
  bool _showPasswordField = false;
  
  // Timer variables for resend OTP
  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // auto-focus the first OTP box when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _newPasswordController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });
    
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.resendOtp(widget.identifier);
    
    if (success && mounted) {
      Fluttertoast.showToast(
        msg: "OTP has been resent to ${widget.identifier}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
      
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      
      _startResendTimer();
    } else if (mounted) {
      final err = (authProvider.errorMessage ?? '').toLowerCase();
      String message = authProvider.errorMessage ?? "Failed to resend OTP";

      if (err.contains('not found') || err.contains('invalid identifier')) {
        message = '❌ User not found. Please check your identifier.';
      } else if (err.contains('expired')) {
        message = '⏰ Previous OTP expired. A new one has been sent.';
      } else if (err.contains('no otp') || err.contains('not found')) {
        message = '⚠️ No OTP found. Please log in again to get an OTP.';
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.errorLight,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    
      if (otp.length != 6) {
      Fluttertoast.showToast(
        msg: "Please enter the complete OTP",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.warningLight,
        textColor: Colors.white,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    
    final newPassword = _showPasswordField ? _newPasswordController.text : null;
    
    if (_showPasswordField && (newPassword == null || newPassword.length < 8)) {
      Fluttertoast.showToast(
        msg: "Password must be at least 8 characters",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.warningLight,
        textColor: Colors.white,
      );
      return;
    }

    final success = await authProvider.verifyLoginOtp(otp, newPassword: newPassword);

    if (success && mounted) {
      Fluttertoast.showToast(
        msg: "Login successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );
      context.go(RouteNames.home);
    } else if (mounted) {
      if (authProvider.status == AuthStatus.tempPasswordRequired && !_showPasswordField) {
        setState(() {
          _showPasswordField = true;
        });
        Fluttertoast.showToast(
          msg: "Please set a permanent password to continue",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.info,
          textColor: Colors.white,
        );
      } else {
        final err = (authProvider.errorMessage ?? '').toLowerCase();
        if (err.contains('expired')) {
          Fluttertoast.showToast(
            msg: "⏰ OTP has expired. Please request a new one.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.errorLight,
            textColor: Colors.white,
          );
        } else if (err.contains('invalid')) {
          Fluttertoast.showToast(
            msg: "❌ Invalid OTP. Please check and try again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.errorLight,
            textColor: Colors.white,
          );
        } else if (err.contains('too many')) {
          Fluttertoast.showToast(
            msg: "🔒 Too many failed attempts. Please try login again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.errorLight,
            textColor: Colors.white,
          );
        } else {
          _showErrorDialog(authProvider.errorMessage ?? 'Invalid OTP');
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red.shade400,
                    size: 40,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Verification Failed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth > 600 ? 40 : 24,
                  vertical: keyboardVisible ? 20 : 40,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(keyboardVisible),
                      
                      SizedBox(height: keyboardVisible ? 20 : 40),
                      
                      _buildMainCard(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool keyboardVisible) {
    return Column(
      children: [
        if (!keyboardVisible) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentOrange.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentOrange.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.email_outlined,
              size: 60,
              color: Color(0xFFE8744F),
            ),
          ),
          const SizedBox(height: 24),
        ],
        
        Text(
          _showPasswordField ? 'Set Your Password' : 'Verify Your Email',
          style: TextStyle(
            fontSize: keyboardVisible ? 28 : 36,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1a1a1a),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          _showPasswordField
              ? 'Enter OTP and create a secure password'
              : 'Enter the 6-digit code sent to\n${widget.identifier}',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE8744F).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: AppColors.accentOrange.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final spacing = 6.0;
              final totalSpacing = spacing * 5;
              final boxWidth = (availableWidth - totalSpacing) / 6;
              final boxSize = boxWidth.clamp(40.0, 50.0);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: boxSize,
                    height: 50,
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1a1a1a),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFFDF6F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: const Color(0xFFE8D5C4), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8744F),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(0),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Code expires in 10 minutes',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ), 
          if (_showPasswordField) ...[
            const SizedBox(height: 18),
            PasswordTextField(
              controller: _newPasswordController,
              labelText: 'New Password',
              hintText: 'Enter new password (min 8 characters)',
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
          ],
          
          const SizedBox(height: 20),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE8744F),
                      Color(0xFFD85B42),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8744F).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleVerifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _showPasswordField ? 'Set Password & Login' : 'Verify',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: Divider(color: const Color(0xFFE8D5C4), thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Resend Code',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF999999),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: const Color(0xFFE8D5C4), thickness: 1),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final canResendNow = _canResend && !authProvider.isLoading;
              
              return InkWell(
                onTap: canResendNow ? _handleResendOtp : null,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: canResendNow ? const Color(0xFFE8744F) : const Color(0xFFE8D5C4),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFFFDF6F0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 22,
                        color: canResendNow ? const Color(0xFFE8744F) : const Color(0xFF999999),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _canResend 
                            ? 'Resend Code' 
                            : 'Resend in ${_resendCountdown}s',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: canResendNow ? const Color(0xFFE8744F) : const Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}