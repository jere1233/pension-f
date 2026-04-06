import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/permission_service.dart';
import '../../core/utils/sms_service.dart';

class SmsPermissionDialog extends StatefulWidget {
  final VoidCallback onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const SmsPermissionDialog({
    super.key,
    required this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  State<SmsPermissionDialog> createState() => _SmsPermissionDialogState();
}

class _SmsPermissionDialogState extends State<SmsPermissionDialog> {
  bool _isRequesting = false;
  bool _isOpeningSettings = false;

  Future<void> _requestPermissions() async {
    // SMS permissions disabled by design for Google Play compliance
    // Users will use manual entry instead
    setState(() => _isRequesting = false);

    if (!mounted) return;
    await SmsService.instance.initialize();
    Navigator.of(context).pop();
    widget.onPermissionGranted(); // Continue with manual mode
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'SMS access is needed to automatically detect your M-Pesa transactions. Please allow access to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              widget.onPermissionDenied?.call();
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermissions(); // Try again
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'SMS access has been permanently denied. Please go to app settings and enable SMS permissions to automatically detect your M-Pesa transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              widget.onPermissionDenied?.call();
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: _openSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: _isOpeningSettings
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showRestrictedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('SMS Permission Restricted'),
        content: const Text(
          'SMS access is restricted by Google Play or your device. The app will work without automatic M-Pesa detection. You can manually enter transaction details instead.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              widget.onPermissionDenied?.call();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSettings() async {
    setState(() => _isOpeningSettings = true);

    await PermissionService.openAppSettings();

    setState(() => _isOpeningSettings = false);

    if (!mounted) return;

    // Close dialogs
    Navigator.of(context).pop(); // Close settings dialog
    Navigator.of(context).pop(); // Close main dialog

    // Re-check permissions after returning from settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAfterSettings();
    });
  }

  Future<void> _checkPermissionsAfterSettings() async {
    // Small delay to allow user to return from settings
    await Future.delayed(const Duration(seconds: 1));

    final isGranted = await PermissionService.checkSmsPermissions();

    if (isGranted) {
      widget.onPermissionGranted();
    } else {
      // If still not granted, show the dialog again
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SmsPermissionDialog(
            onPermissionGranted: widget.onPermissionGranted,
            onPermissionDenied: widget.onPermissionDenied,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.info,
            color: AppColors.primary,
            size: 28,
          ),
          SizedBox(width: 12),
          Text('Manual Entry Mode'),
        ],
      ),
      content: const Text(
        'Due to Google Play requirements, automatic SMS detection is not available. You can manually enter your M-Pesa transaction amounts and we\'ll process them instantly.',
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onPermissionGranted(); // Continue with manual mode
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
