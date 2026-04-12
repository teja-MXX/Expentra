import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetStatus = ref.watch(budgetStatusProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(
            title: 'BUDGETS',
            subtitle: 'Monthly limits · April 2025',
            trailing: Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 8),
              child: GestureDetector(
                onTap: () => _showAddBudgetDialog(context, ref),
                child: const StickerTag('+ NEW', bg: AppColors.green),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ...budgetStatus.map((bs) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BudgetItem(budgetStatus: bs),
                )),
                if (budgetStatus.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    decoration: brutalCardSmall(),
                    child: Column(
                      children: [
                        Text('NO BUDGETS', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, color: AppColors.mutedText, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text('Tap + NEW to set a monthly limit', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, color: AppColors.mutedText)),
                        const SizedBox(height: 16),
                        BrutalButton(label: 'ADD FIRST BUDGET', onTap: () => _showAddBudgetDialog(context, ref), bg: AppColors.yellow, textColor: AppColors.black),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, WidgetRef ref) {
    final categories = ref.read(categoriesProvider);
    String? selectedCatId = categories.isNotEmpty ? categories.first.id : null;
    final limitCtrl = TextEditingController();

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
              Text('SET BUDGET', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 32, letterSpacing: 2)),
              const SizedBox(height: 16),
              Text('CATEGORY', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 13, letterSpacing: 2, color: AppColors.mutedText)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: categories.map((cat) {
                  final isSel = selectedCatId == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCatId = cat.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.black : Colors.white,
                        border: Border.all(color: AppColors.black, width: 2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat.icon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(cat.name, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 14, color: isSel ? AppColors.yellow : AppColors.black, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('MONTHLY LIMIT (₹)', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 13, letterSpacing: 2, color: AppColors.mutedText)),
              const SizedBox(height: 8),
              TextField(
                controller: limitCtrl,
                keyboardType: TextInputType.number,
                style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, letterSpacing: 1),
                decoration: InputDecoration(
                  hintText: '5000',
                  hintStyle: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, color: AppColors.mutedText),
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, color: AppColors.mutedText),
                  enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.black, width: 2)),
                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.blue, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: BrutalButton(
                  label: 'SET BUDGET ★',
                  onTap: () {
                    final limit = double.tryParse(limitCtrl.text) ?? 0;
                    if (limit <= 0 || selectedCatId == null) return;
                    final user = ref.read(currentUserProvider)!;
                    final budget = Budget(userId: user.id, categoryId: selectedCatId!, monthlyLimit: limit);
                    ref.read(budgetBoxProvider).add(budget);
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

class _BudgetItem extends StatelessWidget {
  final Map<String, dynamic> budgetStatus;

  const _BudgetItem({required this.budgetStatus});

  @override
  Widget build(BuildContext context) {
    final budget = budgetStatus['budget'] as Budget;
    final cat = budgetStatus['category'] as Category;
    final spent = budgetStatus['spent'] as double;
    final pct = (budgetStatus['pct'] as double).clamp(0.0, 1.0);
    final status = budgetStatus['status'] as String;

    final fillColor = status == 'over' ? AppColors.red : status == 'warn' ? AppColors.yellow : AppColors.green;
    final statusLabel = status == 'over' ? 'OVER BUDGET' : status == 'warn' ? 'ALMOST FULL' : null;
    final statusBg = status == 'over' ? AppColors.red : AppColors.yellow;
    final statusFg = status == 'over' ? Colors.white : AppColors.black;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.black, width: 3),
        boxShadow: const [BoxShadow(color: AppColors.black, offset: Offset(4, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(cat.name.toUpperCase(), style: TextStyle(fontFamily: 'BebasNeue', fontSize: 20, letterSpacing: 1)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatINR(spent),
                      style: TextStyle(fontFamily: 'BebasNeue', fontSize: 20, color: status == 'over' ? AppColors.red : status == 'warn' ? AppColors.yellow.withRed(200) : AppColors.black)),
                  Text('of ${formatINR(budget.monthlyLimit)}',
                      style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: AppColors.mutedText)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8DC),
              border: Border.all(color: AppColors.black, width: 2),
            ),
            child: FractionallySizedBox(
              widthFactor: pct,
              alignment: Alignment.centerLeft,
              child: Container(color: fillColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status == 'over'
                    ? '${(pct * 100).round()}% · ${formatINR(spent - budget.monthlyLimit)} over!'
                    : '${(pct * 100).round()}% · ${formatINR(budget.monthlyLimit - spent)} left',
                style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: AppColors.mutedText),
              ),
              if (statusLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusBg,
                    border: Border.all(color: AppColors.black, width: 2),
                  ),
                  child: Text(statusLabel, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 11, letterSpacing: 1, color: statusFg)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
