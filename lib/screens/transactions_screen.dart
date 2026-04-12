import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

// ─── ALL TRANSACTIONS SCREEN ──────────────────────────────────────────────────

class AllTransactionsScreen extends ConsumerStatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  ConsumerState<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends ConsumerState<AllTransactionsScreen> {
  TransactionType? _filter;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);

    Category? getCat(String id) {
      try { return categories.firstWhere((c) => c.id == id); } catch (_) { return null; }
    }
    Account? getAcct(String id) {
      try { return accounts.firstWhere((a) => a.id == id); } catch (_) { return null; }
    }

    var filtered = transactions.where((t) {
      if (_filter != null && t.type != _filter) return false;
      if (_search.isNotEmpty) {
        final note = (t.note ?? '').toLowerCase();
        final cat = getCat(t.categoryId)?.name.toLowerCase() ?? '';
        if (!note.contains(_search.toLowerCase()) && !cat.contains(_search.toLowerCase())) return false;
      }
      return true;
    }).toList();

    // Group by date
    final Map<String, List<Transaction>> grouped = {};
    for (final t in filtered) {
      final key = DateFormat('d MMM yyyy').format(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: brutalCardSmall(),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('ALL TRANSACTIONS', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, letterSpacing: 2))),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'SEARCH...',
                  hintStyle: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, color: AppColors.mutedText, letterSpacing: 1),
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.mutedText),
                  enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.black, width: 2)),
                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.blue, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(label: 'ALL', active: _filter == null, onTap: () => setState(() => _filter = null)),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'EXPENSE', active: _filter == TransactionType.expense, color: AppColors.red, onTap: () => setState(() => _filter = TransactionType.expense)),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'INCOME', active: _filter == TransactionType.income, color: AppColors.green, onTap: () => setState(() => _filter = TransactionType.income)),
                  const SizedBox(width: 8),
                  _FilterChip(label: 'TRANSFER', active: _filter == TransactionType.transfer, color: AppColors.blue, onTap: () => setState(() => _filter = TransactionType.transfer)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: grouped.keys.length,
                itemBuilder: (_, i) {
                  final dateKey = grouped.keys.elementAt(i);
                  final dayTxns = grouped[dateKey]!;
                  final dayTotal = dayTxns.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        color: AppColors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dateKey.toUpperCase(), style: TextStyle(fontFamily: 'BebasNeue', fontSize: 14, color: AppColors.yellow, letterSpacing: 2)),
                            if (dayTotal > 0)
                              Text('-${formatINR(dayTotal)}', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: Colors.white60)),
                          ],
                        ),
                      ),
                      ...dayTxns.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TransactionListItem(
                          txn: t,
                          category: getCat(t.categoryId),
                          account: getAcct(t.accountId),
                          onTap: () => _showTxnDetail(context, ref, t, getCat(t.categoryId), getAcct(t.accountId)),
                        ),
                      )),
                      const SizedBox(height: 4),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTxnDetail(BuildContext context, WidgetRef ref, Transaction txn, Category? cat, Account? acct) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.paper,
      builder: (_) => _TransactionDetailSheet(txn: txn, category: cat, account: acct, ref: ref),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.active, this.color = AppColors.black, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : Colors.white,
          border: Border.all(color: active ? color : AppColors.lightBorder, width: 2),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 12, letterSpacing: 1, color: active ? Colors.white : AppColors.mutedText)),
      ),
    );
  }
}

// ─── TRANSACTION DETAIL SHEET ─────────────────────────────────────────────────

class _TransactionDetailSheet extends StatelessWidget {
  final Transaction txn;
  final Category? category;
  final Account? account;
  final WidgetRef ref;

  const _TransactionDetailSheet({required this.txn, this.category, this.account, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isExpense = txn.type == TransactionType.expense;
    final isIncome = txn.type == TransactionType.income;
    final amtColor = isIncome ? AppColors.green : isExpense ? AppColors.red : AppColors.blue;
    final sign = isIncome ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(width: 40, height: 4, color: AppColors.mutedText, margin: const EdgeInsets.only(bottom: 20)),

          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: Color(category?.colorValue ?? 0xFF888888),
                  border: Border.all(color: AppColors.black, width: 3),
                ),
                alignment: Alignment.center,
                child: Text(category?.icon ?? '?', style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(txn.note?.isNotEmpty == true ? txn.note!.toUpperCase() : category?.name.toUpperCase() ?? 'TRANSACTION',
                        style: TextStyle(fontFamily: 'BebasNeue', fontSize: 26, letterSpacing: 1)),
                    Text(category?.name ?? '', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: AppColors.mutedText)),
                  ],
                ),
              ),
              Text('$sign${formatINR(txn.amount)}',
                  style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, color: amtColor)),
            ],
          ),
          const SizedBox(height: 20),

          // Details grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: brutalCardSmall(),
            child: Column(
              children: [
                _DetailRow('Date', DateFormat('d MMMM yyyy, h:mm a').format(txn.date)),
                _DetailRow('Account', account?.name ?? 'Unknown'),
                _DetailRow('Type', txn.type.name.toUpperCase()),
                if (txn.note != null && txn.note!.isNotEmpty) _DetailRow('Note', txn.note!),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Delete button
          SizedBox(
            width: double.infinity,
            child: BrutalButton(
              label: 'DELETE TRANSACTION',
              bg: AppColors.red,
              onTap: () {
                ref.read(transactionServiceProvider).deleteTransaction(txn);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: AppColors.mutedText, letterSpacing: 1)),
          Text(value, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
