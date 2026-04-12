import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/models.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/budgets_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    navigationBarColor: AppColors.black,
    navigationBarIconBrightness: Brightness.light,
  ));

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(AccountTypeAdapter());
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(BudgetAdapter());

  await Future.wait([
    Hive.openBox<Account>('accounts'),
    Hive.openBox<Category>('categories'),
    Hive.openBox<Transaction>('transactions'),
    Hive.openBox<Budget>('budgets'),
  ]);

  await _seedDemoData();
  runApp(const ProviderScope(child: XpnsApp()));
}

Future<void> _seedDemoData() async {
  final acctBox = Hive.box<Account>('accounts');
  final catBox = Hive.box<Category>('categories');
  final txnBox = Hive.box<Transaction>('transactions');
  final budgetBox = Hive.box<Budget>('budgets');
  const userId = 'demo_user';

  if (catBox.isEmpty) {
    for (final cat in defaultCategories(userId)) { await catBox.add(cat); }
  }

  if (acctBox.isEmpty) {
    await acctBox.add(Account(userId: userId, name: 'SBI Savings', type: AccountType.bank, balance: 124300));
    await acctBox.add(Account(
      userId: userId, name: 'Axis Platinum CC', type: AccountType.creditCard,
      creditLimit: 150000, outstandingDue: 8200,
      dueDate: DateTime.now().add(const Duration(days: 11)),
    ));
    await acctBox.add(Account(userId: userId, name: 'PhonePe UPI', type: AccountType.upi, balance: 4280));
    await acctBox.add(Account(userId: userId, name: 'Cash', type: AccountType.cash, balance: 2400));
  }

  if (txnBox.isEmpty && catBox.isNotEmpty && acctBox.isNotEmpty) {
    final cats = catBox.values.toList();
    final accounts = acctBox.values.toList();
    final sbi = accounts.firstWhere((a) => a.name.contains('SBI'));
    final cc = accounts.firstWhere((a) => a.type == AccountType.creditCard);
    final upi = accounts.firstWhere((a) => a.type == AccountType.upi);
    Category catByName(String n) => cats.firstWhere((c) => c.name == n, orElse: () => cats.first);

    final now = DateTime.now();
    final demo = [
      Transaction(userId: userId, amount: 85000, type: TransactionType.income, categoryId: catByName('Salary').id, accountId: sbi.id, note: 'April Salary', date: DateTime(now.year, now.month, 1)),
      Transaction(userId: userId, amount: 640, type: TransactionType.expense, categoryId: catByName('Food').id, accountId: cc.id, note: 'Zomato', date: now.subtract(const Duration(hours: 2))),
      Transaction(userId: userId, amount: 280, type: TransactionType.expense, categoryId: catByName('Transport').id, accountId: cc.id, note: 'Uber', date: now.subtract(const Duration(days: 1))),
      Transaction(userId: userId, amount: 1840, type: TransactionType.expense, categoryId: catByName('Groceries').id, accountId: upi.id, note: 'Big Basket', date: now.subtract(const Duration(days: 2))),
      Transaction(userId: userId, amount: 649, type: TransactionType.expense, categoryId: catByName('Subscriptions').id, accountId: cc.id, note: 'Netflix', date: now.subtract(const Duration(days: 3))),
      Transaction(userId: userId, amount: 3200, type: TransactionType.expense, categoryId: catByName('Food').id, accountId: cc.id, note: 'Swiggy weekend', date: now.subtract(const Duration(days: 4))),
      Transaction(userId: userId, amount: 1200, type: TransactionType.expense, categoryId: catByName('Transport').id, accountId: upi.id, note: 'Ola monthly', date: now.subtract(const Duration(days: 5))),
      Transaction(userId: userId, amount: 2000, type: TransactionType.expense, categoryId: catByName('Groceries').id, accountId: upi.id, note: 'DMart', date: now.subtract(const Duration(days: 6))),
      Transaction(userId: userId, amount: 500, type: TransactionType.expense, categoryId: catByName('Health').id, accountId: upi.id, note: 'PharmEasy', date: now.subtract(const Duration(days: 7))),
      Transaction(userId: userId, amount: 800, type: TransactionType.expense, categoryId: catByName('Entertainment').id, accountId: upi.id, note: 'Inox movie', date: now.subtract(const Duration(days: 8))),
      Transaction(userId: userId, amount: 5000, type: TransactionType.transfer, categoryId: catByName('Transfer').id, accountId: sbi.id, toAccountId: cc.id, note: 'CC bill payment', date: now.subtract(const Duration(days: 9))),
    ];
    for (final t in demo) { await txnBox.add(t); }
  }

  if (budgetBox.isEmpty && catBox.isNotEmpty) {
    final cats = catBox.values.toList();
    Category catByName(String n) => cats.firstWhere((c) => c.name == n, orElse: () => cats.first);
    final budgets = [
      Budget(userId: userId, categoryId: catByName('Food').id, monthlyLimit: 12000),
      Budget(userId: userId, categoryId: catByName('Transport').id, monthlyLimit: 8000),
      Budget(userId: userId, categoryId: catByName('Groceries').id, monthlyLimit: 10000),
      Budget(userId: userId, categoryId: catByName('Subscriptions').id, monthlyLimit: 4000),
      Budget(userId: userId, categoryId: catByName('Entertainment').id, monthlyLimit: 5000),
    ];
    for (final b in budgets) { await budgetBox.add(b); }
  }
}

class XpnsApp extends StatelessWidget {
  const XpnsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XPNS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainShell(),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _idx = 0;

  static const _screens = [
    DashboardScreen(),
    AddTransactionScreen(),
    AccountsScreen(),
    AnalyticsScreen(),
    BudgetsScreen(),
    TransactionsScreen(),
    CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              RichText(
                text: TextSpan(children: [
                  const TextSpan(text: 'XPNS', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, color: AppColors.black, letterSpacing: 3)),
                  const TextSpan(text: '★', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 18, color: AppColors.red)),
                ]),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.black, width: 2),
                    boxShadow: const [BoxShadow(color: AppColors.black, offset: Offset(2, 2), blurRadius: 0)],
                  ),
                  child: const Icon(Icons.settings_outlined, size: 18, color: AppColors.black),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _idx, children: _screens),
      floatingActionButton: _idx != 1 ? _BrutalFAB(onTap: () => setState(() => _idx = 1)) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _BottomNav(currentIndex: _idx, onTap: (i) => setState(() => _idx = i)),
    );
  }
}

class _BrutalFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _BrutalFAB({required this.onTap});
  @override
  State<_BrutalFAB> createState() => _BrutalFABState();
}

class _BrutalFABState extends State<_BrutalFAB> with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  late final Animation<double> _scale = Tween(begin: 1.0, end: 1.07).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() { _pressed = true; _pulse.stop(); }),
      onTapUp: (_) { setState(() => _pressed = false); _pulse.repeat(reverse: true); widget.onTap(); },
      onTapCancel: () { setState(() => _pressed = false); _pulse.repeat(reverse: true); },
      child: ScaleTransition(
        scale: _pressed ? const AlwaysStoppedAnimation(0.92) : _scale,
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: AppColors.red,
            border: Border.all(color: AppColors.black, width: 3),
            boxShadow: _pressed ? [] : const [BoxShadow(color: AppColors.black, offset: Offset(4, 4), blurRadius: 0)],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home, 'HOME'),
      (Icons.add_circle_outline, Icons.add_circle, 'ADD'),
      (Icons.credit_card_outlined, Icons.credit_card, 'WALLETS'),
      (Icons.show_chart, Icons.show_chart, 'CHARTS'),
      (Icons.star_border, Icons.star, 'BUDGETS'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.black,
        border: Border(top: BorderSide(color: AppColors.yellow, width: 3)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final (icon, iconActive, label) = e.value;
              final isActive = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 4, height: 4, margin: const EdgeInsets.only(bottom: 3),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.yellow : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Icon(isActive ? iconActive : icon, color: isActive ? AppColors.yellow : const Color(0xFF555555), size: 22),
                      const SizedBox(height: 3),
                      Text(label, style: TextStyle(
                          fontFamily: 'SpaceMono', fontSize: 7, letterSpacing: 0.5,
                          color: isActive ? AppColors.yellow : const Color(0xFF555555))),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
