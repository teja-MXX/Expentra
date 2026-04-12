import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorySpend = ref.watch(categorySpendProvider);
    final categories = ref.watch(categoriesProvider);
    final transactions = ref.watch(transactionsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(child: ScreenHeader(title: 'ANALYTICS')),
              Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 8),
                child: StickerTag('APR', bg: AppColors.red, textColor: Colors.white, rotate: 2),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // PIE CHART
          _ChartBlock(
            title: 'SPEND BY CATEGORY',
            trailing: formatINR(categorySpend.values.fold(0.0, (a, b) => a + b)),
            child: _PieChartWidget(categorySpend: categorySpend, categories: categories),
          ),

          const SizedBox(height: 14),

          // BAR CHART - daily spend this week
          _ChartBlock(
            title: 'DAILY SPEND — THIS WEEK',
            child: _BarChartWidget(transactions: transactions),
          ),

          const SizedBox(height: 14),

          // MONTHLY COMPARISON
          _ChartBlock(
            title: 'MONTH COMPARISON',
            child: _MonthCompareWidget(transactions: transactions),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ChartBlock extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;

  const _ChartBlock({required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.black, width: 3),
        boxShadow: const [BoxShadow(color: AppColors.black, offset: Offset(5, 5), blurRadius: 0)],
      ),
      child: Column(
        children: [
          Container(
            color: AppColors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 18, letterSpacing: 2, color: AppColors.yellow)),
                if (trailing != null)
                  Text(trailing!, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final Map<String, double> categorySpend;
  final List<Category> categories;

  const _PieChartWidget({required this.categorySpend, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categorySpend.isEmpty) {
      return Center(child: Text('NO DATA YET', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 20, color: AppColors.mutedText, letterSpacing: 2)));
    }

    final total = categorySpend.values.fold(0.0, (a, b) => a + b);
    final sorted = categorySpend.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    final colors = [AppColors.red, AppColors.blue, AppColors.yellow, AppColors.pink, AppColors.green];

    return Row(
      children: [
        SizedBox(
          width: 120, height: 120,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: top5.asMap().entries.map((e) {
                final i = e.key;
                final pct = total > 0 ? (e.value.value / total * 100) : 0;
                return PieChartSectionData(
                  value: e.value.value,
                  color: colors[i % colors.length],
                  radius: 40,
                  showTitle: false,
                  borderSide: const BorderSide(color: AppColors.black, width: 2),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: top5.asMap().entries.map((e) {
              final i = e.key;
              Category? cat;
              try { cat = categories.firstWhere((c) => c.id == e.key.toString() || c.id == e.value.key); } catch (_) {}
              final pct = total > 0 ? (e.value.value / total * 100).round() : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[i % colors.length], border: Border.all(color: AppColors.black, width: 1.5))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(cat?.name ?? 'Category', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, letterSpacing: 0.5))),
                    Text('$pct%', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _BarChartWidget extends ConsumerWidget {
  final List<Transaction> transactions;
  const _BarChartWidget({required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final vals = List.generate(7, (i) {
      final day = weekStart.add(Duration(days: i));
      return transactions
          .where((t) => t.type == TransactionType.expense && t.date.year == day.year && t.date.month == day.month && t.date.day == day.day)
          .fold(0.0, (s, t) => s + t.amount);
    });

    final maxVal = vals.reduce((a, b) => a > b ? a : b);
    final todayIdx = now.weekday - 1;

    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          maxY: maxVal > 0 ? maxVal * 1.2 : 1000,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text(days[v.toInt()], style: TextStyle(fontFamily: 'BebasNeue', fontSize: 10, color: AppColors.mutedText)),
            )),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: vals.asMap().entries.map((e) => BarChartGroupData(
            x: e.key,
            barRods: [BarChartRodData(
              toY: e.value,
              color: e.key == todayIdx ? AppColors.yellow : AppColors.red,
              width: 28,
              borderSide: const BorderSide(color: AppColors.black, width: 2),
              borderRadius: BorderRadius.zero,
            )],
          )).toList(),
        ),
      ),
    );
  }
}

class _MonthCompareWidget extends StatelessWidget {
  final List<Transaction> transactions;
  const _MonthCompareWidget({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(4, (i) => DateTime(now.year, now.month - 3 + i, 1));

    final spends = months.map((m) {
      return transactions
          .where((t) => t.type == TransactionType.expense && t.date.year == m.year && t.date.month == m.month)
          .fold(0.0, (s, t) => s + t.amount);
    }).toList();

    return Row(
      children: months.asMap().entries.map((e) {
        final i = e.key;
        final isCur = i == 3;
        final prev = i > 0 ? spends[i - 1] : null;
        final delta = prev != null && prev > 0 ? ((spends[i] - prev) / prev * 100).round() : null;
        final monthName = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'][e.value.month - 1];

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCur ? AppColors.yellow : Colors.white,
              border: Border.all(color: AppColors.black, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isCur ? '$monthName ★' : monthName, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: AppColors.mutedText, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(formatINR(spends[i]), style: TextStyle(fontFamily: 'BebasNeue', fontSize: 18, color: AppColors.black, height: 1)),
                if (delta != null) ...[
                  const SizedBox(height: 2),
                  Text('${delta > 0 ? '↑' : '↓'} ${delta.abs()}%',
                      style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: delta > 0 ? AppColors.red : AppColors.green)),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
