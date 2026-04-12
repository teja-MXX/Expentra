import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
String formatINR(double v) => _inr.format(v);

// ─── TICKER TAPE ─────────────────────────────────────────────────────────────

class TickerTape extends StatefulWidget {
  final String text;
  const TickerTape({super.key, required this.text});

  @override
  State<TickerTape> createState() => _TickerTapeState();
}

class _TickerTapeState extends State<TickerTape> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
    _anim = Tween<double>(begin: 1.0, end: -1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      color: AppColors.black,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: AppColors.black),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          return FractionalTranslation(
            translation: Offset(_anim.value, 0),
            child: Text(
              widget.text,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: 13,
                color: AppColors.yellow,
                letterSpacing: 2,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── STICKER TAG ─────────────────────────────────────────────────────────────

class StickerTag extends StatelessWidget {
  final String text;
  final Color bg;
  final Color textColor;
  final double rotate;

  const StickerTag(this.text, {
    super.key,
    this.bg = AppColors.yellow,
    this.textColor = AppColors.black,
    this.rotate = -2,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotate * 3.14159 / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: AppColors.black, width: 2.5),
          boxShadow: const [BoxShadow(color: AppColors.black, offset: Offset(3, 3), blurRadius: 0)],
        ),
        child: Text(text, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 13, color: textColor, letterSpacing: 1)),
      ),
    );
  }
}

// ─── TAPE STRIP ──────────────────────────────────────────────────────────────

class TapeStrip extends StatelessWidget {
  final String text;
  const TapeStrip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      color: AppColors.yellow.withOpacity(0.75),
      alignment: Alignment.center,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, letterSpacing: 2.5, color: Colors.black54),
      ),
    );
  }
}

// ─── STAT CARD ───────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color accentColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.accentColor = AppColors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: accentColor, width: 3),
        boxShadow: [BoxShadow(color: accentColor, offset: const Offset(4, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: AppColors.mutedText, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 26, color: AppColors.black, height: 1)),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub!, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: AppColors.mutedText)),
          ]
        ],
      ),
    );
  }
}

// ─── BRUTAL BUTTON ───────────────────────────────────────────────────────────

class BrutalButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color bg;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;

  const BrutalButton({
    super.key,
    required this.label,
    required this.onTap,
    this.bg = AppColors.red,
    this.textColor = Colors.white,
    this.fontSize = 22,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: _pressed ? (Matrix4.identity()..translate(5.0, 5.0)) : Matrix4.identity(),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.bg,
          border: Border.all(color: AppColors.black, width: 3),
          boxShadow: _pressed ? [] : const [BoxShadow(color: AppColors.black, offset: Offset(5, 5), blurRadius: 0)],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: TextStyle(fontFamily: 'BebasNeue', fontSize: widget.fontSize, color: widget.textColor, letterSpacing: 3),
        ),
      ),
    );
  }
}

// ─── TRANSACTION LIST ITEM ────────────────────────────────────────────────────

class TransactionListItem extends StatelessWidget {
  final Transaction txn;
  final Category? category;
  final Account? account;
  final VoidCallback? onTap;

  const TransactionListItem({super.key, required this.txn, this.category, this.account, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpense = txn.type == TransactionType.expense;
    final isIncome = txn.type == TransactionType.income;
    final color = isIncome ? AppColors.green : isExpense ? AppColors.red : AppColors.blue;
    final sign = isIncome ? '+' : '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: brutalCardSmall(),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Color(category?.colorValue ?? 0xFF888888),
                border: Border.all(color: AppColors.black, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(category?.icon ?? '?', style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(txn.note?.isNotEmpty == true ? txn.note! : category?.name ?? 'Transaction',
                      style: TextStyle(fontFamily: 'SpaceMono', fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('${category?.name ?? ''} · ${account?.name ?? ''}',
                      style: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, color: AppColors.mutedText)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$sign${formatINR(txn.amount)}',
                    style: TextStyle(fontFamily: 'BebasNeue', fontSize: 20, color: color)),
                Text(DateFormat('d MMM').format(txn.date),
                    style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: AppColors.mutedText)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SCREEN HEADER ────────────────────────────────────────────────────────────

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const ScreenHeader({super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 56, color: AppColors.black, height: 1, letterSpacing: 1)),
                if (subtitle != null)
                  Text(subtitle!.toUpperCase(), style: TextStyle(fontFamily: 'SpaceMono', fontSize: 9, color: AppColors.mutedText, letterSpacing: 1.5)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─── SECTION HEAD ─────────────────────────────────────────────────────────────

class SectionHead extends StatelessWidget {
  final String title;
  const SectionHead(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontFamily: 'BebasNeue', fontSize: 22, letterSpacing: 2)),
          const SizedBox(width: 10),
          Expanded(child: Container(height: 2, color: AppColors.black)),
        ],
      ),
    );
  }
}

// ─── INSIGHT CARD ─────────────────────────────────────────────────────────────

class InsightCard extends StatelessWidget {
  final String headline;
  final String body;

  const InsightCard({super.key, required this.headline, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue,
        border: Border.all(color: AppColors.black, width: 3),
        boxShadow: const [BoxShadow(color: AppColors.black, offset: Offset(5, 5), blurRadius: 0)],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0, right: 0,
            child: Text('★ INSIGHT', style: TextStyle(fontFamily: 'BebasNeue', fontSize: 10, color: Colors.white24, letterSpacing: 2)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(headline, style: TextStyle(fontFamily: 'BebasNeue', fontSize: 24, color: AppColors.yellow, height: 1, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(body, style: TextStyle(fontFamily: 'SpaceMono', fontSize: 11, color: Colors.white, height: 1.6)),
            ],
          ),
        ],
      ),
    );
  }
}
