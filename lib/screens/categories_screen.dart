import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  static const _icons = ['🍕','🚗','🛒','💊','📺','🎮','🏠','✈️','🛍️','💰','💻','↔️','🎵','📚','🏋️','🐾','🎨','⚽','🍺','☕','🔧','💇'];
  static const _colors = [0xFFE8230A, 0xFF1B3FFF, 0xFFFFE600, 0xFF00C46A, 0xFFFF3CAC, 0xFF9B59B6, 0xFF2C3E50, 0xFF3498DB, 0xFFE67E22, 0xFF1ABC9C, 0xFFE74C3C, 0xFF95A5A6];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenHeader(
              title: 'CATEGORIES',
              subtitle: 'Organize your spending',
              trailing: Padding(
                padding: const EdgeInsets.only(right: 20, bottom: 8),
                child: GestureDetector(
                  onTap: () => _showAddDialog(context, ref),
                  child: const StickerTag('+ NEW', bg: AppColors.blue, textColor: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (_, i) {
                  final cat = categories[i];
                  return GestureDetector(
                    onLongPress: () => _showDeleteDialog(context, ref, cat),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(cat.colorValue).withOpacity(0.12),
                        border: Border.all(color: Color(cat.colorValue), width: 2.5),
                        boxShadow: [BoxShadow(color: Color(cat.colorValue), offset: const Offset(3, 3), blurRadius: 0)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cat.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Text(cat.name.toUpperCase(),
                              style: TextStyle(fontFamily: 'BebasNeue', fontSize: 13, letterSpacing: 1, color: AppColors.black),
                              textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    String selectedIcon = '🍕';
    int selectedColor = 0xFFE8230A;

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
              Text('NEW CATEGORY', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 32, letterSpacing: 2)),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                style: TextStyle(fontFamily: 'SpaceMono', fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Category name',
                  hintStyle: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, color: AppColors.mutedText),
                  enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.black, width: 2)),
                  focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.blue, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 14),
              Text('ICON', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 13, letterSpacing: 2, color: AppColors.mutedText)),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _icons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, i) {
                    final isSel = selectedIcon == _icons[i];
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = _icons[i]),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.black : Colors.white,
                          border: Border.all(color: AppColors.black, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(_icons[i], style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              Text('COLOR', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 13, letterSpacing: 2, color: AppColors.mutedText)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _colors.map((c) {
                  final isSel = selectedColor == c;
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = c),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Color(c),
                        border: Border.all(color: isSel ? AppColors.black : Colors.transparent, width: isSel ? 3 : 0),
                        boxShadow: isSel ? const [BoxShadow(color: AppColors.black, offset: Offset(2, 2), blurRadius: 0)] : [],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: BrutalButton(
                  label: 'CREATE CATEGORY',
                  bg: AppColors.blue,
                  onTap: () {
                    if (nameCtrl.text.isEmpty) return;
                    final user = ref.read(currentUserProvider)!;
                    final cat = Category(userId: user.id, name: nameCtrl.text, icon: selectedIcon, colorValue: selectedColor);
                    ref.read(categoryBoxProvider).add(cat);
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

  void _showDeleteDialog(BuildContext ctx, WidgetRef ref, Category cat) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(color: AppColors.black, width: 3),
        ),
        title: Text('DELETE ${cat.name.toUpperCase()}?', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 22, letterSpacing: 2)),
        content: Text('This will not delete existing transactions.', style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2, color: AppColors.black)),
          ),
          GestureDetector(
            onTap: () { cat.delete(); Navigator.pop(ctx); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.red,
              child: Text('DELETE', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
