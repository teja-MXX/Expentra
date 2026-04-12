import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'package:intl/intl.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    final netWorth = ref.watch(netWorthProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScreenHeader(title: 'ACCOUNTS', subtitle: 'All your money, one place'),
          const SizedBox(height: 12),
          TapeStrip('★ TOTAL: ${formatINR(netWorth)} ★'),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ...accounts.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _AccountCard(account: a),
                )),
                if (accounts.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Text('NO ACCOUNTS YET', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 24, color: AppColors.mutedText, letterSpacing: 2)),
                  ),
                // Add account button
                GestureDetector(
                  onTap: () => _showAddAccountDialog(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.black, width: 2, style: BorderStyle.solid),
                    ),
                    alignment: Alignment.center,
                    child: Text('+ ADD ACCOUNT', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 18, letterSpacing: 2)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    AccountType selectedType = AccountType.bank;
    double balance = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.paper,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 20, left: 20, right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ADD ACCOUNT', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 32, letterSpacing: 2)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Account name (e.g. SBI Savings)',
                  hintStyle: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, color: AppColors.mutedText),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                  enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.black, width: 2)),
                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.blue, width: 2)),
                ),
                style: TextStyle(fontFamily: 'SpaceMono', fontSize: 13),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: AccountType.values.map((t) {
                  final isSel = selectedType == t;
                  final labels = {AccountType.cash: 'CASH', AccountType.bank: 'BANK', AccountType.creditCard: 'CREDIT CARD', AccountType.upi: 'UPI'};
                  return GestureDetector(
                    onTap: () => setState(() => selectedType = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.black : Colors.white,
                        border: Border.all(color: AppColors.black, width: 2),
                      ),
                      child: Text(labels[t]!, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 14, letterSpacing: 1, color: isSel ? AppColors.yellow : AppColors.black)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: BrutalButton(
                  label: 'CREATE ACCOUNT',
                  onTap: () {
                    if (nameCtrl.text.isEmpty) return;
                    final user = ref.read(currentUserProvider)!;
                    final acct = Account(userId: user.id, name: nameCtrl.text, type: selectedType);
                    ref.read(accountBoxProvider).add(acct);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final configs = {
      AccountType.bank: (AppColors.blue, Colors.white, 'BANK'),
      AccountType.cash: (AppColors.yellow, AppColors.black, 'CASH'),
      AccountType.creditCard: (AppColors.black, AppColors.yellow, 'CREDIT'),
      AccountType.upi: (AppColors.pink, Colors.white, 'UPI'),
    };
    final (bg, fg, typeLabel) = configs[account.type]!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: AppColors.black, width: 3),
        boxShadow: const [BoxShadow(color: AppColors.black, offset: Offset(5, 5), blurRadius: 0)],
      ),
      child: Stack(
        children: [
          // Watermark
          Positioned(
            right: -10, bottom: -14,
            child: Text(
              account.name.length > 4 ? account.name.substring(0, 4).toUpperCase() : account.name.toUpperCase(),
              style: TextStyle(fontFamily: 'BebasNeue', fontSize: 96, color: fg.withOpacity(0.06), height: 1, letterSpacing: -4),
            ),
          ),
          // Type label
          Positioned(
            right: 0, top: 0,
            child: Text(typeLabel, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 10, letterSpacing: 2, color: fg.withOpacity(0.4))),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(account.name.toUpperCase(), style: TextStyle(fontFamily: 'BebasNeue', fontSize: 10, letterSpacing: 2, color: fg.withOpacity(0.7))),
              const SizedBox(height: 4),
              Text(account.name.toUpperCase(), style: TextStyle(fontFamily: 'BebasNeue', fontSize: 30, letterSpacing: 1, color: fg, height: 1)),
              const SizedBox(height: 8),
              // Main balance / due
              if (account.isCreditCard) ...[
                Text(formatINR(account.outstandingDue), style: TextStyle(fontFamily: 'BebasNeue', fontSize: 44, color: AppColors.red, height: 1, letterSpacing: -1)),
                Text('OUTSTANDING DUE', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: fg.withOpacity(0.6), letterSpacing: 1)),
                const SizedBox(height: 12),
                Divider(color: fg.withOpacity(0.15), thickness: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _CardStat('LIMIT', formatINR(account.creditLimit ?? 0), fg),
                    const SizedBox(width: 24),
                    _CardStat('AVAILABLE', formatINR(account.availableCredit), AppColors.green),
                    const SizedBox(width: 24),
                    if (account.dueDate != null)
                      _CardStat('DUE', DateFormat('d MMM').format(account.dueDate!), AppColors.red),
                  ],
                ),
              ] else ...[
                Text(formatINR(account.balance), style: TextStyle(fontFamily: 'BebasNeue', fontSize: 44, color: fg, height: 1, letterSpacing: -1)),
                Text('BALANCE', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: fg.withOpacity(0.6), letterSpacing: 1)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CardStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _CardStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, letterSpacing: 1, color: color.withOpacity(0.6))),
        Text(value, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 17, color: color, height: 1)),
      ],
    );
  }
}
