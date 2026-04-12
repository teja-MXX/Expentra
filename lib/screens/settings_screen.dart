import '../models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'categories_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border.fromBorderSide(BorderSide(color: AppColors.black, width: 2)),
                        boxShadow: [BoxShadow(color: AppColors.black, offset: Offset(2, 2), blurRadius: 0)],
                      ),
                      child: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('SETTINGS', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 40, letterSpacing: 2)),
                ]),
              ),
              const SizedBox(height: 16),

              // Profile card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.black,
                  boxShadow: [BoxShadow(color: AppColors.yellow, offset: Offset(5, 5), blurRadius: 0)],
                ),
                child: Row(children: [
                  Container(
                    width: 52, height: 52,
                    color: AppColors.yellow,
                    alignment: Alignment.center,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 34, color: AppColors.black),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user?.name ?? 'User',
                        style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 22, color: AppColors.yellow, letterSpacing: 1)),
                    Text(user?.email ?? '',
                        style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: Colors.white54)),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),

              const SectionHead('MANAGE'),
              _Tile(
                icon: Icons.category_outlined,
                label: 'Categories',
                sub: 'Add, edit, delete categories',
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: AppColors.paper,
                    body: SafeArea(child: const CategoriesScreen()),
                  ),
                )),
              ),
              _Tile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Edit Profile Name',
                sub: 'Change your display name',
                onTap: () => _editName(context, ref, user?.name ?? ''),
              ),

              const SectionHead('DATA'),
              _Tile(
                icon: Icons.file_download_outlined,
                label: 'Export to CSV',
                sub: 'Download all transactions',
                onTap: () => _exportCSV(context, ref),
              ),
              _Tile(
                icon: Icons.restore_outlined,
                label: 'Reset & Reseed Demo Data',
                sub: 'Wipe all data and reload samples',
                onTap: () => _confirmReset(context, ref),
                danger: true,
              ),

              const SectionHead('APP'),
              _Tile(icon: Icons.info_outlined, label: 'Version', sub: '1.0.0 · Flutter · Hive', onTap: () {}),
              _Tile(icon: Icons.palette_outlined, label: 'Design', sub: 'Maximalist mixed-media aesthetic', onTap: () {}),

              const SizedBox(height: 40),
              Center(child: Column(children: [
                const Text('★ XPNS TRACKER ★', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 20, letterSpacing: 3, color: AppColors.mutedText)),
                const SizedBox(height: 4),
                const Text('TRACK EVERY RUPEE', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: AppColors.mutedText, letterSpacing: 2)),
              ])),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _editName(BuildContext context, WidgetRef ref, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.paper,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('EDIT NAME', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 28, letterSpacing: 2)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 13),
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.black, width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.blue, width: 2)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.black, width: 2)),
                  alignment: Alignment.center,
                  child: const Text('CANCEL', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2))),
              )),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: () {
                  if (ctrl.text.trim().isEmpty) return;
                  final u = ref.read(currentUserProvider);
                  if (u != null) {
                    ref.read(currentUserProvider.notifier).state = AppUser(id: u.id, name: ctrl.text.trim(), email: u.email);
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.blue,
                    border: Border.fromBorderSide(BorderSide(color: AppColors.black, width: 2)),
                    boxShadow: [BoxShadow(color: AppColors.black, offset: Offset(3, 3), blurRadius: 0)],
                  ),
                  alignment: Alignment.center,
                  child: const Text('SAVE', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2, color: Colors.white)),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  void _exportCSV(BuildContext context, WidgetRef ref) {
    final txns = ref.read(transactionsProvider);
    final cats = ref.read(categoriesProvider);
    final accounts = ref.read(accountsProvider);

    String csv = 'Date,Type,Amount,Category,Account,Note\n';
    for (final t in txns) {
      final cat = cats.where((c) => c.id == t.categoryId).map((c) => c.name).firstOrNull ?? '';
      final acct = accounts.where((a) => a.id == t.accountId).map((a) => a.name).firstOrNull ?? '';
      csv += '${t.date.toIso8601String()},${t.type.name},${t.amount},$cat,$acct,${t.note ?? ''}\n';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.green,
      duration: const Duration(seconds: 3),
      content: Text('CSV READY · ${txns.length} TRANSACTIONS',
          style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2, color: AppColors.black)),
    ));
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.paper,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: BorderSide(color: AppColors.black, width: 3)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('RESET ALL DATA?', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 26, letterSpacing: 2)),
            const SizedBox(height: 8),
            const Text('Wipes everything and reloads demo data. Cannot be undone.',
                style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, height: 1.6)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.black, width: 2)),
                  alignment: Alignment.center,
                  child: const Text('CANCEL', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2)),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await ref.read(accountBoxProvider).clear();
                  await ref.read(categoryBoxProvider).clear();
                  await ref.read(transactionBoxProvider).clear();
                  await ref.read(budgetBoxProvider).clear();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('DATA RESET · RESTART APP TO RESEED',
                          style: TextStyle(fontFamily: 'BebasNeue', letterSpacing: 1)),
                    ));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    border: Border.fromBorderSide(BorderSide(color: AppColors.black, width: 2)),
                    boxShadow: [BoxShadow(color: AppColors.black, offset: Offset(3, 3), blurRadius: 0)],
                  ),
                  alignment: Alignment.center,
                  child: const Text('RESET ★', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2, color: Colors.white)),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label, sub;
  final VoidCallback onTap;
  final bool danger;
  const _Tile({required this.icon, required this.label, required this.sub, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final c = danger ? AppColors.red : AppColors.black;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: c, width: 2),
          boxShadow: [BoxShadow(color: c, offset: const Offset(3, 3), blurRadius: 0)],
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: c),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12, fontWeight: FontWeight.bold, color: c)),
            Text(sub, style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: AppColors.mutedText)),
          ])),
          Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.mutedText),
        ]),
      ),
    );
  }
}
