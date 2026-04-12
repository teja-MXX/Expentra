import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

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
                    Text('SETTINGS', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 40, letterSpacing: 2)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Profile card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  border: Border.all(color: AppColors.black, width: 3),
                  boxShadow: const [BoxShadow(color: AppColors.yellow, offset: Offset(5, 5), blurRadius: 0)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      color: AppColors.yellow,
                      alignment: Alignment.center,
                      child: Text(
                        user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                        style: TextStyle(fontFamily: 'BebasNeue', fontSize: 36, color: AppColors.black),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'User', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 24, color: AppColors.yellow, letterSpacing: 1)),
                        Text(user?.email ?? '', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: Colors.white60)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const SectionHead('PREFERENCES'),
              _SettingsTile(icon: Icons.category_outlined, label: 'Manage Categories', sub: 'Add, edit, delete categories', onTap: () {}),
              _SettingsTile(icon: Icons.notifications_outlined, label: 'Notifications', sub: 'Budget alerts, CC due reminders', onTap: () {}),
              _SettingsTile(icon: Icons.security_outlined, label: 'Biometric Lock', sub: 'Fingerprint / Face ID', onTap: () {}),

              const SectionHead('DATA'),
              _SettingsTile(icon: Icons.cloud_upload_outlined, label: 'Backup to Firebase', sub: 'Sync across devices', onTap: () {}),
              _SettingsTile(icon: Icons.file_download_outlined, label: 'Export to CSV', sub: 'Download your data', onTap: () {}),
              _SettingsTile(icon: Icons.restore_outlined, label: 'Reset Demo Data', sub: 'Wipe and reseed sample data',
                  onTap: () => _confirmReset(context, ref), danger: true),

              const SectionHead('APP INFO'),
              _SettingsTile(icon: Icons.info_outlined, label: 'Version', sub: '1.0.0 · Built with Flutter', onTap: () {}),
              _SettingsTile(icon: Icons.palette_outlined, label: 'Design', sub: 'Maximalist mixed-media aesthetic', onTap: () {}),
              const SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    Text('★ XPNS TRACKER ★', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 22, letterSpacing: 3, color: AppColors.mutedText)),
                    const SizedBox(height: 4),
                    Text('TRACK EVERY RUPEE', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: AppColors.mutedText, letterSpacing: 2)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.black, width: 3),
        ),
        title: Text('RESET ALL DATA?', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 24, letterSpacing: 2)),
        content: Text('This will delete everything and reload demo data. Cannot be undone.',
            style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, height: 1.6)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2, color: AppColors.black)),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await ref.read(accountBoxProvider).clear();
              await ref.read(categoryBoxProvider).clear();
              await ref.read(transactionBoxProvider).clear();
              await ref.read(budgetBoxProvider).clear();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.red,
              child: Text('RESET', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final bool danger;

  const _SettingsTile({required this.icon, required this.label, required this.sub, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: danger ? AppColors.red : AppColors.black, width: 2),
          boxShadow: [BoxShadow(color: danger ? AppColors.red : AppColors.black, offset: const Offset(3, 3), blurRadius: 0)],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: danger ? AppColors.red : AppColors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12, fontWeight: FontWeight.bold, color: danger ? AppColors.red : AppColors.black)),
                  Text(sub, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: AppColors.mutedText)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}
