import '../../domain/entities/user.dart';

class BankAccount {
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String? branchCode;
  final String? branchName;

  const BankAccount({
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.branchCode,
    this.branchName,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    // Support multiple possible key names coming from different API responses
    String? bankName = json['bankName']?.toString() ?? json['bank_name']?.toString() ?? json['bank']?.toString();
    String? accountNumber = json['accountNumber']?.toString() ?? json['account_number']?.toString() ?? json['acct_number']?.toString();
    String? accountName = json['accountName']?.toString() ?? json['bankAccountName']?.toString() ?? json['bankAccountName']?.toString() ?? json['bank_account_name']?.toString();
    String? branchCode = json['branchCode']?.toString() ?? json['branch_code']?.toString();
    String? branchName = json['branchName']?.toString() ?? json['branch']?.toString();

    return BankAccount(
      bankName: bankName,
      accountNumber: accountNumber,
      accountName: accountName,
      branchCode: branchCode,
      branchName: branchName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (bankName != null) 'bankName': bankName,
      if (accountNumber != null) 'accountNumber': accountNumber,
      if (accountName != null) 'accountName': accountName,
      if (branchCode != null) 'branchCode': branchCode,
      if (branchName != null) 'branchName': branchName,
    };
  }
}

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.phoneNumber,
    super.profileImage,
    super.accountNumber,
    super.balance,
    super.isVerified,
    super.createdAt,
    super.dateOfBirth,
    super.bankAccount, 
    super.occupation,
    super.employer,
    super.salary,
    super.contributionRate,
    super.retirementAge,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    BankAccount? bankAccount;
    // Prefer a single `bankAccount` object if provided. Support many possible shapes:
    // - `bankAccount` as Map
    // - `bankAccount` as List (take first)
    // - `bankDetails` / `bank_details` as List (take first)
    // - `bank_details` or `bank_accounts` variations
    try {
      final dynamicBank = json['bankAccount'] ?? json['bank_account'];
      if (dynamicBank != null) {
        if (dynamicBank is Map<String, dynamic>) {
          bankAccount = BankAccount.fromJson(dynamicBank);
        } else if (dynamicBank is List && dynamicBank.isNotEmpty) {
          final first = dynamicBank.first;
          if (first is Map<String, dynamic>) {
            bankAccount = BankAccount.fromJson(first);
          } else if (first is Map) {
            bankAccount = BankAccount.fromJson(Map<String, dynamic>.from(first));
          }
        }
      } else {
        final details = json['bankDetails'] ?? json['bank_details'] ?? json['bankAccounts'] ?? json['bank_accounts'];
        if (details != null && details is List && details.isNotEmpty) {
          final first = details.first;
          if (first is Map<String, dynamic>) {
            bankAccount = BankAccount.fromJson(first);
          } else if (first is Map) {
            bankAccount = BankAccount.fromJson(Map<String, dynamic>.from(first));
          }
        }
      }
    } catch (_) {
      // ignore parsing errors and leave bankAccount null
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? json['phoneNumber']?.toString() ?? json['phone']?.toString() ?? '',
      profileImage: json['profile_image']?.toString() ?? json['profileImage']?.toString(),
      accountNumber: json['account_number']?.toString() ?? json['accountNumber']?.toString(),
      balance: json['balance'] != null ? double.tryParse(json['balance'].toString()) : null,
      isVerified: json['is_verified'] ?? json['isVerified'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : (json['dob'] != null ? DateTime.tryParse(json['dob'].toString()) : null),
      bankAccount: bankAccount, // 🆕 NEW FIELD
      occupation: json['occupation']?.toString(),
      employer: json['employer']?.toString(),
      salary: json['salary'] != null ? double.tryParse(json['salary'].toString()) : null,
      contributionRate: json['contributionRate'] != null ? double.tryParse(json['contributionRate'].toString()) : null,
      retirementAge: json['retirementAge'] != null ? int.tryParse(json['retirementAge'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'account_number': accountNumber,
      'balance': balance,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      if (bankAccount != null) 'bankAccount': (bankAccount as BankAccount).toJson(),
      if (occupation != null) 'occupation': occupation,
      if (employer != null) 'employer': employer,
      if (salary != null) 'salary': salary,
      if (contributionRate != null) 'contributionRate': contributionRate,
if (dateOfBirth != null) 'dateOfBirth': dateOfBirth?.toIso8601String(),
        if (retirementAge != null) 'retirementAge': retirementAge,
    };
  }

  User toEntity() => User(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
        accountNumber: accountNumber,
        balance: balance,
        isVerified: isVerified,
        createdAt: createdAt,
        dateOfBirth: dateOfBirth,
        bankAccount: bankAccount,
        occupation: occupation,
        employer: employer,
        salary: salary,
        contributionRate: contributionRate,
        retirementAge: retirementAge,
      );

  factory UserModel.fromEntity(User user) => UserModel(
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        phoneNumber: user.phoneNumber,
        profileImage: user.profileImage,
        accountNumber: user.accountNumber,
        balance: user.balance,
        isVerified: user.isVerified,
        createdAt: user.createdAt,
        dateOfBirth: user.dateOfBirth,
        bankAccount: user.bankAccount,
        occupation: user.occupation,
        employer: user.employer,
        salary: user.salary,
        contributionRate: user.contributionRate,
        retirementAge: user.retirementAge,
      );
}