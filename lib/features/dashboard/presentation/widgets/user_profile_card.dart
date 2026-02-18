import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/routes/route_names.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/data/models/user_model.dart';

class UserProfileCard extends StatelessWidget {
  final User? user;

  const UserProfileCard({
    super.key,
    this.user,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _maskAccountNumber(String? accountNumber) {
    if (accountNumber == null || accountNumber.isEmpty) return 'N/A';
    if (accountNumber.length <= 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    final bankAccount = user?.bankAccount as BankAccount?;
    // Bank details section is temporarily disabled - hasBankDetails no longer needed
    // final hasBankDetails = bankAccount != null && bankAccount.bankName != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient1,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with glass effect
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    user != null
                        ? '${user!.firstName[0]}${user!.lastName[0]}'.toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'User Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user?.email ?? 'user@example.com',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Since ${_formatDate(user?.createdAt)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.highlightGold,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.highlightGold.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          
          // BANK DETAILS SECTION - TEMPORARILY DISABLED TO REDUCE CLUTTER
          // if (hasBankDetails) ...[
          //   const SizedBox(height: 20),
          //   Container(
          //     padding: const EdgeInsets.all(16),
          //     decoration: BoxDecoration(
          //       color: Colors.white.withOpacity(0.15),
          //       borderRadius: BorderRadius.circular(16),
          //       border: Border.all(
          //         color: Colors.white.withOpacity(0.2),
          //         width: 1,
          //       ),
          //     ),
          //     child: Column(
          //       children: [
          //         Row(
          //           children: [
          //             Container(
          //               padding: const EdgeInsets.all(8),
          //               decoration: BoxDecoration(
          //                 color: Colors.white.withOpacity(0.2),
          //                 borderRadius: BorderRadius.circular(8),
          //               ),
          //               child: const Icon(
          //                 Icons.account_balance_rounded,
          //                 color: Colors.white,
          //                 size: 18,
          //               ),
          //             ),
          //             const SizedBox(width: 12),
          //             Expanded(
          //               child: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     'Bank Account',
          //                     style: TextStyle(
          //                       fontSize: 12,
          //                       color: Colors.white.withOpacity(0.8),
          //                       fontWeight: FontWeight.w500,
          //                     ),
          //                   ),
          //                   const SizedBox(height: 2),
          //                   Text(
          //                     bankAccount.bankName ?? 'N/A',
          //                     style: const TextStyle(
          //                       fontSize: 15,
          //                       color: Colors.white,
          //                       fontWeight: FontWeight.bold,
          //                     ),
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             Icon(
          //               Icons.verified_rounded,
          //               color: AppColors.highlightGold,
          //               size: 20,
          //             ),
          //           ],
          //         ),
          //         const SizedBox(height: 12),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             Text(
          //               'Account: ${_maskAccountNumber(bankAccount.accountNumber)}',
          //               style: TextStyle(
          //                 fontSize: 13,
          //                 color: Colors.white.withOpacity(0.9),
          //                 fontWeight: FontWeight.w500,
          //               ),
          //             ),
          //             if (bankAccount.branchName != null)
          //               Text(
          //                 bankAccount.branchName!,
          //                 style: TextStyle(
          //                   fontSize: 13,
          //                   color: Colors.white.withOpacity(0.9),
          //                   fontWeight: FontWeight.w500,
          //                 ),
          //               ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ] else ...[
          //   const SizedBox(height: 16),
          //   InkWell(
          //     onTap: () {
          //       // Navigate to bank details setup
          //       context.push(RouteNames.profile);
          //     },
          //     borderRadius: BorderRadius.circular(12),
          //     child: Container(
          //       padding: const EdgeInsets.all(14),
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(
          //           colors: [
          //             const Color(0xFFFF6B35),
          //             const Color(0xFFFF8C42),
          //           ],
          //           begin: Alignment.topLeft,
          //           end: Alignment.bottomRight,
          //         ),
          //         borderRadius: BorderRadius.circular(12),
          //         border: Border.all(
          //           color: Colors.white.withOpacity(0.3),
          //           width: 1.5,
          //         ),
          //         boxShadow: [
          //           BoxShadow(
          //             color: const Color(0xFFFF6B35).withOpacity(0.3),
          //             blurRadius: 12,
          //             offset: const Offset(0, 4),
          //           ),
          //         ],
          //       ),
          //       child: Row(
          //         children: [
          //           Container(
          //             padding: const EdgeInsets.all(8),
          //             decoration: BoxDecoration(
          //               color: Colors.white.withOpacity(0.25),
          //               borderRadius: BorderRadius.circular(8),
          //             ),
          //             child: const Icon(
          //               Icons.warning_amber_rounded,
          //               color: Colors.white,
          //               size: 20,
          //             ),
          //           ),
          //           const SizedBox(width: 12),
          //           const Expanded(
          //             child: Text(
          //               'Please add your bank details',
          //               style: TextStyle(
          //                 fontSize: 14,
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold,
          //                 letterSpacing: 0.2,
          //               ),
          //             ),
          //           ),
          //           Container(
          //             padding: const EdgeInsets.all(6),
          //             decoration: BoxDecoration(
          //               color: Colors.white.withOpacity(0.25),
          //               borderRadius: BorderRadius.circular(6),
          //             ),
          //             child: const Icon(
          //               Icons.arrow_forward_ios_rounded,
          //               color: Colors.white,
          //               size: 14,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }
}