import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

// ─── HIVE BOX PROVIDERS ───────────────────────────────────────────────────────

final accountBoxProvider = Provider<Box<Account>>((ref) => Hive.box<Account>('accounts'));
final categoryBoxProvider = Provider<Box<Category>>((ref) => Hive.box<Category>('categories'));
final transactionBoxProvider = Provider<Box<Transaction>>((ref) => Hive.box<Transaction>('transactions'));
final budgetBoxProvider = Provider<Box<Budget>>((ref) => Hive.box<Budget>('budgets'));

// ─── CURRENT USER ─────────────────────────────────────────────────────────────

final currentUserProvider = StateProvider<AppUser?>((ref) => AppUser(
  id: 'demo_user',
  name: 'Arjun Sharma',
  email: 'arjun@example.com',
));

// ─── ACCOUNTS ─────────────────────────────────────────────────────────────────

final accountsProvider = Provider<List<Account>>((ref) {
  final box = ref.watch(accountBoxProvider);
  return box.values.toList();
});

final netWorthProvider = Provider<double>((ref) {
  final accounts = ref.watch(accountsProvider);
  double total = 0;
  for (final a in accounts) {
    if (a.isCreditCard) {
      total -= a.outstandingDue;
    } else {
      total += a.balance;
    }
  }
  return total;
});

// ─── TRANSACTIONS ─────────────────────────────────────────────────────────────

final transactionsProvider = Provider<List<Transaction>>((ref) {
  final box = ref.watch(transactionBoxProvider);
  final list = box.values.toList();
  list.sort((a, b) => b.date.compareTo(a.date));
  return list;
});

final monthlyTransactionsProvider = Provider.family<List<Transaction>, DateTime>((ref, month) {
  final txns = ref.watch(transactionsProvider);
  return txns.where((t) => t.date.year == month.year && t.date.month == month.month).toList();
});

final monthlySpendProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final txns = ref.watch(monthlyTransactionsProvider(now));
  return txns.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
});

final monthlyIncomeProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final txns = ref.watch(monthlyTransactionsProvider(now));
  return txns.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
});

final dailyAverageSpendProvider = Provider<double>((ref) {
  final spend = ref.watch(monthlySpendProvider);
  final day = DateTime.now().day;
  return day > 0 ? spend / day : 0;
});

// ─── CATEGORIES ───────────────────────────────────────────────────────────────

final categoriesProvider = Provider<List<Category>>((ref) {
  final box = ref.watch(categoryBoxProvider);
  return box.values.toList();
});

final topCategoryProvider = Provider<Map<String, dynamic>?>((ref) {
  final now = DateTime.now();
  final txns = ref.watch(monthlyTransactionsProvider(now))
      .where((t) => t.type == TransactionType.expense)
      .toList();
  final cats = ref.watch(categoriesProvider);

  if (txns.isEmpty) return null;

  final Map<String, double> totals = {};
  for (final t in txns) {
    totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
  }
  final topId = totals.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  final cat = cats.firstWhere((c) => c.id == topId, orElse: () => cats.first);
  return {'category': cat, 'amount': totals[topId]};
});

final categorySpendProvider = Provider<Map<String, double>>((ref) {
  final now = DateTime.now();
  final txns = ref.watch(monthlyTransactionsProvider(now))
      .where((t) => t.type == TransactionType.expense)
      .toList();
  final Map<String, double> totals = {};
  for (final t in txns) {
    totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
  }
  return totals;
});

// ─── BUDGETS ──────────────────────────────────────────────────────────────────

final budgetsProvider = Provider<List<Budget>>((ref) {
  final box = ref.watch(budgetBoxProvider);
  return box.values.toList();
});

final budgetStatusProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final budgets = ref.watch(budgetsProvider);
  final spend = ref.watch(categorySpendProvider);
  final cats = ref.watch(categoriesProvider);

  return budgets.map((b) {
    final spent = spend[b.categoryId] ?? 0.0;
    final pct = b.monthlyLimit > 0 ? spent / b.monthlyLimit : 0.0;
    final cat = cats.firstWhere((c) => c.id == b.categoryId, orElse: () => cats.first);
    return {
      'budget': b,
      'category': cat,
      'spent': spent,
      'pct': pct,
      'status': pct >= 1.0 ? 'over' : pct >= 0.8 ? 'warn' : 'safe',
    };
  }).toList();
});

// ─── TRANSACTION OPERATIONS ───────────────────────────────────────────────────

class TransactionService {
  final Box<Transaction> txnBox;
  final Box<Account> acctBox;

  TransactionService(this.txnBox, this.acctBox);

  void addTransaction(Transaction txn) {
    final account = acctBox.values.firstWhere((a) => a.id == txn.accountId);

    switch (txn.type) {
      case TransactionType.expense:
        if (account.isCreditCard) {
          account.outstandingDue += txn.amount;
        } else {
          account.balance -= txn.amount;
        }
        account.save();
        break;

      case TransactionType.income:
        account.balance += txn.amount;
        account.save();
        break;

      case TransactionType.transfer:
        // Deduct from source
        if (account.isCreditCard) {
          account.outstandingDue += txn.amount;
        } else {
          account.balance -= txn.amount;
        }
        account.save();

        // Credit to destination (if it's a CC payment: reduce due)
        if (txn.toAccountId != null) {
          final dest = acctBox.values.firstWhere((a) => a.id == txn.toAccountId);
          if (dest.isCreditCard) {
            dest.outstandingDue -= txn.amount;
            if (dest.outstandingDue < 0) dest.outstandingDue = 0;
          } else {
            dest.balance += txn.amount;
          }
          dest.save();
        }
        break;
    }

    txnBox.add(txn);
  }

  void deleteTransaction(Transaction txn) {
    // Reverse the balance effect
    final account = acctBox.values.firstWhere((a) => a.id == txn.accountId);

    switch (txn.type) {
      case TransactionType.expense:
        if (account.isCreditCard) {
          account.outstandingDue -= txn.amount;
        } else {
          account.balance += txn.amount;
        }
        account.save();
        break;

      case TransactionType.income:
        account.balance -= txn.amount;
        account.save();
        break;

      case TransactionType.transfer:
        if (account.isCreditCard) {
          account.outstandingDue -= txn.amount;
        } else {
          account.balance += txn.amount;
        }
        account.save();
        if (txn.toAccountId != null) {
          final dest = acctBox.values.firstWhere((a) => a.id == txn.toAccountId);
          if (dest.isCreditCard) {
            dest.outstandingDue += txn.amount;
          } else {
            dest.balance -= txn.amount;
          }
          dest.save();
        }
        break;
    }

    txn.delete();
  }
}

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(
    ref.watch(transactionBoxProvider),
    ref.watch(accountBoxProvider),
  );
});

// ─── SELECTED MONTH ──────────────────────────────────────────────────────────

final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
