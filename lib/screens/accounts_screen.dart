import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

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
          const SizedBox(height: 8),
          TapeStrip('★ NET WORTH: ${formatINR(netWorth)} ★'),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ...accounts.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _AccountCard(account: a),
                )),
                if (accounts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text('NO ACCOUNTS YET',
                        style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 24, color: AppColors.mutedText, letterSpacing: 2))),
                  ),
                GestureDetector(
                  onTap: () => _showAddDialog(context, ref),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.black, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: const Text('+ ADD ACCOUNT',
                        style: TextStyle(fontFamily: 'BebasNeue', fontSize: 18, letterSpacing: 2)),
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

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddAccountDialog(ref: ref),
    );
  }
}

class _AddAccountDialog extends StatefulWidget {
  final WidgetRef ref;
  const _AddAccountDialog({required this.ref});
  @override
  State<_AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<_AddAccountDialog> {
  final _nameCtrl = TextEditingController();
  final _balCtrl = TextEditingController(text: '0');
  final _limitCtrl = TextEditingController();
  AccountType _type = AccountType.bank;

  @override
  void dispose() { _nameCtrl.dispose(); _balCtrl.dispose(); _limitCtrl.dispose(); super.dispose(); }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
    final user = widget.ref.read(currentUserProvider)!;
    final acct = Account(
      userId: user.id,
      name: _nameCtrl.text.trim(),
      type: _type,
      balance: double.tryParse(_balCtrl.text) ?? 0,
      creditLimit: _type == AccountType.creditCard ? (double.tryParse(_limitCtrl.text) ?? 0) : null,
    );
    widget.ref.read(accountBoxProvider).add(acct);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final typeLabels = {AccountType.cash: 'CASH', AccountType.bank: 'BANK', AccountType.creditCard: 'CREDIT CARD', AccountType.upi: 'UPI'};
    return Dialog(
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ADD ACCOUNT', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, letterSpacing: 2)),
            const SizedBox(height: 14),

            _field(_nameCtrl, 'Account name (e.g. SBI Savings)'),
            const SizedBox(height: 10),

            // Type
            const Text('TYPE', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 12, letterSpacing: 2, color: AppColors.mutedText)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: AccountType.values.map((t) {
                final sel = _type == t;
                return GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.black : Colors.white,
                      border: Border.all(color: AppColors.black, width: 2),
                    ),
                    child: Text(typeLabels[t]!,
                        style: TextStyle(fontFamily: 'BebasNeue', fontSize: 14, letterSpacing: 1,
                            color: sel ? AppColors.yellow : AppColors.black)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            if (_type != AccountType.creditCard) ...[
              _field(_balCtrl, 'Opening balance', numeric: true),
              const SizedBox(height: 10),
            ],
            if (_type == AccountType.creditCard) ...[
              _field(_limitCtrl, 'Credit limit', numeric: true),
              const SizedBox(height: 10),
            ],

            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.black, width: 2)),
                    alignment: Alignment.center,
                    child: const Text('CANCEL', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      border: Border.fromBorderSide(BorderSide(color: AppColors.black, width: 2)),
                      boxShadow: [BoxShadow(color: AppColors.black, offset: Offset(3, 3), blurRadius: 0)],
                    ),
                    alignment: Alignment.center,
                    child: const Text('CREATE ★', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2, color: AppColors.black)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, {bool numeric = false}) => TextField(
    controller: ctrl,
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 13),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: AppColors.mutedText),
      enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.black, width: 2)),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.blue, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
  );
}

class _AccountCard extends StatelessWidget {
  final Account account;
  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final configs = {
      AccountType.bank: (AppColors.blue, Colors.white),
      AccountType.cash: (AppColors.yellow, AppColors.black),
      AccountType.creditCard: (AppColors.black, AppColors.yellow),
      AccountType.upi: (AppColors.pink, Colors.white),
    };
    final typeLabels = {AccountType.bank: 'BANK', AccountType.cash: 'CASH', AccountType.creditCard: 'CREDIT', AccountType.upi: 'UPI'};
    final (bg, fg) = configs[account.type]!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: AppColors.black, width: 3),
        boxShadow: const [BoxShadow(color: AppColors.black, offset: Offset(5, 5), blurRadius: 0)],
      ),
      child: Stack(children: [
        // watermark
        Positioned(
          right: -8, bottom: -12,
          child: Text(
            account.name.substring(0, account.name.length.clamp(0, 5)).toUpperCase(),
            style: TextStyle(fontFamily: 'BebasNeue', fontSize: 80, color: (fg as Color).withOpacity(0.06), height: 1),
          ),
        ),
        Positioned(right: 0, top: 0,
          child: Text(typeLabels[account.type]!,
              style: TextStyle(fontFamily: 'BebasNeue', fontSize: 10, letterSpacing: 2, color: (fg).withOpacity(0.4)))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(account.name.toUpperCase(),
                style: TextStyle(fontFamily: 'BebasNeue', fontSize: 26, letterSpacing: 1, color: fg, height: 1)),
            const SizedBox(height: 8),
            if (account.isCreditCard) ...[
              Text(formatINR(account.outstandingDue),
                  style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 40, color: AppColors.red, height: 1, letterSpacing: -1)),
              Text('OUTSTANDING DUE', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: (fg).withOpacity(0.6), letterSpacing: 1)),
              const SizedBox(height: 10),
              Divider(color: (fg).withOpacity(0.2), thickness: 1),
              const SizedBox(height: 6),
              Row(children: [
                _Stat('LIMIT', formatINR(account.creditLimit ?? 0), fg),
                const SizedBox(width: 20),
                _Stat('AVAILABLE', formatINR(account.availableCredit), AppColors.green),
                if (account.dueDate != null) ...[
                  const SizedBox(width: 20),
                  _Stat('DUE', DateFormat('d MMM').format(account.dueDate!), AppColors.red),
                ],
              ]),
            ] else ...[
              Text(formatINR(account.balance),
                  style: TextStyle(fontFamily: 'BebasNeue', fontSize: 40, color: fg, height: 1, letterSpacing: -1)),
              Text('BALANCE', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: (fg).withOpacity(0.6), letterSpacing: 1)),
            ],
          ],
        ),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 8, letterSpacing: 1, color: color.withOpacity(0.6))),
      Text(value, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, color: color, height: 1)),
    ],
  );
}
