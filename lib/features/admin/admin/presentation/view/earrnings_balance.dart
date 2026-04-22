import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freelancer/core/constant/constant.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_cubit.dart';
import 'package:freelancer/features/auth/logic/cubit/cubit/auth_state.dart';
import 'package:freelancer/features/admin/logic/wallet_cubit.dart';
import 'package:freelancer/features/admin/logic/wallet_state.dart';
import 'package:intl/intl.dart';

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
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAdminSuccess) {
      context.read<WalletCubit>().loadWallet(authState.user.id);
    } else if (authState is AuthSuccess) {
      context.read<WalletCubit>().loadWallet(authState.user.id);
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
          final authState = context.read<AuthCubit>().state;
          final userId = authState is AuthAdminSuccess
              ? authState.user.id
              : authState is AuthSuccess ? authState.user.id : null;
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
  final int _rowsPerPage = 10;
  int _currentPage = 1;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // فلترة بسيطة
    final filteredHistory = widget.history.where((tx) {
      final query = _searchCtrl.text.toLowerCase();
      if (query.isEmpty) return true;
      final desc = (tx['listing'] is Map ? tx['listing']['title'] : 'Booking').toString().toLowerCase();
      final status = (tx['status'] ?? 'pending').toString().toLowerCase();
      return desc.contains(query) || status.contains(query);
    }).toList();

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
                  headingRowColor: WidgetStateProperty.all(Colors.white),
                  dataRowColor: WidgetStateProperty.all(Colors.white),
                  dividerThickness: 1,
                  columnSpacing: 32,
                  columns: const [
                    DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Balance After', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: filteredHistory.isEmpty
                      ? []
                      : List<DataRow>.generate(filteredHistory.length, (index) {
                          // Calculate running balance (from oldest to newest)
                          // Since list is descending, index 0 is newest. So running balance up to index i
                          // is total available balance minus all newer transactions.
                          
                          // First, sum all subtotal for this logic
                          // For a more accurate "Balance After", we simply accumulate subtotals backwards
                          
                          final currentTx = filteredHistory[index];
                          final status = currentTx['status'] ?? 'pending';
                          final isCredit = status == 'confirmed' || status == 'completed';
                          final subtotal = (currentTx['subtotal'] as num?)?.toDouble() ?? 0.0;
                          final listingTitle = (currentTx['listing'] is Map)
                              ? currentTx['listing']['title'] as String? ?? 'Listing'
                              : 'Listing';
                          
                          final date = currentTx['created_at'] != null
                              ? DateFormat('MMM d, yyyy').format(DateTime.parse(currentTx['created_at']))
                              : '-';

                          final description = 'Payment for $listingTitle';
                          
                          // Calculate balance after:
                          // If we don't have the absolute global balance at time of tx, we can estimate running sum of just these txs
                          // or leave it as '-' if it's pending. Let's do a simple running sum of shown items for demonstration:
                          double runningBalance = 0.0;
                          for(int i = filteredHistory.length - 1; i >= index; i--) {
                            final st = filteredHistory[i]['status'];
                            if (st == 'confirmed' || st == 'completed') {
                              runningBalance += (filteredHistory[i]['subtotal'] as num?)?.toDouble() ?? 0.0;
                            }
                          }
                          
                          final balanceAfterStr = isCredit ? 'EGP ${runningBalance.toStringAsFixed(0)}' : 'Pending';

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
                            DataCell(Text(description, style: const TextStyle(fontSize: 13))),
                            DataCell(Text(balanceAfterStr, style: TextStyle(fontSize: 13, color: AppColors.sub, fontWeight: FontWeight.w500))),
                          ]);
                        }),
                ),
              ),
              if (filteredHistory.isEmpty)
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
                      Text('${filteredHistory.length} row(s) total.', style: TextStyle(fontSize: 12, color: AppColors.sub)),
                      const SizedBox(width: 16),
                      Text('Rows per page:', style: TextStyle(fontSize: 12, color: AppColors.sub)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text('$_rowsPerPage', style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Page $_currentPage of ${filteredHistory.isEmpty ? 0 : 1}', style: TextStyle(fontSize: 12, color: AppColors.sub)),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_left, size: 20, color: AppColors.dividerGrey),
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, size: 20, color: AppColors.dividerGrey),
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
                  if (val != null) onMethodChanged(val);
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
                final authState = context.read<AuthCubit>().state;
                final userId = authState is AuthAdminSuccess
                    ? authState.user.id
                    : authState is AuthSuccess ? authState.user.id : null;
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
