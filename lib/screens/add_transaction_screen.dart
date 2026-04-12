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
  final _noteController = TextEditingController();

  @override
  void dispose() { _noteController.dispose(); super.dispose(); }

  void _numPress(String v) {
    setState(() {
      if (v == '.' && _amountStr.contains('.')) return;
      if (_amountStr == '0' && v != '.') {
        _amountStr = v;
      } else {
        if (_amountStr.length < 10) _amountStr += v;
      }
    });
  }

  void _numDel() {
    setState(() {
      if (_amountStr.length <= 1) { _amountStr = '0'; return; }
      _amountStr = _amountStr.substring(0, _amountStr.length - 1);
    });
  }

  void _submit() {
    final amount = double.tryParse(_amountStr) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ENTER AN AMOUNT', style: TextStyle(fontFamily: 'BebasNeue', letterSpacing: 2))),
      );
      return;
    }
    if (_selectedCategoryId == null || _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SELECT CATEGORY + ACCOUNT', style: TextStyle(fontFamily: 'BebasNeue', letterSpacing: 2))),
      );
      return;
    }
    if (_type == TransactionType.transfer && _selectedToAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SELECT DESTINATION ACCOUNT', style: TextStyle(fontFamily: 'BebasNeue', letterSpacing: 2))),
      );
      return;
    }

    final user = ref.read(currentUserProvider)!;
    final txn = Transaction(
      userId: user.id,
      amount: amount,
      type: _type,
      categoryId: _selectedCategoryId!,
      accountId: _selectedAccountId!,
      toAccountId: _selectedToAccountId,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    ref.read(transactionServiceProvider).addTransaction(txn);
    setState(() { _amountStr = '0'; });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.green,
        content: Text('ADDED! ${formatINR(amount)}', style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 18, letterSpacing: 2, color: AppColors.black)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);

    // auto-select first if not set
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      _selectedAccountId = accounts.first.id;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // HEADER with type toggle + amount
          Container(
            color: AppColors.black,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                // Type toggle
                Row(
                  children: TransactionType.values.map((t) {
                    final isActive = _type == t;
                    final configs = {
                      TransactionType.expense: (AppColors.red, 'EXPENSE'),
                      TransactionType.income: (AppColors.green, 'INCOME'),
                      TransactionType.transfer: (AppColors.yellow, 'TRANSFER'),
                    };
                    final (color, label) = configs[t]!;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = t),
                        child: Container(
                          margin: EdgeInsets.only(right: t != TransactionType.transfer ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? color : Colors.transparent,
                            border: Border.all(color: isActive ? color : const Color(0xFF555555), width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(label,
                              style: TextStyle(
                                  fontFamily: 'BebasNeue', fontSize: 15, letterSpacing: 2,
                                  color: isActive ? (t == TransactionType.income || t == TransactionType.transfer ? AppColors.black : Colors.white) : const Color(0xFF777777))),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Amount display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('₹', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 32, color: AppColors.yellow, height: 1.4)),
                    const SizedBox(width: 4),
                    Text(_amountStr,
                        style: TextStyle(fontFamily: 'BebasNeue', fontSize: 64, color: AppColors.yellow, height: 1, letterSpacing: -2)),
                  ],
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category
                Text('CATEGORY', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 13, letterSpacing: 2, color: AppColors.mutedText)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = categories[i];
                      final isSel = _selectedCategoryId == cat.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategoryId = cat.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.black : Colors.white,
                            border: Border.all(color: AppColors.black, width: 2),
                          ),
                          child: Row(
                            children: [
                              Text(cat.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(cat.name, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 14, color: isSel ? AppColors.yellow : AppColors.black, letterSpacing: 1)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Account
                Text('FROM ACCOUNT', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 13, letterSpacing: 2, color: AppColors.mutedText)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: accounts.map((a) {
                    final isSel = _selectedAccountId == a.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAccountId = a.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.blue : Colors.white,
                          border: Border.all(color: isSel ? AppColors.blue : AppColors.black, width: 2),
                        ),
                        child: Text(a.name,
                            style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.bold,
                                color: isSel ? Colors.white : AppColors.black, letterSpacing: 0.5)),
                      ),
                    );
                  }).toList(),
                ),

                // Transfer destination
                if (_type == TransactionType.transfer) ...[
                  const SizedBox(height: 14),
                  Text('TO ACCOUNT', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 13, letterSpacing: 2, color: AppColors.mutedText)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: accounts.where((a) => a.id != _selectedAccountId).map((a) {
                      final isSel = _selectedToAccountId == a.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedToAccountId = a.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.pink : Colors.white,
                            border: Border.all(color: isSel ? AppColors.pink : AppColors.black, width: 2),
                          ),
                          child: Text(a.name,
                              style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.bold,
                                  color: isSel ? Colors.white : AppColors.black)),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 14),
                // Note field
                TextField(
                  controller: _noteController,
                  style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'NOTE (optional)',
                    hintStyle: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, color: AppColors.mutedText, letterSpacing: 1),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: AppColors.black, width: 2)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: const BorderSide(color: AppColors.blue, width: 2)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // NUMPAD
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                  childAspectRatio: 1.5,
                  children: [
                    ...'123456789'.split('').map((n) => _NumKey(n, onTap: () => _numPress(n))),
                    _NumKey('.', onTap: () => _numPress('.')),
                    _NumKey('0', onTap: () => _numPress('0')),
                    _NumKey('⌫', bg: AppColors.black, textColor: AppColors.yellow, onTap: _numDel),
                  ],
                ),
                const SizedBox(height: 10),

                // Submit
                SizedBox(width: double.infinity, child: BrutalButton(label: 'ADD TRANSACTION ★', onTap: _submit)),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
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
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        transform: _pressed ? (Matrix4.identity()..translate(2.0, 2.0)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.bg,
          border: Border.all(color: AppColors.black, width: 2),
          boxShadow: _pressed ? [] : const [BoxShadow(color: AppColors.black, offset: Offset(2, 2), blurRadius: 0)],
        ),
        alignment: Alignment.center,
        child: Text(widget.label, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, color: widget.textColor)),
      ),
    );
  }
}
