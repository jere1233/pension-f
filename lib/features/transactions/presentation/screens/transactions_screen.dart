// lib/features/transactions/presentation/screens/transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_filter.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<TransactionProvider>().loadMoreTransactions();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TransactionFilter(
        onApply: () {
          Navigator.pop(context);
          context.read<TransactionProvider>().loadTransactions(refresh: true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterBottomSheet,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Transactions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.05),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context
                                .read<TransactionProvider>()
                                .setSearchQuery('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  context.read<TransactionProvider>().setSearchQuery(value);
                },
              ),
            ),

            // Active Filters Display
            Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final hasFilters = provider.selectedType != null ||
                    provider.selectedStatus != null ||
                    provider.startDate != null;

                if (!hasFilters) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (provider.selectedType != null)
                        Chip(
                          label: Text(provider.selectedType!),
                          onDeleted: () =>
                              provider.setTypeFilter(null),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      if (provider.selectedStatus != null)
                        Chip(
                          label: Text(provider.selectedStatus!),
                          onDeleted: () =>
                              provider.setStatusFilter(null),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      if (provider.startDate != null)
                        Chip(
                          label: const Text('Date Range'),
                          onDeleted: () =>
                              provider.setDateRange(null, null),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear All'),
                        onPressed: provider.clearFilters,
                      ),
                    ],
                  ),
                );
              },
            ),
            Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final hasFilters = provider.selectedType != null ||
                    provider.selectedStatus != null ||
                    provider.startDate != null;

                if (!hasFilters) return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      if (provider.selectedType != null)
                        Chip(
                          label: Text(provider.selectedType!),
                          onDeleted: () =>
                              provider.setTypeFilter(null),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      if (provider.selectedStatus != null)
                        Chip(
                          label: Text(provider.selectedStatus!),
                          onDeleted: () =>
                              provider.setStatusFilter(null),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      if (provider.startDate != null)
                        Chip(
                          label: const Text('Date Range'),
                          onDeleted: () =>
                              provider.setDateRange(null, null),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear All'),
                        onPressed: provider.clearFilters,
                      ),
                    ],
                  ),
                );
              },
            ),

            // Transaction List
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  if (provider.status == TransactionStatus.loading &&
                      provider.transactions.isEmpty) {
                    return const Center(child: CustomLoadingIndicator());
                  }

                  if (provider.status == TransactionStatus.error) {
                    return CustomErrorWidget(
                      message: provider.errorMessage ?? 'An error occurred',
                      onRetry: () =>
                          provider.loadTransactions(refresh: true),
                    );
                  }

                  if (provider.filteredTransactions.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.receipt_long,
                      title: 'No Transactions',
                      message: 'You don\'t have any transactions yet',
                    );
                  }

                  final groupedTransactions = provider.groupedTransactions;

                  return RefreshIndicator(
                    onRefresh: () =>
                        provider.loadTransactions(refresh: true),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: groupedTransactions.length +
                          (provider.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == groupedTransactions.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final date = groupedTransactions.keys.elementAt(index);
                        final transactions = groupedTransactions[date]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Text(
                                date,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                    ),
                              ),
                            ),
                            ...transactions.map(
                              (transaction) => TransactionListItem(
                                transaction: transaction,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/transaction-detail',
                                    arguments: transaction.id,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}