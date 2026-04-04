import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getAllTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<TransactionModel> getTransactionById(String transactionId);
  
  Future<List<TransactionModel>> searchTransactions(String query);
  
  Future<List<TransactionModel>> getTransactionsByCategory(String category);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final Dio dio;

  TransactionRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TransactionModel>> getAllTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (type != null) queryParams['type'] = type;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await dio.get(
        ApiConstants.userTransactions,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('DEBUG: Transactions API response: $data');
        
        List<dynamic> transactionsList;
        if (data is Map<String, dynamic>) {
          // Try different possible keys for transactions
          transactionsList = data['transactions'] ?? data['data'] ?? data['results'] ?? [];
          print('DEBUG: Found ${transactionsList.length} transactions in response map');
          
          // If transactionsList is still empty but data has other keys, check if data itself contains transaction-like objects
          if (transactionsList.isEmpty && data.isNotEmpty) {
            // Check if the response is wrapped in a success structure like web app
            if (data['success'] == true && data.containsKey('transactions')) {
              transactionsList = data['transactions'] ?? [];
              print('DEBUG: Found transactions in success wrapper: ${transactionsList.length}');
            }
          }
        } else if (data is List) {
          transactionsList = data;
          print('DEBUG: Response is a list with ${transactionsList.length} items');
        } else {
          transactionsList = [];
          print('DEBUG: Unexpected response format: ${data.runtimeType}');
        }

        print('DEBUG: Final transactions list length: ${transactionsList.length}');
        return transactionsList
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      } else {
        print('DEBUG: Transactions API failed with status ${response.statusCode}');
        throw Exception('Failed to load transactions');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load transactions',
      );
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  @override
  Future<TransactionModel> getTransactionById(String transactionId) async {
    try {
      final response = await dio.get(
        ApiConstants.getTransactionUrl(transactionId),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        Map<String, dynamic> transactionData;
        if (data is Map<String, dynamic>) {
          transactionData = data['transaction'] ?? data['data'] ?? data;
        } else {
          throw Exception('Invalid response format');
        }

        return TransactionModel.fromJson(transactionData);
      } else {
        throw Exception('Failed to load transaction details');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load transaction details',
      );
    } catch (e) {
      throw Exception('Failed to load transaction details: $e');
    }
  }

  @override
  Future<List<TransactionModel>> searchTransactions(String query) async {
    try {
      final response = await dio.get(
        ApiConstants.userTransactions,
        queryParameters: {'search': query},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        List<dynamic> transactionsList;
        if (data is Map<String, dynamic>) {
          transactionsList = data['transactions'] ?? data['data'] ?? [];
        } else if (data is List) {
          transactionsList = data;
        } else {
          transactionsList = [];
        }

        return transactionsList
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to search transactions');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception(
        e.response?.data['message'] ?? 'Failed to search transactions',
      );
    } catch (e) {
      throw Exception('Failed to search transactions: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByCategory(
    String category,
  ) async {
    try {
      final response = await dio.get(
        ApiConstants.userTransactions,
        queryParameters: {'category': category},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        List<dynamic> transactionsList;
        if (data is Map<String, dynamic>) {
          transactionsList = data['transactions'] ?? data['data'] ?? [];
        } else if (data is List) {
          transactionsList = data;
        } else {
          transactionsList = [];
        }

        return transactionsList
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load transactions by category');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw Exception(
        e.response?.data['message'] ?? 'Failed to load transactions by category',
      );
    } catch (e) {
      throw Exception('Failed to load transactions by category: $e');
    }
  }
}