import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_article.dart';
import '../services/bookmark_service.dart';
import '../theme/app_theme.dart';

class NewsListItem extends StatefulWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsListItem({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  State<NewsListItem> createState() => _NewsListItemState();
}

class _NewsListItemState extends State<NewsListItem> {
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

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        color: isDark ? AppTheme.darkCard : Colors.white,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with Left Title + Right Thumbnail
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Category + Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Text(
                        widget.article.categoryName.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.primaryRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Headline
                      Text(
                        widget.article.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Right: Thumbnail Image (rounded corners)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 104,
                    height: 74,
                    child: CachedNetworkImage(
                      imageUrl: widget.article.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported_outlined, size: 24, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom Action Row (Timestamp, WhatsApp, Share, Bookmark)
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 13, color: AppTheme.lightTextSecondary),
                const SizedBox(width: 4),
                Text(
                  widget.article.timeAgo,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),

                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  color: AppTheme.whatsAppGreen,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'வாட்ஸ்அப் பகிர்வு',
                  onPressed: _shareToWhatsApp,
                ),

                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  iconSize: 19,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'பகிர்வு',
                  onPressed: () {
                    Share.share('${widget.article.title}\n\n${widget.article.link}');
                  },
                ),

                IconButton(
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: _isBookmarked ? AppTheme.primaryRed : (isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
                  ),
                  iconSize: 21,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  tooltip: 'சேமிக்க',
                  onPressed: _toggleBookmark,
                ),
              ],
            ),
            const Divider(height: 1, thickness: 0.8),
          ],
        ),
      ),
    );
  }
}
