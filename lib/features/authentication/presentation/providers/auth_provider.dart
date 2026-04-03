///home/hp/JERE/AutoNest-frontend/lib/features/authentication/presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/storage/secure_storage_helper.dart';
import '../../../../core/constants/api_constants.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/register_request_model.dart';
import '../../data/models/register_initiation_response_model.dart';
import '../../data/models/terms_and_conditions_model.dart';
import '../../domain/entities/user.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  awaitingOtp,
  tempPasswordRequired,
}

class AuthProvider extends ChangeNotifier {
  final AuthRemoteDataSource _authDataSource;
  final Dio _dio;

  AuthProvider({
    required AuthRemoteDataSource authDataSource,
    required Dio dio,
  })  : _authDataSource = authDataSource,
        _dio = dio;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;
  
  // Login flow tracking
  String? _pendingLoginIdentifier;
  String? _pendingLoginOtp;
  
  // Registration payment tracking
  String? _registrationTransactionId;
  String? _registrationCheckoutRequestId;

  // Terms and Conditions
  TermsAndConditionsModel? _termsAndConditions;
  bool _isLoadingTerms = false;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get pendingLoginIdentifier => _pendingLoginIdentifier;
  String? get registrationTransactionId => _registrationTransactionId;
  String? get registrationCheckoutRequestId => _registrationCheckoutRequestId;
  TermsAndConditionsModel? get termsAndConditions => _termsAndConditions;
  bool get isLoadingTerms => _isLoadingTerms;

  // ============================================================================
  // AUTH STATUS CHECK
  // ============================================================================

  Future<void> checkAuthStatus() async {
    try {
      final token = await SecureStorageHelper.read('auth_token');
      if (token != null) {
        _status = AuthStatus.authenticated;
        await getCurrentUser();
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ============================================================================
  // LOGIN FLOW (Two-Step)
  // ============================================================================

  /// Step 1: Initiate login (sends OTP to email/SMS)
  Future<bool> initiateLogin(String identifier, String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final request = LoginRequestModel(identifier: identifier, password: password);
      final response = await _authDataSource.initiateLogin(request);

      if (response['success'] == true) {
        _pendingLoginIdentifier = identifier;
        _status = AuthStatus.awaitingOtp;
        _setLoading(false);
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('Failed to initiate login: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Step 2: Verify OTP (and set permanent password if needed)
  Future<bool> verifyLoginOtp(String otp, {String? newPassword}) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      if (_pendingLoginIdentifier == null) {
        throw Exception('No pending login session');
      }

      final response = await _authDataSource.loginWithOtp(
        _pendingLoginIdentifier!,
        otp,
        newPassword: newPassword,
      );

      await _saveTokens(response);
      _user = response.user.toEntity();
      await _storeUserData(_user!);
      _status = AuthStatus.authenticated;
      _pendingLoginIdentifier = null;
      _pendingLoginOtp = null;

      _setLoading(false);
      return true;
    } on Exception catch (e) {
      final errorMsg = e.toString();
      
      if (errorMsg.contains('TEMP_PASSWORD_REQUIRED')) {
        // User needs to set permanent password
        _pendingLoginOtp = otp;
        _status = AuthStatus.tempPasswordRequired;
        _setLoading(false);
        notifyListeners();
        return false;
      }

      _setLoading(false);
      _errorMessage = errorMsg.replaceAll('Exception: ', '').replaceAll('Failed to verify OTP: ', '');
      _status = AuthStatus.awaitingOtp;
      notifyListeners();
      return false;
    }
  }

  /// Resend OTP to user's email
  Future<bool> resendOtp(String identifier) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _dio.post(
        ApiConstants.getFullUrl(ApiConstants.resendOtp),
        data: {
          'identifier': identifier, // email or phone
        },
      );

      if (response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to resend OTP';
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 
          'Failed to resend OTP. Please try again.';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setLoading(false);
      return false;
    }
  }

  // ============================================================================
  // REGISTRATION FLOW
  // ============================================================================

  /// Initiate registration (M-Pesa payment)
  Future<RegisterInitiationResponseModel> register(RegisterRequestModel request) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _authDataSource.register(request);

      _registrationTransactionId = response.transactionId;
      _registrationCheckoutRequestId = response.checkoutRequestId;

      if (_registrationTransactionId != null) {
        await SecureStorageHelper.write(
          'pending_registration_tx',
          _registrationTransactionId!,
        );
      }

      _setLoading(false);
      return response;
    } catch (e) {
      _setLoading(false);
      final msg = e.toString().replaceAll('Exception: ', '');
      _errorMessage = msg;
      notifyListeners();
      return RegisterInitiationResponseModel(success: false, status: 'failed', message: msg);
    }
  }

  /// Check registration payment status
  Future<bool> checkRegistrationStatus(String transactionId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _authDataSource.checkRegisterStatus(transactionId);

      await _saveTokens(response);
      _user = response.user.toEntity();
      await _storeUserData(_user!);
      _status = AuthStatus.authenticated;
      
      await SecureStorageHelper.delete('pending_registration_tx');
      _registrationTransactionId = null;
      _registrationCheckoutRequestId = null;

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // PASSWORD MANAGEMENT
  // ============================================================================

  /// Change password (authenticated) - Returns Map for compatibility
  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      _setLoading(false);
      return {
        'success': true,
        'message': 'Password changed successfully',
      };
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage ?? 'Failed to change password',
      };
    }
  }

  /// Request password reset OTP
  Future<bool> forgotPassword(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authDataSource.forgotPassword(email);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP and reset password
  Future<bool> forgotPasswordVerify({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authDataSource.forgotPasswordVerify(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // PIN MANAGEMENT (🆕 NEW METHODS FOR SCREENS)
  // ============================================================================

  /// Request OTP to set PIN - Returns Map for screen compatibility
  Future<Map<String, dynamic>> requestSetPin(String pin) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _dio.post(
        ApiConstants.getFullUrl(ApiConstants.setPin),
        data: {'pin': pin},
      );

      _setLoading(false);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP sent to your phone',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to request OTP',
        };
      }
    } on DioException catch (e) {
      _setLoading(false);
      _errorMessage = e.response?.data['message'] ?? 'Failed to request OTP';
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }

  /// Verify OTP and set PIN - Returns Map for screen compatibility
  Future<Map<String, dynamic>> verifySetPin(String pin, String otp) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _dio.post(
        ApiConstants.getFullUrl(ApiConstants.setPinVerify),
        data: {
          'pin': pin,
          'otp': otp,
        },
      );

      _setLoading(false);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'PIN set successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to set PIN',
        };
      }
    } on DioException catch (e) {
      _setLoading(false);
      _errorMessage = e.response?.data['message'] ?? 'Failed to set PIN';
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    } catch (e) {
      _setLoading(false);
      _errorMessage = 'An unexpected error occurred';
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }

  /// Change PIN (authenticated) - Returns Map for screen compatibility
  Future<Map<String, dynamic>> changePin(
    String currentPin,
    String newPin,
  ) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authDataSource.changePin(
        currentPin: currentPin,
        newPin: newPin,
      );

      _setLoading(false);
      return {
        'success': true,
        'message': 'PIN changed successfully',
      };
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage ?? 'Failed to change PIN',
      };
    }
  }

  /// Request PIN reset OTP - Returns Map for screen compatibility
  Future<Map<String, dynamic>> requestResetPin(String phoneNumber) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authDataSource.resetPin(phoneNumber);

      _setLoading(false);
      return {
        'success': true,
        'message': 'OTP sent to your phone',
      };
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage ?? 'Failed to send OTP',
      };
    }
  }

  /// Verify OTP and reset PIN - Returns Map for screen compatibility
  Future<Map<String, dynamic>> verifyResetPin(
    String phoneNumber,
    String otp,
    String newPin,
  ) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authDataSource.resetPinVerify(
        phone: phoneNumber,
        otp: otp,
        newPin: newPin,
      );

      _setLoading(false);
      return {
        'success': true,
        'message': 'PIN reset successfully',
      };
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage ?? 'Failed to reset PIN',
      };
    }
  }

  /// Original PIN management methods (keep for backward compatibility)
  
  /// Request OTP to set PIN (authenticated)
  Future<bool> requestSetPinOtp() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _dio.post(
        ApiConstants.getFullUrl(ApiConstants.setPin),
      );

      if (response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to request OTP';
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to request OTP';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setLoading(false);
      return false;
    }
  }

  /// Verify OTP and set PIN (authenticated)
  Future<bool> setPin({
    required String otp,
    required String pin,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _dio.post(
        ApiConstants.getFullUrl(ApiConstants.setPinVerify),
        data: {
          'otp': otp,
          'pin': pin,
        },
      );

      if (response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to set PIN';
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Failed to set PIN';
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _setLoading(false);
      return false;
    }
  }

  /// Reset PIN (original method)
  Future<bool> resetPin(String phone) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authDataSource.resetPin(phone);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP and reset PIN (original method)
  Future<bool> resetPinVerify({
    required String phone,
    required String otp,
    required String newPin,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authDataSource.resetPinVerify(
        phone: phone,
        otp: otp,
        newPin: newPin,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // USER MANAGEMENT
  // ============================================================================

  /// Get current user
  Future<void> getCurrentUser() async {
    try {
      final userModel = await _authDataSource.getCurrentUser();
      _user = userModel.toEntity();
      await _storeUserData(_user!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authDataSource.logout();
      await _clearTokens();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _pendingLoginIdentifier = null;
      _pendingLoginOtp = null;
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // ============================================================================
  // TERMS & CONDITIONS
  // ============================================================================

  /// Fetch Terms and Conditions from API
  Future<bool> fetchTermsAndConditions() async {
    try {
      _isLoadingTerms = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _authDataSource.getTermsAndConditions();
      _termsAndConditions = TermsAndConditionsModel.fromJson(response);

      _isLoadingTerms = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoadingTerms = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('Failed to fetch terms and conditions: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Get cached terms or fetch if not available
  Future<TermsAndConditionsModel?> getTermsAndConditions() async {
    if (_termsAndConditions != null) {
      return _termsAndConditions;
    }
    
    final success = await fetchTermsAndConditions();
    return success ? _termsAndConditions : null;
  }

  /// Set permanent password (for users with temporary password after registration)
  Future<bool> setPermanentPassword(String password) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authDataSource.setPassword(password: password);

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Save tokens
  Future<void> _saveTokens(AuthResponseModel response) async {
    await SecureStorageHelper.write('auth_token', response.accessToken);
    await SecureStorageHelper.write('refresh_token', response.refreshToken);
  }

  /// Clear tokens
  Future<void> _clearTokens() async {
    await SecureStorageHelper.delete('auth_token');
    await SecureStorageHelper.delete('refresh_token');
    // Clear user data from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_phone');
  }

  /// Store user data in shared preferences
  Future<void> _storeUserData(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_phone', user.phoneNumber);
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}