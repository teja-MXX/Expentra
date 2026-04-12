import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'models.g.dart';

const _uuid = Uuid();

// ─── ENUMS ───────────────────────────────────────────────────────────────────

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0) expense,
  @HiveField(1) income,
  @HiveField(2) transfer,
}

@HiveType(typeId: 1)
enum AccountType {
  @HiveField(0) cash,
  @HiveField(1) bank,
  @HiveField(2) creditCard,
  @HiveField(3) upi,
}

// ─── USER ────────────────────────────────────────────────────────────────────

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  const AppUser({required this.id, required this.name, required this.email, this.photoUrl});

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'] as String,
        name: m['name'] as String,
        email: m['email'] as String,
        photoUrl: m['photoUrl'] as String?,
      );

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'email': email, 'photoUrl': photoUrl};
}

// ─── ACCOUNT ─────────────────────────────────────────────────────────────────

@HiveType(typeId: 2)
class Account extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String userId;
  @HiveField(2) String name;
  @HiveField(3) AccountType type;
  @HiveField(4) double balance;
  @HiveField(5) double? creditLimit;
  @HiveField(6) double outstandingDue;
  @HiveField(7) int? billingCycleStart;
  @HiveField(8) DateTime? dueDate;
  @HiveField(9) DateTime createdAt;

  Account({
    String? id,
    required this.userId,
    required this.name,
    required this.type,
    this.balance = 0,
    this.creditLimit,
    this.outstandingDue = 0,
    this.billingCycleStart,
    this.dueDate,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  double get availableCredit => (creditLimit ?? 0) - outstandingDue;

  bool get isCreditCard => type == AccountType.creditCard;

  factory Account.fromMap(Map<String, dynamic> m) => Account(
        id: m['id'],
        userId: m['userId'],
        name: m['name'],
        type: AccountType.values.firstWhere((e) => e.name == m['type']),
        balance: (m['balance'] as num).toDouble(),
        creditLimit: m['creditLimit'] != null ? (m['creditLimit'] as num).toDouble() : null,
        outstandingDue: (m['outstandingDue'] as num? ?? 0).toDouble(),
        billingCycleStart: m['billingCycleStart'] as int?,
        dueDate: m['dueDate'] != null ? DateTime.parse(m['dueDate']) : null,
        createdAt: DateTime.parse(m['createdAt']),
      );

  Map<String, dynamic> toMap() => {
        'id': id, 'userId': userId, 'name': name, 'type': type.name,
        'balance': balance, 'creditLimit': creditLimit, 'outstandingDue': outstandingDue,
        'billingCycleStart': billingCycleStart,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };
}

// ─── CATEGORY ────────────────────────────────────────────────────────────────

@HiveType(typeId: 3)
class Category extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String userId;
  @HiveField(2) String name;
  @HiveField(3) String icon;
  @HiveField(4) int colorValue;
  @HiveField(5) String? parentCategoryId;

  Category({
    String? id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.colorValue,
    this.parentCategoryId,
  }) : id = id ?? _uuid.v4();

  factory Category.fromMap(Map<String, dynamic> m) => Category(
        id: m['id'], userId: m['userId'], name: m['name'],
        icon: m['icon'], colorValue: m['colorValue'] as int,
        parentCategoryId: m['parentCategoryId'],
      );

  Map<String, dynamic> toMap() => {
        'id': id, 'userId': userId, 'name': name, 'icon': icon,
        'colorValue': colorValue, 'parentCategoryId': parentCategoryId,
      };
}

// ─── TRANSACTION ─────────────────────────────────────────────────────────────

@HiveType(typeId: 4)
class Transaction extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String userId;
  @HiveField(2) double amount;
  @HiveField(3) TransactionType type;
  @HiveField(4) String categoryId;
  @HiveField(5) String accountId;
  @HiveField(6) String? toAccountId;
  @HiveField(7) String? note;
  @HiveField(8) DateTime date;
  @HiveField(9) bool isRecurring;
  @HiveField(10) String? recurringId;

  Transaction({
    String? id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    this.note,
    DateTime? date,
    this.isRecurring = false,
    this.recurringId,
  })  : id = id ?? _uuid.v4(),
        date = date ?? DateTime.now();

  factory Transaction.fromMap(Map<String, dynamic> m) => Transaction(
        id: m['id'], userId: m['userId'],
        amount: (m['amount'] as num).toDouble(),
        type: TransactionType.values.firstWhere((e) => e.name == m['type']),
        categoryId: m['categoryId'], accountId: m['accountId'],
        toAccountId: m['toAccountId'], note: m['note'],
        date: DateTime.parse(m['date']),
        isRecurring: m['isRecurring'] as bool? ?? false,
        recurringId: m['recurringId'],
      );

  Map<String, dynamic> toMap() => {
        'id': id, 'userId': userId, 'amount': amount, 'type': type.name,
        'categoryId': categoryId, 'accountId': accountId,
        'toAccountId': toAccountId, 'note': note,
        'date': date.toIso8601String(), 'isRecurring': isRecurring,
        'recurringId': recurringId,
      };
}

// ─── BUDGET ──────────────────────────────────────────────────────────────────

@HiveType(typeId: 5)
class Budget extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String userId;
  @HiveField(2) String categoryId;
  @HiveField(3) double monthlyLimit;

  Budget({
    String? id,
    required this.userId,
    required this.categoryId,
    required this.monthlyLimit,
  }) : id = id ?? _uuid.v4();

  factory Budget.fromMap(Map<String, dynamic> m) => Budget(
        id: m['id'], userId: m['userId'],
        categoryId: m['categoryId'],
        monthlyLimit: (m['monthlyLimit'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'id': id, 'userId': userId,
        'categoryId': categoryId, 'monthlyLimit': monthlyLimit,
      };
}

// ─── DEFAULT CATEGORIES ──────────────────────────────────────────────────────

List<Category> defaultCategories(String userId) => [
  Category(userId: userId, name: 'Food', icon: '🍕', colorValue: 0xFFE8230A),
  Category(userId: userId, name: 'Transport', icon: '🚗', colorValue: 0xFF1B3FFF),
  Category(userId: userId, name: 'Groceries', icon: '🛒', colorValue: 0xFFFFE600),
  Category(userId: userId, name: 'Health', icon: '💊', colorValue: 0xFF00C46A),
  Category(userId: userId, name: 'Subscriptions', icon: '📺', colorValue: 0xFFFF3CAC),
  Category(userId: userId, name: 'Entertainment', icon: '🎮', colorValue: 0xFF9B59B6),
  Category(userId: userId, name: 'Rent', icon: '🏠', colorValue: 0xFF2C3E50),
  Category(userId: userId, name: 'Travel', icon: '✈️', colorValue: 0xFF3498DB),
  Category(userId: userId, name: 'Shopping', icon: '🛍️', colorValue: 0xFFE67E22),
  Category(userId: userId, name: 'Salary', icon: '💰', colorValue: 0xFF00C46A),
  Category(userId: userId, name: 'Freelance', icon: '💻', colorValue: 0xFF1B3FFF),
  Category(userId: userId, name: 'Transfer', icon: '↔️', colorValue: 0xFF888888),
];

// ─── AUTO CATEGORIZATION ─────────────────────────────────────────────────────

String autoCategorize(String merchantName, List<Category> categories) {
  final name = merchantName.toLowerCase();
  final Map<String, String> rules = {
    'zomato': 'Food', 'swiggy': 'Food', 'blinkit': 'Food', 'dunzo': 'Food',
    'uber': 'Transport', 'ola': 'Transport', 'rapido': 'Transport', 'irctc': 'Travel',
    'bigbasket': 'Groceries', 'dmart': 'Groceries', 'reliance': 'Groceries',
    'netflix': 'Subscriptions', 'spotify': 'Subscriptions', 'hotstar': 'Subscriptions', 'prime': 'Subscriptions',
    'apollo': 'Health', 'pharmeasy': 'Health', 'practo': 'Health',
    'amazon': 'Shopping', 'flipkart': 'Shopping', 'myntra': 'Shopping',
    'salary': 'Salary', 'payroll': 'Salary',
  };
  for (final entry in rules.entries) {
    if (name.contains(entry.key)) {
      return categories.firstWhere((c) => c.name == entry.value, orElse: () => categories.first).id;
    }
  }
  return categories.isNotEmpty ? categories.first.id : '';
}
