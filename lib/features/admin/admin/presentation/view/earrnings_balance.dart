import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/auth_state.dart';
import 'package:freelancer/features/admin/logic/wallet_cubit.dart';
import 'package:freelancer/features/admin/logic/wallet_state.dart';
import 'package:freelancer/features/home/presentation/widget/custom_footer.dart';
import 'package:intl/intl.dart';
import 'package:freelancer/core/utils/widgets/elegant_toast.dart';

class EarningsBalanceView extends StatefulWidget {
  const EarningsBalanceView({super.key});

  @override
  State<EarningsBalanceView> createState() => _EarningsBalanceViewState();
}

class _EarningsBalanceViewState extends State<EarningsBalanceView> {
  final TextEditingController _amountController = TextEditingController();
  String _withdrawalMethod = 'Vodafone Cash';

  @override
  void initState() {
    super.initState();
    final AuthCubitState = context.read<AuthCubit>().state;
    if (AuthCubitState is AuthAdminSuccess) {
      context.read<WalletCubit>().loadWallet(AuthCubitState.user.id);
    } else if (AuthCubitState is AuthSuccess) {
      context.read<WalletCubit>().loadWallet(AuthCubitState.user.id);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletCubit, WalletState>(
      listener: (context, state) {
        if (state is WalletWithdrawalSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Withdrawal requested successfully!')),
          );
          final AuthCubitState = context.read<AuthCubit>().state;
          final userId = AuthCubitState is AuthAdminSuccess
              ? AuthCubitState.user.id
              : AuthCubitState is AuthSuccess ? AuthCubitState.user.id : null;
          if (userId != null) {
            context.read<WalletCubit>().loadWallet(userId);
          }
          _amountController.clear();
        } else if (state is WalletError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is WalletLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, dynamic> balance = {
          'available_balance': 0.0,
          'on_hold': 0.0,
          'total_inflows': 0.0,
        };
        List<Map<String, dynamic>> history = [];

        if (state is WalletLoaded) {
          balance = state.balance;
          history = state.history;
        }

        final availableBalance =
            (balance['available_balance'] as num?)?.toDouble() ?? 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wallet Balance',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View your balance, request withdrawals, and track transactions.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.sub.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 32),
            _BalanceCard(
              title: 'Available Balance',
              amount: 'EGP ${balance['available_balance']?.toStringAsFixed(0)}',
              subtitle: 'Ready for withdrawal',
              color: Colors.green.shade700,
            ),
            const SizedBox(height: 16),
            _BalanceCard(
              title: 'On Hold',
              amount: 'EGP ${balance['on_hold']?.toStringAsFixed(0)}',
              subtitle: 'Pending check-in',
              color: Colors.orange.shade700,
            ),
            const SizedBox(height: 16),
            _BalanceCard(
              title: 'Total Inflows',
              amount: 'EGP ${balance['total_inflows']?.toStringAsFixed(0)}',
              subtitle: 'Lifetime total received',
              color: Colors.black,
            ),
            const SizedBox(height: 48),
            const Text(
              'Transaction History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Recent credits and debits to your account.',
              style: TextStyle(fontSize: 14, color: AppColors.sub),
            ),
            const SizedBox(height: 24),
            _TransactionTable(history: history),
            const SizedBox(height: 48),
            const Text(
              'Request Withdrawal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Withdraw funds to your connected accounts.',
              style: TextStyle(fontSize: 14, color: AppColors.sub),
            ),
            const SizedBox(height: 24),
            _WithdrawalForm(
              maxAmount: availableBalance,
              amountController: _amountController,
              withdrawalMethod: _withdrawalMethod,
              onMethodChanged: (val) => setState(() => _withdrawalMethod = val),
            ),
            const SizedBox(height: 40),
            const CustomFooter(),
          ],
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final Color color;

  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Text(
            amount,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.sub)),
        ],
      ),
    );
  }
}

class _TransactionTable extends StatefulWidget {
  final List<Map<String, dynamic>> history;
  const _TransactionTable({required this.history});

  @override
  State<_TransactionTable> createState() => _TransactionTableState();
}

class _TransactionTableState extends State<_TransactionTable> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _rowsPerPage = 10;
  int _currentPage = 1;
  int _sortColumnIndex = 0;
  bool _sortAscending = false;
  late List<Map<String, dynamic>> _processedHistory;

  @override
  void initState() {
    super.initState();
    _processHistory();
  }

  @override
  void didUpdateWidget(covariant _TransactionTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.history != widget.history) {
      _processHistory();
    }
  }

  void _processHistory() {
    double currentBalance = 0.0;
    List<Map<String, dynamic>> temp = [];
    
    // Iterate from oldest (end of list) to newest (start of list) to calculate chronological balance
    for (int i = widget.history.length - 1; i >= 0; i--) {
      final tx = Map<String, dynamic>.from(widget.history[i]);
      final status = tx['status'] ?? 'pending';
      final isCredit = status == 'confirmed' || status == 'completed';
      final subtotal = (tx['subtotal'] as num?)?.toDouble() ?? 0.0;
      
      if (isCredit) {
        currentBalance += subtotal;
      }
      
      tx['balanceAfter'] = isCredit ? 'EGP ${currentBalance.toStringAsFixed(0)}' : 'Pending';
      tx['isCredit'] = isCredit;
      tx['parsedDate'] = tx['created_at'] != null ? DateTime.parse(tx['created_at']) : DateTime.fromMillisecondsSinceEpoch(0);
      
      final listingTitle = (tx['listing'] is Map)
          ? tx['listing']['title'] as String? ?? 'Listing'
          : 'Listing';
      tx['description'] = 'Payment for $listingTitle';
      
      temp.add(tx);
    }
    // Reverse back so newest is first
    _processedHistory = temp.reversed.toList();
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _currentPage = 1; // Reset to first page on sort
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Search Filter
    List<Map<String, dynamic>> filteredList = _processedHistory.where((tx) {
      final query = _searchCtrl.text.toLowerCase();
      if (query.isEmpty) return true;
      final desc = tx['description'].toString().toLowerCase();
      final status = tx['status'].toString().toLowerCase();
      return desc.contains(query) || status.contains(query);
    }).toList();

    // 2. Sorting
    filteredList.sort((a, b) {
      int cmp = 0;
      if (_sortColumnIndex == 0) { // Date
        final d1 = a['parsedDate'] as DateTime;
        final d2 = b['parsedDate'] as DateTime;
        cmp = d1.compareTo(d2);
      } else if (_sortColumnIndex == 1) { // Type
        final s1 = a['status'].toString();
        final s2 = b['status'].toString();
        cmp = s1.compareTo(s2);
      } else if (_sortColumnIndex == 2) { // Amount
        final am1 = (a['subtotal'] as num?)?.toDouble() ?? 0.0;
        final am2 = (b['subtotal'] as num?)?.toDouble() ?? 0.0;
        cmp = am1.compareTo(am2);
      } else if (_sortColumnIndex == 3) { // Description
        final desc1 = a['description'].toString();
        final desc2 = b['description'].toString();
        cmp = desc1.compareTo(desc2);
      } else if (_sortColumnIndex == 4) { // Balance After
        // Simple string comparison for balance
        final b1 = a['balanceAfter'].toString();
        final b2 = b['balanceAfter'].toString();
        cmp = b1.compareTo(b2);
      }
      return _sortAscending ? cmp : -cmp;
    });

    // 3. Pagination
    int totalRows = filteredList.length;
    int totalPages = (totalRows / _rowsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;
    if (_currentPage > totalPages) _currentPage = totalPages;

    int startIndex = (_currentPage - 1) * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    if (endIndex > totalRows) endIndex = totalRows;

    final paginatedHistory = startIndex < totalRows ? filteredList.sublist(startIndex, endIndex) : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search Box
        TextField(
          controller: _searchCtrl,
          onChanged: (val) => setState(() => _currentPage = 1),
          decoration: InputDecoration(
            hintText: 'Search by description...',
            hintStyle: TextStyle(fontSize: 14, color: AppColors.sub),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.dividerGrey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Table Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  headingRowColor: WidgetStateProperty.all(Colors.white),
                  dataRowColor: WidgetStateProperty.all(Colors.white),
                  dividerThickness: 1,
                  columnSpacing: 32,
                  columns: [
                    DataColumn(label: const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)), onSort: _onSort),
                    DataColumn(label: const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)), onSort: _onSort),
                    DataColumn(label: const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)), onSort: _onSort),
                    DataColumn(label: const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)), onSort: _onSort),
                    DataColumn(label: const Text('Balance After', style: TextStyle(fontWeight: FontWeight.bold)), onSort: _onSort),
                  ],
                  rows: paginatedHistory.isEmpty
                      ? []
                      : List<DataRow>.generate(paginatedHistory.length, (index) {
                          final currentTx = paginatedHistory[index];
                          final status = currentTx['status'] ?? 'pending';
                          final isCredit = currentTx['isCredit'] ?? false;
                          final subtotal = (currentTx['subtotal'] as num?)?.toDouble() ?? 0.0;
                          
                          final date = currentTx['created_at'] != null
                              ? DateFormat('MMM d, yyyy').format(DateTime.parse(currentTx['created_at']))
                              : '-';

                          return DataRow(cells: [
                            DataCell(Text(date, style: const TextStyle(fontSize: 13))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isCredit ? Colors.green.shade50 : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  status.toString().toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isCredit ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text('EGP ${subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13))),
                            DataCell(Text(currentTx['description'].toString(), style: const TextStyle(fontSize: 13))),
                            DataCell(Text(currentTx['balanceAfter'].toString(), style: TextStyle(fontSize: 13, color: AppColors.sub, fontWeight: FontWeight.w500))),
                          ]);
                        }),
                ),
              ),
              if (paginatedHistory.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.dividerGrey.withValues(alpha: 0.3))),
                  ),
                  child: const Text('No results.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black87)),
                ),
              // Footer Pagination
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.dividerGrey.withValues(alpha: 0.3))),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('$totalRows row(s) total.', style: TextStyle(fontSize: 12, color: AppColors.sub)),
                      const SizedBox(width: 16),
                      Text('Rows per page:', style: TextStyle(fontSize: 12, color: AppColors.sub)),
                      const SizedBox(width: 8),
                      Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _rowsPerPage,
                            isDense: true,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                            style: const TextStyle(fontSize: 12, color: AppColors.ink),
                            items: [5, 10, 20, 50].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _rowsPerPage = val;
                                  _currentPage = 1;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Page $_currentPage of $totalPages', style: TextStyle(fontSize: 12, color: AppColors.sub)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
                        child: Icon(Icons.chevron_left, size: 20, color: _currentPage > 1 ? AppColors.ink : AppColors.dividerGrey),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _currentPage < totalPages ? () => setState(() => _currentPage++) : null,
                        child: Icon(Icons.chevron_right, size: 20, color: _currentPage < totalPages ? AppColors.ink : AppColors.dividerGrey),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}


class _WithdrawalForm extends StatelessWidget {
  final double maxAmount;
  final TextEditingController amountController;
  final String withdrawalMethod;
  final ValueChanged<String> onMethodChanged;

  const _WithdrawalForm({
    required this.maxAmount,
    required this.amountController,
    required this.withdrawalMethod,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount (EGP)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: amountController,
            decoration: InputDecoration(
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          Text(
            'Maximum: EGP ${maxAmount.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 12, color: AppColors.sub),
          ),
          const SizedBox(height: 24),
          const Text(
            'Withdrawal Method',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: withdrawalMethod,
                isExpanded: true,
                items: ['Vodafone Cash', 'Bank Transfer', 'InstaPay']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    onMethodChanged(val);
                    ElegantToast.show(context, 'Selected: $val', icon: Icons.account_balance_wallet_rounded);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (maxAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your available balance is 0 EGP. Cannot request payout.'),
                      backgroundColor: AppColors.primaryRed,
                    ),
                  );
                  return;
                }
                final amountText = amountController.text.trim();
                if (amountText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter an amount to withdraw.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                final amount = double.tryParse(amountText) ?? 0.0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount greater than 0.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                if (amount > maxAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Amount exceeds your available balance of EGP ${maxAmount.toStringAsFixed(2)}.'),
                      backgroundColor: AppColors.primaryRed,
                    ),
                  );
                  return;
                }
                final AuthCubitState = context.read<AuthCubit>().state;
                final userId = AuthCubitState is AuthAdminSuccess
                    ? AuthCubitState.user.id
                    : AuthCubitState is AuthSuccess ? AuthCubitState.user.id : null;
                if (userId != null) {
                  context.read<WalletCubit>().requestWithdrawal(
                    hostId: userId,
                    amount: amount,
                    method: withdrawalMethod,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payout requested successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  amountController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Request Payout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
