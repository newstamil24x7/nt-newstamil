import 'dart:async';
import 'package:flutter/material.dart';
import '../models/news_article.dart';
import '../theme/app_theme.dart';

class BreakingTicker extends StatefulWidget {
  final List<NewsArticle> items;
  final Function(NewsArticle) onTap;

  const BreakingTicker({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  State<BreakingTicker> createState() => _BreakingTickerState();
}

class _BreakingTickerState extends State<BreakingTicker> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.items.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.items.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final currentArticle = widget.items[_currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1417) : const Color(0xFFFFF1F2),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.red.shade900 : Colors.red.shade200,
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          // Flashing Breaking News Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: Colors.white, size: 14),
                SizedBox(width: 2),
                Text(
                  'பிரேக்கிங்',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Animated Scrolling Title
          Expanded(
            child: GestureDetector(
              onTap: () => widget.onTap(currentArticle),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Text(
                  currentArticle.title,
                  key: ValueKey<int>(currentArticle.id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.red.shade100 : const Color(0xFF991B1B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
