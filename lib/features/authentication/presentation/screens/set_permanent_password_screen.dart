import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/routes/route_names.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class SetPermanentPasswordScreen extends StatefulWidget {
  const SetPermanentPasswordScreen({super.key});

  @override
  State<SetPermanentPasswordScreen> createState() => _SetPermanentPasswordScreenState();
}

class _SetPermanentPasswordScreenState extends State<SetPermanentPasswordScreen> {
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreedToTerms = false;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character (!@#\$%^&*)';
    }
    return null;
  }

  Future<void> _handleSetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate password
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      setState(() => _passwordError = passwordError);
      return;
    }

    // Check if passwords match
    if (password != confirmPassword) {
      setState(() => _passwordError = 'Passwords do not match');
      return;
    }

    // Check terms agreement
    if (!_agreedToTerms) {
      Fluttertoast.showToast(
        msg: 'Please agree to the terms and conditions',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _passwordError = null);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.setPermanentPassword(password);

    if (success && mounted) {
      Fluttertoast.showToast(
        msg: 'Password set successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.success,
        textColor: Colors.white,
      );

      context.go(RouteNames.home);
    } else if (mounted) {
      setState(() => _passwordError = authProvider.errorMessage ?? 'Failed to set password');
      
      Fluttertoast.showToast(
        msg: authProvider.errorMessage ?? 'Failed to set password',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFAFAFA),
              Color(0xFFF3F4F6),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button and progress
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8744F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE8744F).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFE8744F), size: 20),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8744F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFE8744F).withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: const Text(
                        'Final Step',
                        style: TextStyle(
                          color: Color(0xFFE8744F),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 600 ? 40 : 24,
                    vertical: keyboardVisible ? 12 : 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                              BoxShadow(
                                color: const Color(0xFFE8744F).withOpacity(0.05),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE8744F), Color(0xFFD85B42)],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE8744F).withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.lock_rounded, color: Colors.white, size: 32),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Set Your Password',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create a secure permanent password for your account',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              // Password field
                              CustomTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: Icons.lock_rounded,
                                obscureText: !_showPassword,
                                textInputAction: TextInputAction.next,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    color: Colors.grey.shade400,
                                  ),
                                  onPressed: () => setState(() => _showPassword = !_showPassword),
                                ),
                                validator: (_) => _passwordError,
                              ),
                              const SizedBox(height: 20),
                              // Confirm password field
                              CustomTextField(
                                controller: _confirmPasswordController,
                                labelText: 'Confirm Password',
                                hintText: 'Re-enter your password',
                                prefixIcon: Icons.lock_rounded,
                                obscureText: !_showConfirmPassword,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showConfirmPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    color: Colors.grey.shade400,
                                  ),
                                  onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                                ),
                                validator: (_) => _passwordError,
                              ),
                              const SizedBox(height: 24),
                              // Password requirements info
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFE8744F).withOpacity(0.1),
                                      const Color(0xFFD85B42).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFE8744F).withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8744F).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.info_outline_rounded,
                                            color: Color(0xFFE8744F),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Password Requirements',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFE8744F),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _buildRequirement('At least 8 characters'),
                                    _buildRequirement('One uppercase letter (A-Z)'),
                                    _buildRequirement('One lowercase letter (a-z)'),
                                    _buildRequirement('One number (0-9)'),
                                    _buildRequirement('One special character (!@#\$%^&*)'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Terms acceptance checkbox
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _agreedToTerms,
                                      onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                                      activeColor: const Color(0xFFE8744F),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'I agree to the ',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'Terms and Conditions',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFFE8744F),
                                                  fontWeight: FontWeight.w700,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              // Set Password button
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, _) {
                                  return ElevatedButton(
                                    onPressed: authProvider.isLoading ? null : _handleSetPassword,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE8744F),
                                      disabledBackgroundColor: Colors.grey.shade300,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text(
                                            'Set Permanent Password',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFFE8744F)),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
