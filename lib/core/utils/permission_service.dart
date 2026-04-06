import 'package:app_settings/app_settings.dart';

class PermissionService {
  /// Check if SMS permissions are granted
  /// Note: SMS permissions are not declared due to Google Play restrictions
  /// Apps must be the default SMS handler to use READ_SMS/RECEIVE_SMS
  /// This method always returns false as SMS features work in manual entry mode
  static Future<bool> checkSmsPermissions() async {
    try {
      print('SMS permissions disabled - manual entry mode (Google Play compliant)');
      return false; // Graceful degradation
    } catch (e) {
      print('Error checking SMS permissions: $e');
      return false;
    }
  }

  /// Request SMS permissions - disabled for Google Play compliance
  /// Users manually enter transaction details instead
  static Future<PermissionStatus> requestSmsPermissions() async {
    try {
      print('SMS permission requests disabled - using manual entry instead');
      return PermissionStatus.denied; // Return denied since we don't request these
    } catch (e) {
      print('Error requesting SMS permissions: $e');
      return PermissionStatus.denied;
    }
  }

  /// Check if permissions are permanently denied
  static Future<bool> areSmsPermissionsPermanentlyDenied() async {
    try {
      // SMS permissions are disabled by design for Google Play compliance
      return true;
    } catch (e) {
      print('Error checking permanent denial status: $e');
      return true;
    }
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    try {
      await AppSettings.openAppSettings();
    } catch (e) {
      print('Error opening app settings: $e');
    }
  }

  /// Handle permission flow - returns manual mode since SMS permissions are disabled
  static Future<PermissionResult> handleSmsPermissionFlow() async {
    try {
      print('SMS feature disabled - manual transaction entry mode');
      // Return restricted since Google Play doesn't allow these permissions
      return PermissionResult.restricted;
    } catch (e) {
      print('Error in SMS permission flow: $e');
      return PermissionResult.restricted;
    }
  }

  /// Check if SMS functionality can be used
  /// Always returns false since SMS permissions are not requested
  /// Users enter data manually instead
  static Future<bool> canUseSmsFeatures() async {
    try {
      return false; // SMS features disabled by design
    } catch (e) {
      print('SMS features not available: $e');
      return false;
    }
  }
}

// Modified enum to reflect Google Play compliance
enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted, // When Google Play or system restricts the permission
}

enum PermissionResult {
  granted,
  denied,
  permanentlyDenied,
  restricted, // When Google Play or system restricts the permission
}
