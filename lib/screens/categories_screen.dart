import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

const _icons = ['🍕','🚗','🛒','💊','📺','🎮','🏠','✈️','🛍️','💰','💻','↔️','☕','🎵','📚','💅','🏋️','🎂','🏥','🐾','🎓','🔌','🛠️','📱','🎁','🍺','🌿','🎪','🚿','💡'];
const _colors = [0xFFE8230A, 0xFF1B3FFF, 0xFFFFE600, 0xFFFF3CAC, 0xFF00C46A, 0xFF9B59B6, 0xFF2C3E50, 0xFF3498DB, 0xFFE67E22, 0xFF1ABC9C, 0xFF34495E, 0xFFF39C12];

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).where((c) => c.parentCategoryId == null).toList();
    final all = ref.watch(categoriesProvider);

    return Column(
      children: [
        ScreenHeader(
          title: 'CATEGORIES',
          subtitle: '${all.length} total',
          trailing: Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 8),
            child: GestureDetector(
              onTap: () => _openDialog(context, ref, null, null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  border: Border.all(color: AppColors.black, width: 2),
                  boxShadow: const [BoxShadow(color: AppColors.black, offset: Offset(3, 3), blurRadius: 0)],
                ),
                child: const Text('+ NEW', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2, color: Colors.white)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: categories.isEmpty
              ? Center(child: Text('NO CATEGORIES\nTAP + NEW', textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 22, color: AppColors.mutedText, letterSpacing: 2, height: 1.4)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final cat = categories[i];
                    final subs = all.where((c) => c.parentCategoryId == cat.id).toList();
                    return _CatTile(
                      cat: cat,
                      subs: subs,
                      onEdit: () => _openDialog(context, ref, cat, null),
                      onDelete: () => _delete(ref, cat, all),
                      onAddSub: () => _openDialog(context, ref, null, cat.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _delete(WidgetRef ref, Category cat, List<Category> all) {
    // also delete subcategories
    final subs = all.where((c) => c.parentCategoryId == cat.id).toList();
    for (final s in subs) ref.read(categoryBoxProvider).delete(s.key);
    ref.read(categoryBoxProvider).delete(cat.key);
  }

  void _openDialog(BuildContext context, WidgetRef ref, Category? existing, String? parentId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _CategoryDialog(existing: existing, parentId: parentId),
    );
  }
}

class _CategoryDialog extends ConsumerStatefulWidget {
  final Category? existing;
  final String? parentId;
  const _CategoryDialog({this.existing, this.parentId});
  @override
  ConsumerState<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends ConsumerState<_CategoryDialog> {
  late final TextEditingController _nameCtrl;
  late String _icon;
  late int _color;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _icon = widget.existing?.icon ?? _icons.first;
    _color = widget.existing?.colorValue ?? _colors.first;
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) return;
    final user = ref.read(currentUserProvider)!;
    if (widget.existing != null) {
      widget.existing!.name = _nameCtrl.text.trim();
      widget.existing!.icon = _icon;
      widget.existing!.colorValue = _color;
      widget.existing!.save();
    } else {
      ref.read(categoryBoxProvider).add(Category(
        userId: user.id,
        name: _nameCtrl.text.trim(),
        icon: _icon,
        colorValue: _color,
        parentCategoryId: widget.parentId,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.existing != null ? 'EDIT CATEGORY' : (widget.parentId != null ? 'ADD SUBCATEGORY' : 'NEW CATEGORY'),
                style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 28, letterSpacing: 2)),
            const SizedBox(height: 14),

            // Name
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Category name',
                hintStyle: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, color: AppColors.mutedText),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.black, width: 2)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: AppColors.blue, width: 2)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),

            // Icon picker
            const Text('ICON', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 12, letterSpacing: 2, color: AppColors.mutedText)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _icons.map((ic) => GestureDetector(
                onTap: () => setState(() => _icon = ic),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _icon == ic ? AppColors.black : Colors.white,
                    border: Border.all(color: AppColors.black, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(ic, style: const TextStyle(fontSize: 18)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 12),

            // Color picker
            const Text('COLOR', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 12, letterSpacing: 2, color: AppColors.mutedText)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: _colors.map((c) => GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: Color(c),
                    border: Border.all(color: _color == c ? AppColors.black : Colors.transparent, width: 3),
                    boxShadow: _color == c ? const [BoxShadow(color: AppColors.black, offset: Offset(2, 2), blurRadius: 0)] : null,
                  ),
                  child: _color == c ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),

            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.black, width: 2)),
                    alignment: Alignment.center,
                    child: const Text('CANCEL', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.blue,
                      border: Border.fromBorderSide(BorderSide(color: AppColors.black, width: 2)),
                      boxShadow: [BoxShadow(color: AppColors.black, offset: Offset(3, 3), blurRadius: 0)],
                    ),
                    alignment: Alignment.center,
                    child: const Text('SAVE ★', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 16, letterSpacing: 2, color: Colors.white)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _CatTile extends StatelessWidget {
  final Category cat;
  final List<Category> subs;
  final VoidCallback onEdit, onDelete, onAddSub;
  const _CatTile({required this.cat, required this.subs, required this.onEdit, required this.onDelete, required this.onAddSub});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.fromBorderSide(BorderSide(color: AppColors.black, width: 2)),
        boxShadow: [BoxShadow(color: AppColors.black, offset: Offset(3, 3), blurRadius: 0)],
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: Color(cat.colorValue), border: Border.all(color: AppColors.black, width: 2)),
              alignment: Alignment.center,
              child: Text(cat.icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cat.name.toUpperCase(), style: const TextStyle(fontFamily: 'BebasNeue', fontSize: 18, letterSpacing: 1)),
                if (subs.isNotEmpty)
                  Text('${subs.length} subcategories', style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: AppColors.mutedText)),
              ],
            )),
            // action buttons
            GestureDetector(onTap: onAddSub, child: _ActionBtn(Icons.add, AppColors.blue)),
            const SizedBox(width: 6),
            GestureDetector(onTap: onEdit, child: _ActionBtn(Icons.edit_outlined, AppColors.black)),
            const SizedBox(width: 6),
            GestureDetector(onTap: onDelete, child: _ActionBtn(Icons.delete_outline, AppColors.red, light: true)),
          ]),
        ),
        if (subs.isNotEmpty) ...[
          Container(height: 1, color: const Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Wrap(spacing: 6, runSpacing: 6, children: subs.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(s.colorValue).withOpacity(0.12),
                border: Border.all(color: Color(s.colorValue), width: 1.5),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(s.icon, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(s.name, style: const TextStyle(fontFamily: 'SpaceMono', fontSize: 10, fontWeight: FontWeight.bold)),
              ]),
            )).toList()),
          ),
        ],
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool light;
  const _ActionBtn(this.icon, this.color, {this.light = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: light ? color : Colors.transparent,
      border: Border.all(color: color, width: 1.5),
    ),
    child: Icon(icon, size: 16, color: light ? Colors.white : color),
  );
}
