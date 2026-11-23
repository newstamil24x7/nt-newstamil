import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_article.dart';
import '../services/bookmark_service.dart';
import '../theme/app_theme.dart';

class HeroNewsCard extends StatefulWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const HeroNewsCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  State<HeroNewsCard> createState() => _HeroNewsCardState();
}

class _HeroNewsCardState extends State<HeroNewsCard> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final saved = await BookmarkService.isBookmarked(widget.article.id);
    if (mounted) {
      setState(() => _isBookmarked = saved);
    }
  }

  Future<void> _toggleBookmark() async {
    final saved = await BookmarkService.toggleBookmark(widget.article);
    if (mounted) {
      setState(() => _isBookmarked = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved ? 'செய்தி சேமிக்கப்பட்டது' : 'சேமிப்பிலிருந்து நீக்கப்பட்டது',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Direct WhatsApp Share (High viral distribution)
  Future<void> _shareToWhatsApp() async {
    final message = Uri.encodeComponent(
      '📰 *${widget.article.title}*\n\nமுழு விவரங்களை வாசிக்க: ${widget.article.link}\n\n_NewsTamil 24x7 செயலியை பதிவிறக்கவும்_',
    );
    final url = Uri.parse('whatsapp://send?text=$message');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Share.share('${widget.article.title}\n\n${widget.article.link}');
      }
    } catch (_) {
      Share.share('${widget.article.title}\n\n${widget.article.link}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDark ? AppTheme.darkCard : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Category Tag & Title
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.article.categoryName.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bold Headline (matches sample design)
                  Text(
                    widget.article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.42,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Full-Width 16:9 Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: widget.article.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  child: const Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                ),
              ),
            ),

            // 3. Quick Action Row (Time, WhatsApp, Share, Bookmark)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  // Time ago
                  Icon(Icons.access_time_rounded, size: 14, color: AppTheme.lightTextSecondary),
                  const SizedBox(width: 4),
                  Text(
                    widget.article.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),

                  // WhatsApp Share Button
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    color: AppTheme.whatsAppGreen,
                    iconSize: 21,
                    tooltip: 'வாட்ஸ்அப் பகிர்வு',
                    onPressed: _shareToWhatsApp,
                  ),

                  // Native Share
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    iconSize: 20,
                    tooltip: 'பகிர்வு',
                    onPressed: () {
                      Share.share('${widget.article.title}\n\n${widget.article.link}');
                    },
                  ),

                  // Bookmark Icon
                  IconButton(
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: _isBookmarked ? AppTheme.primaryRed : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                    ),
                    iconSize: 22,
                    tooltip: 'சேமிக்க',
                    onPressed: _toggleBookmark,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
          ],
        ),
      ),
    );
  }
}
