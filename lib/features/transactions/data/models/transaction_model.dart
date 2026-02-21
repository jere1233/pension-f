import '../../domain/entities/transaction_detail.dart';

class TransactionModel extends TransactionDetail {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.currency,
    required super.status,
    super.description,
    required super.createdAt,
    super.updatedAt,
    super.referenceNumber,
    super.metadata,
    super.userId,
    super.vehicleId,
    super.bookingId,
    super.paymentMethod,
    super.paymentProvider,
    super.paymentReference,
    super.category,
    super.timestamp,
    super.recipientName,
    super.recipientAccount,
    super.senderName,
    super.senderAccount,
    super.balanceAfter,
    super.notes,
    super.contributionPercentage,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'KES',
      status: json['status'] ?? '',
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      referenceNumber: json['referenceNumber'] ?? json['reference'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      userId: json['userId'] ?? json['user'],
      vehicleId: json['vehicleId'] ?? json['vehicle'],
      bookingId: json['bookingId'] ?? json['booking'],
      paymentMethod: json['paymentMethod'],
      paymentProvider: json['paymentProvider'],
      paymentReference: json['paymentReference'],
      category: json['category'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : null),
      recipientName: json['recipientName'] ?? json['recipient']?['name'],
      recipientAccount: json['recipientAccount'] ?? json['recipient']?['account'],
      senderName: json['senderName'] ?? json['sender']?['name'],
      senderAccount: json['senderAccount'] ?? json['sender']?['account'],
      balanceAfter: json['balanceAfter'] != null
          ? (json['balanceAfter'] as num).toDouble()
          : null,
      notes: json['notes'],
      contributionPercentage: json['contributionPercentage'] != null
          ? (json['contributionPercentage'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'amount': amount,
      'currency': currency,
      'status': status,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'referenceNumber': referenceNumber,
      'metadata': metadata,
      'userId': userId,
      'vehicleId': vehicleId,
      'bookingId': bookingId,
      'paymentMethod': paymentMethod,
      'paymentProvider': paymentProvider,
      'paymentReference': paymentReference,
      'category': category,
      'timestamp': timestamp?.toIso8601String(),
      'recipientName': recipientName,
      'recipientAccount': recipientAccount,
      'senderName': senderName,
      'senderAccount': senderAccount,
      'balanceAfter': balanceAfter,
      'notes': notes,
      'contributionPercentage': contributionPercentage,
    };
  }

  TransactionDetail toEntity() {
    return TransactionDetail(
      id: id,
      type: type,
      amount: amount,
      currency: currency,
      status: status,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      referenceNumber: referenceNumber,
      metadata: metadata,
      userId: userId,
      vehicleId: vehicleId,
      bookingId: bookingId,
      paymentMethod: paymentMethod,
      paymentProvider: paymentProvider,
      paymentReference: paymentReference,
      category: category,
      timestamp: timestamp,
      recipientName: recipientName,
      recipientAccount: recipientAccount,
      senderName: senderName,
      senderAccount: senderAccount,
      balanceAfter: balanceAfter,
      notes: notes,
      contributionPercentage: contributionPercentage,
    );
  }

  factory TransactionModel.fromEntity(TransactionDetail entity) {
    return TransactionModel(
      id: entity.id,
      type: entity.type,
      amount: entity.amount,
      currency: entity.currency,
      status: entity.status,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      referenceNumber: entity.referenceNumber,
      metadata: entity.metadata,
      userId: entity.userId,
      vehicleId: entity.vehicleId,
      bookingId: entity.bookingId,
      paymentMethod: entity.paymentMethod,
      paymentProvider: entity.paymentProvider,
      paymentReference: entity.paymentReference,
      category: entity.category,
      timestamp: entity.timestamp,
      recipientName: entity.recipientName,
      recipientAccount: entity.recipientAccount,
      senderName: entity.senderName,
      senderAccount: entity.senderAccount,
      balanceAfter: entity.balanceAfter,
      notes: entity.notes,
      contributionPercentage: entity.contributionPercentage,
    );
  }
}