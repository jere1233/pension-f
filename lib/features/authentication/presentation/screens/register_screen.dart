///home/hp/JERE/AutoNest-frontend/lib/features/authentication/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/routes/route_names.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/phone_text_field.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/numeric_text_field.dart';

import '../widgets/terms_acceptance_checkbox.dart';
import '../widgets/country_dropdown_field.dart';
import '../providers/auth_provider.dart';
import '../../data/models/register_request_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  late final List<GlobalKey<FormState>> _formKeys;
  int _currentStep = 0;
  
  // Step 1: Account Credentials
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  // Step 2: Personal Details
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateOfBirthController;
  String? _gender;
  String? _maritalStatus;
  late TextEditingController _nationalIdController;
  
  // Step 3: Address
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  String? _country = 'Kenya';
  
  // Step 4: Financial & Pension Info
  String? _contributionRate;
  String _accountType = 'MANDATORY';
  
  // Terms and Conditions acceptance
  bool _acceptedTerms = false;
  String? _termsError;

  final List<String> _stepLabels = [
    'Account',
    'Personal',
    'Address',
    'Financial',
  ];
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
    
    // Initialize all text controllers
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _nationalIdController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    // Salary and retirement age inputs removed; system will use defaults
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchTermsAndConditions();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _nationalIdController.dispose();
    _addressController.dispose();
    _cityController.dispose();

    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
          _fadeController.reset();
          _fadeController.forward();
        });
      } else {
        if (!_acceptedTerms) {
          setState(() {
            _termsError = 'You must accept the Terms and Conditions to continue';
          });
          return;
        }
        _handleRegister();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _fadeController.reset();
        _fadeController.forward();
      });
    } else {
      context.pop();
    }
  }

  void _handleTermsTap() {
    final authProvider = context.read<AuthProvider>();
    final terms = authProvider.termsAndConditions;

    if (terms != null && terms.body.isNotEmpty) {
      context.push(
        RouteNames.termsAndConditions,
        extra: {
          'htmlContent': terms.body,
          'showAcceptButton': false,
        },
      );
    } else {
      Fluttertoast.showToast(
        msg: "Loading Terms and Conditions...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.info,
        textColor: Colors.white,
      );
      
      authProvider.fetchTermsAndConditions().then((success) {
        if (success && mounted) {
          _handleTermsTap();
        }
      });
    }
  }

  Future<void> _handleRegister() async {
    final authProvider = context.read<AuthProvider>();
    
    // Convert phone number format: 0700580577 → 254700580577
    String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.startsWith('0')) {
      phoneNumber = '254' + phoneNumber.substring(1);
    } else if (phoneNumber.startsWith('+254')) {
      phoneNumber = phoneNumber.replaceFirst('+', '');
    }
    
    final request = RegisterRequestModel(
      email: _emailController.text.trim(),
      phone: phoneNumber,
      
      firstName: _firstNameController.text.isNotEmpty 
          ? _firstNameController.text.trim() 
          : null,
      lastName: _lastNameController.text.isNotEmpty 
          ? _lastNameController.text.trim() 
          : null,
      dateOfBirth: _dateOfBirthController.text.isNotEmpty 
          ? _dateOfBirthController.text 
          : null,
      gender: _gender,
      maritalStatus: _maritalStatus,
      nationalId: _nationalIdController.text.isNotEmpty 
          ? _nationalIdController.text.trim() 
          : null,
      
      address: _addressController.text.isNotEmpty 
          ? _addressController.text.trim() 
          : null,
      city: _cityController.text.isNotEmpty 
          ? _cityController.text.trim() 
          : null,
      country: _country,
      
        // Salary and risk profile are managed by system; contributionRate is kept
        contributionRate: _contributionRate != null 
          ? num.tryParse(_contributionRate!) 
          : null,
        // Retirement age calculated by system; default to 60
        retirementAge: 60,
        accountType: _accountType,
      currency: 'KES',
      accountStatus: 'ACTIVE',
      kycVerified: false,
      complianceStatus: 'PENDING',
    );

    final initiation = await authProvider.register(request);

    if (initiation.success && mounted) {
      final transactionId = initiation.transactionId ?? authProvider.registrationTransactionId;

      Fluttertoast.showToast(
        msg: initiation.message ?? 'Registration initiated! Please complete M-Pesa payment.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.info,
        textColor: Colors.white,
      );

      if (transactionId != null && transactionId.isNotEmpty) {
        context.go('${RouteNames.paymentStatus}/$transactionId');
      } else {
        context.go(RouteNames.home);
      }
    } else if (mounted) {
      _showErrorDialog(authProvider.errorMessage ?? initiation.message ?? 'Registration failed');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Registration Failed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
          ],
        ),
        content: Text(
          message, 
          style: const TextStyle(fontSize: 15, height: 1.4, color: Color(0xFF6B7280))
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFE8744F),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('OK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
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
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 600 ? 40 : 24,
                    vertical: keyboardVisible ? 12 : 20,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
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
                            child: _buildCurrentStep(),
                          ),
                          
                          const SizedBox(height: 24),
                          _buildNavigationButtons(),
                          
                          if (_currentStep == 0) ...[
                            const SizedBox(height: 24),
                            _buildLoginLink(),
                          ],
                          
                          const SizedBox(height: 20),
                        ],
                      ),
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

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.03),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
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
                  onPressed: _previousStep,
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
                child: Text(
                  'Step ${_currentStep + 1} of 4',
                  style: const TextStyle(
                    color: Color(0xFFE8744F),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(3),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: constraints.maxWidth * ((_currentStep + 1) / 5),
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8744F), Color(0xFFD85B42)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8744F).withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildStep1AccountCredentials();
      case 1:
        return _buildStep2PersonalDetails();
      case 2:
        return _buildStep3Address();
      case 3:
        return _buildStep4FinancialInfo();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1AccountCredentials() {
    return Form(
      key: _formKeys[0],
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
            child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 32),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Create Account',
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
            'Set up your account credentials',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          CustomTextField(
            controller: _emailController,
            labelText: 'Email Address',
            hintText: 'your.email@example.com',
            prefixIcon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          PhoneTextField(
            controller: _phoneController,
            labelText: 'Phone Number (M-Pesa)',
            hintText: '+254712345678',
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (!RegExp(r'^\+254[17]\d{8}$').hasMatch(value)) {
                return 'Enter valid Kenyan number (+254...)';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 24),
          
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
            child: Row(
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
                Expanded(
                  child: Text(
                    'PIN is optional. A temporary password will be sent to your email and phone after payment',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2PersonalDetails() {
    return Form(
      key: _formKeys[1],
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
            child: const Icon(Icons.badge_rounded, color: Colors.white, size: 32),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Personal Details',
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
            'Tell us more about yourself',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          CustomTextField(
            controller: _firstNameController,
            labelText: 'First Name',
            hintText: 'John',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 20),
          
          CustomTextField(
            controller: _lastNameController,
            labelText: 'Last Name',
            hintText: 'Doe',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 20),
          
          DatePickerField(
            controller: _dateOfBirthController,
            labelText: 'Date of Birth',
            hintText: 'Select your date of birth',
            prefixIcon: Icons.cake_rounded,
            lastDate: DateTime.now().subtract(const Duration(days: 6570)),
            initialDate: DateTime.now().subtract(const Duration(days: 9125)),
          ),
          
          const SizedBox(height: 20),
          
          DropdownField(
            value: _gender,
            labelText: 'Gender',
            hintText: 'Select gender',
            prefixIcon: Icons.wc_rounded,
            items: const ['Male', 'Female', 'Other'],
            onChanged: (value) => setState(() => _gender = value),
          ),
          
          const SizedBox(height: 20),
          
          DropdownField(
            value: _maritalStatus,
            labelText: 'Marital Status',
            hintText: 'Select marital status',
            prefixIcon: Icons.favorite_rounded,
            items: const ['Single', 'Married', 'Divorced', 'Widowed'],
            onChanged: (value) => setState(() => _maritalStatus = value),
          ),
          
          const SizedBox(height: 20),
          
          CustomTextField(
            controller: _nationalIdController,
            labelText: 'National ID',
            hintText: '12345678',
            prefixIcon: Icons.credit_card_rounded,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Address() {
    return Form(
      key: _formKeys[2],
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
            child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Your Address',
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
            'Where do you live?',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          CustomTextField(
            controller: _addressController,
            labelText: 'Address',
            hintText: 'Enter your address',
            prefixIcon: Icons.home_rounded,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            maxLines: 2,
          ),
          
          const SizedBox(height: 20),
          
          CustomTextField(
            controller: _cityController,
            labelText: 'City',
            hintText: 'Nairobi',
            prefixIcon: Icons.location_city_rounded,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: 20),
          
          CountryDropdownField(
            value: _country,
            labelText: 'Country',
            hintText: 'Select your country',
            prefixIcon: Icons.flag_rounded,
            onChanged: (value) => setState(() => _country = value),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4FinancialInfo() {
    return Form(
      key: _formKeys[3],
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
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Financial & Pension',
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
            'Set up your pension preferences',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // Contribution Rate (kept)
          const SizedBox(height: 20),
          DropdownField(
            value: _contributionRate,
            labelText: 'Contribution Rate',
            hintText: 'Select contribution rate',
            prefixIcon: Icons.percent_rounded,
            items: const ['2', '5', '10', '15', '20'],
            onChanged: (value) => setState(() => _contributionRate = value),
            displaySuffix: '%',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a contribution rate';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Retirement ages are calculated by the system. Display defaults.
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Retirement Ages',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 8),
                Text('retirement age: 60 years', style: TextStyle(fontSize: 13)),
                SizedBox(height: 4),
                Text('Early retirement age: 55 years', style: TextStyle(fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 20),
          
          const SizedBox(height: 32),
          
          TermsAcceptanceCheckbox(
            value: _acceptedTerms,
            onChanged: (value) {
              setState(() {
                _acceptedTerms = value ?? false;
                if (_acceptedTerms) {
                  _termsError = null;
                }
              });
            },
            onTermsTap: _handleTermsTap,
            errorText: _termsError,
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(18),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8744F).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFE8744F),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Upon registration, you\'ll receive an M-Pesa prompt to pay 1 KES. After successful payment, a temporary password will be sent to your email and phone.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8744F).withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _previousStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8744F).withOpacity(0.1),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE8744F),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8744F), Color(0xFFD85B42)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE8744F).withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _nextStep,
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
                          _currentStep < 5 ? 'Next' : 'Complete Registration',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
        InkWell(
          onTap: () => context.pop(),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE8744F),
              ),
            ),
          ),
        ),
      ],
    );
  }
}