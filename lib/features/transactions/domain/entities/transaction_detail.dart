import 'package:equatable/equatable.dart';

class TransactionDetail extends Equatable {
  final String id;
  final String type;
  final double amount;
  final String currency;
  final String status;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? referenceNumber;
  final Map<String, dynamic>? metadata;
  
  // Related entities
  final String? userId;
  final String? vehicleId;
  final String? bookingId;
  
  // Payment details
  final String? paymentMethod;
  final String? paymentProvider;
  final String? paymentReference;
  
  // Additional properties needed by UI
  final String? category;
  final DateTime? timestamp;
  final String? recipientName;
  final String? recipientAccount;
  final String? senderName;
  final String? senderAccount;
  final double? balanceAfter;
  final String? notes;
  final double? contributionPercentage;

  const TransactionDetail({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.referenceNumber,
    this.metadata,
    this.userId,
    this.vehicleId,
    this.bookingId,
    this.paymentMethod,
    this.paymentProvider,
    this.paymentReference,
    this.category,
    this.timestamp,
    this.recipientName,
    this.recipientAccount,
    this.senderName,
    this.senderAccount,
    this.balanceAfter,
    this.notes,
    this.contributionPercentage,
  });

  // Computed properties
  bool get isCredit => type.toLowerCase() == 'credit' || type.toLowerCase() == 'deposit' || type.toLowerCase() == 'income';
  bool get isDebit => type.toLowerCase() == 'debit' || type.toLowerCase() == 'withdrawal' || type.toLowerCase() == 'expense';
  bool get isCompleted => status.toLowerCase() == 'completed' || status.toLowerCase() == 'success';

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        currency,
        status,
        description,
        createdAt,
        updatedAt,
        referenceNumber,
        metadata,
        userId,
        vehicleId,
        bookingId,
        paymentMethod,
        paymentProvider,
        paymentReference,
        category,
        timestamp,
        recipientName,
        recipientAccount,
        senderName,
        senderAccount,
        balanceAfter,
        notes,
      ];
}