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

class _TransactionTable extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _TransactionTable({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.sub,
            ),
            const SizedBox(height: 16),
            const Text(
              'No results.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '0 row(s) total.',
              style: TextStyle(fontSize: 12, color: AppColors.sub),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dividerGrey.withValues(alpha: 0.3)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: history.length,
        separatorBuilder: (_, _) =>
            Divider(color: AppColors.dividerGrey.withValues(alpha: 0.3), height: 1),
        itemBuilder: (context, index) {
          final tx = history[index];
          // Repo returns: subtotal, status, created_at, listing:{title,user_id}
          final status = tx['status'] ?? 'pending';
          final isCredit = status == 'confirmed' || status == 'completed';
          final subtotal = (tx['subtotal'] as num?)?.toDouble() ?? 0.0;
          final listingTitle = (tx['listing'] is Map)
              ? tx['listing']['title'] as String? ?? 'Booking'
              : 'Booking';
          final shortId = (tx['id'] as String? ?? '--------').substring(0, 8);
          final date = tx['created_at'] != null
              ? DateFormat('MMM d, yyyy').format(DateTime.parse(tx['created_at']))
              : '-';
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: isCredit
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.hourglass_top,
                color: isCredit ? Colors.green : Colors.orange,
                size: 20,
              ),
            ),
            title: Text(
              listingTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '#$shortId  ·  $date',
              style: TextStyle(color: AppColors.sub, fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'EGP ${subtotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCredit ? Colors.green : Colors.orange,
                    fontSize: 14,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCredit ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isCredit ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
              onPressed: maxAmount > 0
                  ? () {
                      final amount =
                          double.tryParse(amountController.text) ?? 0.0;
                      if (amount <= 0 || amount > maxAmount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Invalid amount')),
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
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffb07c7c),
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
