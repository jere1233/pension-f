import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? profileImage;
  final String? accountNumber;
  final double? balance;
  final bool? isVerified;
  final DateTime? createdAt;
  final DateTime? dateOfBirth;
  final BankAccount? bankAccount; 
  final String? occupation;
  final String? employer;
  final double? salary;
  final double? contributionRate;
  final int? retirementAge;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.profileImage,
    this.accountNumber,
    this.balance,
    this.isVerified,
    this.createdAt,
    this.dateOfBirth,
    this.bankAccount, // 🆕 NEW FIELD
    this.occupation,
    this.employer,
    this.salary,
    this.contributionRate,
    this.retirementAge,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phoneNumber,
        profileImage,
        accountNumber,
        balance,
        isVerified,
        createdAt,
        dateOfBirth,
        bankAccount,
        occupation,
        employer,
        salary,
        contributionRate,
        retirementAge,
      ];

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImage,
    String? accountNumber,
    double? balance,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? dateOfBirth,
    BankAccount? bankAccount,
    String? occupation,
    String? employer,
    double? salary,
    double? contributionRate,
    int? retirementAge,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bankAccount: bankAccount ?? this.bankAccount,
      occupation: occupation ?? this.occupation,
      employer: employer ?? this.employer,
      salary: salary ?? this.salary,
      contributionRate: contributionRate ?? this.contributionRate,
      retirementAge: retirementAge ?? this.retirementAge,
    );
  }
}