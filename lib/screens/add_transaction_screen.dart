import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});
  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  String _amountStr = '0';
  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  String? _selectedAccountId;
  String? _selectedToAccountId;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  void _numPress(String v) {
    setState(() {
      if (v == '.' && _amountStr.contains('.')) return;
      if (_amountStr == '0' && v != '.') { _amountStr = v; return; }
      if (_amountStr.length < 9) _amountStr += v;
    });
  }

  void _numDel() => setState(() {
    if (_amountStr.length <= 1) { _amountStr = '0'; return; }
    _amountStr = _amountStr.substring(0, _amountStr.length - 1);
  });

  void _submit() {
    final amount = double.tryParse(_amountStr) ?? 0;
    final categories = ref.read(categoriesProvider);
    final accounts = ref.read(accountsProvider);
    final catId = _selectedCategoryId ?? (categories.isNotEmpty ? categories.first.id : null);
    final acctId = _selectedAccountId ?? (accounts.isNotEmpty ? accounts.first.id : null);

    if (amount <= 0 || catId == null || acctId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ENTER AMOUNT + SELECT CATEGORY & ACCOUNT',
            style: TextStyle(fontFamily: 'BebasNeue', letterSpacing: 1)),
      ));
      return;
    }
    if (_type == TransactionType.transfer && _selectedToAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('SELECT DESTINATION ACCOUNT',
            style: TextStyle(fontFamily: 'BebasNeue', letterSpacing: 1)),
      ));
      return;
    }

    final user = ref.read(currentUserProvider)!;
    ref.read(transactionServiceProvider).addTransaction(Transaction(
      userId: user.id,
      amount: amount,
      type: _type,
      categoryId: catId,
      accountId: acctId,
      toAccountId: _selectedToAccountId,
      note: _noteCtrl.text.isNotEmpty ? _noteCtrl.text : null,
    ));

    setState(() { _amountStr = '0'; _noteCtrl.clear(); });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.green,
      duration: const Duration(seconds: 2),
      content: Text('✓ ADDED ${formatINR(amount)}',
          style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 18, letterSpacing: 2, color: AppColors.black)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);
    if (_selectedCategoryId == null && categories.isNotEmpty) _selectedCategoryId = categories.first.id;
    if (_selectedAccountId == null && accounts.isNotEmpty) _selectedAccountId = accounts.first.id;

    final typeColors = {
      TransactionType.expense: AppColors.red,
      TransactionType.income: AppColors.green,
      TransactionType.transfer: AppColors.yellow,
    };

    return Column(
      children: [
        // TOP HEADER
        Container(
          color: AppColors.black,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(children: [
            Row(
              children: TransactionType.values.map((t) {
                final active = _type == t;
                final color = typeColors[t]!;
                final labels = {TransactionType.expense: 'EXPENSE', TransactionType.income: 'INCOME', TransactionType.transfer: 'TRANSFER'};
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() { _type = t; _selectedToAccountId = null; }),
                    child: Container(
                      margin: EdgeInsets.only(right: t != TransactionType.transfer ? 6 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? color : Colors.transparent,
                        border: Border.all(color: active ? color : const Color(0xFF444444), width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(labels[t]!, style: TextStyle(
                        fontFamily: 'BebasNeue', fontSize: 13, letterSpacing: 1.5,
                        color: active ? (t == TransactionType.income || t == TransactionType.transfer ? AppColors.black : Colors.white) : const Color(0xFF666666),
                      )),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹', style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 24, color: AppColors.yellow, height: 1.6)),
                const SizedBox(width: 2),
                Text(_amountStr, style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 52, color: AppColors.yellow, height: 1, letterSpacing: -1)),
              ],
            ),
          ]),
        ),

        // BODY
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Text('CATEGORY', style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 12, letterSpacing: 2, color: AppColors.mutedText)),
                const SizedBox(height: 4),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final cat = categories[i];
                      final sel = _selectedCategoryId == cat.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategoryId = cat.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.black : Colors.white,
                            border: Border.all(color: AppColors.black, width: 2),
                          ),
                          child: Row(children: [
                            Text(cat.icon, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 4),
                            Text(cat.name, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 13, color: sel ? AppColors.yellow : AppColors.black, letterSpacing: 1)),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Account
                Text('ACCOUNT', style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 12, letterSpacing: 2, color: AppColors.mutedText)),
                const SizedBox(height: 4),
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final a = accounts[i];
                      final sel = _selectedAccountId == a.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAccountId = a.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.blue : Colors.white,
                            border: Border.all(color: sel ? AppColors.blue : AppColors.black, width: 2),
                          ),
                          child: Text(a.name, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, fontWeight: FontWeight.bold, color: sel ? Colors.white : AppColors.black)),
                        ),
                      );
                    },
                  ),
                ),

                // Transfer to
                if (_type == TransactionType.transfer) ...[
                  const SizedBox(height: 8),
                  Text('TO ACCOUNT', style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 12, letterSpacing: 2, color: AppColors.mutedText)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: accounts.where((a) => a.id != _selectedAccountId).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final a = accounts.where((a) => a.id != _selectedAccountId).toList()[i];
                        final sel = _selectedToAccountId == a.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedToAccountId = a.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.pink : Colors.white,
                              border: Border.all(color: sel ? AppColors.pink : AppColors.black, width: 2),
                            ),
                            child: Text(a.name, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, fontWeight: FontWeight.bold, color: sel ? Colors.white : AppColors.black)),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _noteCtrl,
                    style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 11),
                    decoration: const InputDecoration(
                      hintText: 'Note (optional)',
                      hintStyle: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: AppColors.mutedText),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.black, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.blue, width: 2)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Numpad
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                  childAspectRatio: 2.4,
                  children: [
                    ...'123456789'.split('').map((n) => _NumKey(n, onTap: () => _numPress(n))),
                    _NumKey('.', onTap: () => _numPress('.')),
                    _NumKey('0', onTap: () => _numPress('0')),
                    _NumKey('⌫', bg: AppColors.black, textColor: AppColors.yellow, onTap: _numDel),
                  ],
                ),
                const SizedBox(height: 8),

                // ADD button
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      border: Border.fromBorderSide(BorderSide(color: AppColors.black, width: 3)),
                      boxShadow: [BoxShadow(color: AppColors.black, offset: Offset(4, 4), blurRadius: 0)],
                    ),
                    child: const Text('ADD TRANSACTION ★',
                        style: TextStyle(fontFamily: 'BebasNeue', fontSize: 20, letterSpacing: 3, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NumKey extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color bg;
  final Color textColor;
  const _NumKey(this.label, {required this.onTap, this.bg = Colors.white, this.textColor = AppColors.black});
  @override
  State<_NumKey> createState() => _NumKeyState();
}

class _NumKeyState extends State<_NumKey> {
  bool _p = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _p = true),
      onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
      onTapCancel: () => setState(() => _p = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: _p ? (Matrix4.identity()..translate(2.0, 2.0)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.bg,
          border: Border.all(color: AppColors.black, width: 2),
          boxShadow: _p ? [] : const [BoxShadow(color: AppColors.black, offset: Offset(2, 2), blurRadius: 0)],
        ),
        alignment: Alignment.center,
        child: Text(widget.label, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 22, color: widget.textColor)),
      ),
    );
  }
}
