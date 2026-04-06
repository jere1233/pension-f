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

        final transactionsList = _extractTransactionsList(data);
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
        final transactionsList = _extractTransactionsList(response.data);
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
        final transactionsList = _extractTransactionsList(response.data);
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

  List<dynamic> _extractTransactionsList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      if (data['transactions'] is List) {
        return data['transactions'];
      }

      if (data['data'] is List) {
        return data['data'];
      }

      if (data['results'] is List) {
        return data['results'];
      }

      if (data['data'] is Map<String, dynamic>) {
        final nested = data['data'] as Map<String, dynamic>;
        if (nested['transactions'] is List) {
          return nested['transactions'];
        }
        if (nested['results'] is List) {
          return nested['results'];
        }
      }
    }

    return [];
  }
}