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
import 'screens/transactions_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
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

  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool('onboarded') ?? false;
  final savedName = prefs.getString('user_name') ?? '';

  runApp(ProviderScope(
    overrides: [
      if (onboarded && savedName.isNotEmpty)
        currentUserProvider.overrideWith((ref) => AppUser(id: 'local_user', name: savedName, email: '')),
    ],
    child: XpnsApp(showOnboarding: !onboarded),
  ));
}

Future<void> _seedDemoData() async {
}

class XpnsApp extends StatelessWidget {
  final bool showOnboarding;
  const XpnsApp({super.key, this.showOnboarding = false});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XPNS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: showOnboarding ? '/onboarding' : '/home',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const MainShell(),
      },
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
