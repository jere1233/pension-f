import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

class PermissionService {
  static const List<Permission> smsPermissions = [
    Permission.sms,
    Permission.phone,
  ];

  /// Check if SMS permissions are granted
  static Future<bool> checkSmsPermissions() async {
    final smsStatus = await Permission.sms.status;
    final phoneStatus = await Permission.phone.status;

    return smsStatus.isGranted && phoneStatus.isGranted;
  }

  /// Request SMS permissions
  static Future<PermissionStatus> requestSmsPermissions() async {
    // Request SMS permission first
    final smsStatus = await Permission.sms.request();

    // If SMS is granted, also request phone permission
    if (smsStatus.isGranted) {
      final phoneStatus = await Permission.phone.request();
      return phoneStatus; // Return phone status as it's the last one
    }

    return smsStatus;
  }

  /// Check if permissions are permanently denied
  static Future<bool> areSmsPermissionsPermanentlyDenied() async {
    final smsStatus = await Permission.sms.status;
    final phoneStatus = await Permission.phone.status;

    return smsStatus.isPermanentlyDenied || phoneStatus.isPermanentlyDenied;
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await AppSettings.openAppSettings();
  }

  /// Handle permission flow: check -> request -> handle denial
  static Future<PermissionResult> handleSmsPermissionFlow() async {
    // First check if already granted
    final isGranted = await checkSmsPermissions();
    if (isGranted) {
      return PermissionResult.granted;
    }

    // Request permissions
    final status = await requestSmsPermissions();

    if (status.isGranted) {
      return PermissionResult.granted;
    } else if (status.isPermanentlyDenied) {
      return PermissionResult.permanentlyDenied;
    } else {
      return PermissionResult.denied;
    }
  }
}

enum PermissionResult {
  granted,
  denied,
  permanentlyDenied,
}
