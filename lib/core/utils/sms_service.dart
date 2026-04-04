import 'package:telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;
  late ApiClient _apiClient;

  SmsService() {
    _apiClient = ApiClient();
  }

  Future<void> initialize() async {
    // Request permissions
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    if (permissionsGranted != true) {
      print('SMS permissions not granted');
      return;
    }

    // Listen for incoming SMS
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        _processSms(message);
      },
      listenInBackground: false,
    );
  }

  void _processSms(SmsMessage message) {
    // Check if from M-Pesa
    if (message.address == 'MPESA' || message.address == 'M-PESA' || message.address?.contains('MPESA') == true) {
      _parseMpesaSms(message.body ?? '');
    }
  }

  void _parseMpesaSms(String body) {
    // Parse the SMS body for amount and mobile number
    String amount = '';
    String phoneNumber = '';

    // Find amount: "Ksh123.45"
    RegExp amountReg = RegExp(r'Ksh([\d,]+\.?\d{0,2})');
    Match? amountMatch = amountReg.firstMatch(body);
    if (amountMatch != null) {
      // Remove commas and convert
      amount = amountMatch.group(1)!.replaceAll(',', '');
    }

    // Find phone number: "254712345678 or +254712345678"
    // M-Pesa SMS format: "...to 254712345678... from 254712345678..."
    RegExp phoneReg = RegExp(r'(?:to|from)\s*(\+?254\d{9}|\d{9})');
    Match? phoneMatch = phoneReg.firstMatch(body);
    if (phoneMatch != null) {
      phoneNumber = phoneMatch.group(1)!;
      // Ensure E.164 format
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+$phoneNumber';
      }
      if (!phoneNumber.startsWith('+254')) {
        phoneNumber = '+254${phoneNumber.substring(phoneNumber.length - 9)}';
      }
    }

    if (amount.isNotEmpty && phoneNumber.isNotEmpty) {
      _getAccountData().then((accountData) {
        if (accountData != null) {
          final accountId = accountData['accountId'];
          final userId = accountData['userId'];
          
          if (accountId != null && userId != null) {
            _initiateStkPush(
              amount: amount,
              phone: phoneNumber,
              accountId: accountId,
              userId: userId,
            );
          }
        }
      });
    }
  }

  Future<Map<String, String>?> _getAccountData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('user_id');
      String? accountId = prefs.getString('account_id');
      
      if (userId != null && accountId != null) {
        return {
          'userId': userId,
          'accountId': accountId,
        };
      }
      return null;
    } catch (e) {
      print('Error retrieving account data: $e');
      return null;
    }
  }

  Future<void> _initiateStkPush({
    required String amount,
    required String phone,
    required String accountId,
    required String userId,
  }) async {
    try {
      // Show loading toast
      Fluttertoast.showToast(
        msg: '💳 M-Pesa STK Push initiated for KES $amount...',
        toastLength: Toast.LENGTH_SHORT,
      );

      // Call backend STK push endpoint by phone
      final response = await _apiClient.post(
        ApiConstants.stkPushByPhone,
        data: {
          'amount': double.parse(amount),
          'phone': phone,
          'description': 'SMS-triggered deposit - $amount',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final transactionId =
            data['transaction']?['id'] ??
            data['transactionId'] ??
            data['transaction']?['_id'] ??
            data['transaction']?['transactionId'] ??
            'N/A';
        
        Fluttertoast.showToast(
          msg: '✅ STK Push sent! TransactionID: $transactionId',
          toastLength: Toast.LENGTH_LONG,
        );
        
        print('STK Push initiated successfully - TxnID: $transactionId');
      } else {
        Fluttertoast.showToast(
          msg: '❌ Failed to initiate STK Push: ${response.data['error'] ?? 'Unknown error'}',
          toastLength: Toast.LENGTH_LONG,
        );
        print('STK Push failed: ${response.data}');
      }
    } on DioException catch (e) {
      String errorMsg = 'Network error';
      if (e.response != null) {
        errorMsg = e.response?.data['error'] ?? e.message ?? 'Failed to initiate STK Push';
      }
      
      Fluttertoast.showToast(
        msg: '❌ Error: $errorMsg',
        toastLength: Toast.LENGTH_LONG,
      );
      print('STK Push DIO error: $e');
    } catch (e) {
      Fluttertoast.showToast(
        msg: '❌ Unexpected error: $e',
        toastLength: Toast.LENGTH_LONG,
      );
      print('STK Push unexpected error: $e');
    }
  }
}