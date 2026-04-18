import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netWorth = ref.watch(netWorthProvider);
    final monthlySpend = ref.watch(monthlySpendProvider);
    final monthlyIncome = ref.watch(monthlyIncomeProvider);
    final dailyAvg = ref.watch(dailyAverageSpendProvider);
    final topCat = ref.watch(topCategoryProvider);
    final transactions = ref.watch(transactionsProvider).take(5).toList();
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(accountsProvider);

    Category? getCat(String id) {
      try { return categories.firstWhere((c) => c.id == id); } catch (_) { return null; }
    }

    Account? getAcct(String id) {
      try { return accounts.firstWhere((a) => a.id == id); } catch (_) { return null; }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TickerTape(
            text: '★ XPNS TRACKER *** WHERE DID YOUR MONEY GO *** NET WORTH LIVE *** TRACK EVERY RUPEE *** BUDGET ALERTS *** SMART INSIGHTS *** CREDIT CARD LOGIC *** ★ XPNS TRACKER *** WHERE DID YOUR MONEY GO *** NET WORTH LIVE ***',
          ),

          ScreenHeader(
            title: 'DASH',
            subtitle: 'April 2025 · Hyderabad',
            trailing: const StickerTag('APR 2025', rotate: 2),
          ),

          // NET WORTH BLOCK
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.black,
              border: Border.fromBorderSide(
                BorderSide(color: AppColors.black, width: 3),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -22,
                  top: 0,
                  child: Text(
                    'NET\nWORTH',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 52,
                      color: Color(0xFF1a1a1a),
                      height: 1,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL NET WORTH',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 10,
                        color: Colors.white60,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatINR(netWorth),
                      style: TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 48,
                        color: AppColors.yellow,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'monthly spend: ${formatINR(monthlySpend)}  ·  income: ${formatINR(monthlyIncome)}',
                      style: TextStyle(
                        fontFamily: 'SpaceMono',
                        fontSize: 9,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // STATS GRID
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                StatCard(
                  label: 'Monthly Spend',
                  value: formatINR(monthlySpend),
                  sub: '↑ 14% vs last month',
                  accentColor: AppColors.red,
                ),
                StatCard(
                  label: 'Daily Average',
                  value: formatINR(dailyAvg),
                  sub: '${30 - DateTime.now().day} days left',
                  accentColor: AppColors.blue,
                ),
                StatCard(
                  label: 'Top Category',
                  value: topCat != null
                      ? (topCat['category'] as Category).name
                      : 'N/A',
                  sub: topCat != null
                      ? formatINR(topCat['amount'] as double)
                      : '',
                  accentColor: AppColors.pink,
                ),
                StatCard(
                  label: 'Saved This Mo',
                  value: formatINR(monthlyIncome - monthlySpend),
                  sub: monthlyIncome > monthlySpend
                      ? '↑ on track!'
                      : '↓ over budget',
                  accentColor: AppColors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          const InsightCard(
            headline: 'ZOMATO IS EATING YOU',
            body:
                'You spent ₹4,800 on food delivery this month — 39% more than last month. Consider cooking 3x a week to save ~₹2,000.',
          ),

          const SectionHead('RECENT'),

          // TRANSACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ...transactions.map((txn) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TransactionListItem(
                        txn: txn,
                        category: getCat(txn.categoryId),
                        account: getAcct(txn.accountId),
                      ),
                    )),
                if (transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Text(
                      'NO TRANSACTIONS YET\nADD ONE WITH + BELOW',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'BebasNeue',
                        fontSize: 22,
                        color: AppColors.mutedText,
                        letterSpacing: 2,
                        height: 1.4,
                      ),
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
}
