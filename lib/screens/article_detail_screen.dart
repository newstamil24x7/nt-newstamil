import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_article.dart';
import '../services/bookmark_service.dart';
import '../theme/app_theme.dart';

class ArticleDetailScreen extends StatefulWidget {
  final NewsArticle article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  double _fontSize = 16.0;
  bool _isBookmarked = false;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final saved = await BookmarkService.isBookmarked(widget.article.id);
    if (mounted) setState(() => _isBookmarked = saved);
  }

  Future<void> _toggleBookmark() async {
    final saved = await BookmarkService.toggleBookmark(widget.article);
    if (mounted) {
      setState(() => _isBookmarked = saved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saved ? 'செய்தி சேமிக்கப்பட்டது' : 'சேமிப்பிலிருந்து நீக்கப்பட்டது'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareWhatsApp() async {
    final message = Uri.encodeComponent(
      '📰 *${widget.article.title}*\n\nமுழு விவரங்கள்: ${widget.article.link}\n\n_NewsTamil 24x7 App_',
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

  void _toggleAudioSpeech() {
    setState(() {
      _isPlayingAudio = !_isPlayingAudio;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPlayingAudio ? '🔊 ஆடியோ செய்தி ஒலிக்கிறது...' : '⏹️ ஆடியோ நிறுத்தப்பட்டது',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.categoryName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isBookmarked ? AppTheme.primaryRed : null,
            ),
            tooltip: 'சேமிக்க',
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'பகிர்வு',
            onPressed: () => Share.share('${widget.article.title}\n\n${widget.article.link}'),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.white,
          border: Border(top: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // WhatsApp Quick Share CTA
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.whatsAppGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                  label: const Text(
                    'வாட்ஸ்அப்பில் பகிருங்கள்',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: widget.article.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade200),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported_rounded, size: 48),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.article.categoryName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Headline
                  Text(
                    widget.article.title,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.45,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metadata: Author & Time
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.primaryNavy,
                        child: Text(
                          widget.article.authorName.isNotEmpty ? widget.article.authorName[0] : 'N',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.article.authorName,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time_rounded, size: 14, color: AppTheme.lightTextSecondary),
                      const SizedBox(width: 4),
                      Text(
                        widget.article.timeAgo,
                        style: TextStyle(fontSize: 12, color: AppTheme.lightTextSecondary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(),

                  // Utility Controls: Audio News Reader + Font Size Scaler
                  Row(
                    children: [
                      // Listen to News Button
                      ActionChip(
                        avatar: Icon(
                          _isPlayingAudio ? Icons.pause_circle_filled_rounded : Icons.volume_up_rounded,
                          color: AppTheme.primaryRed,
                          size: 18,
                        ),
                        label: Text(
                          _isPlayingAudio ? 'நிறுத்துக' : 'செய்தியை கேளுங்கள்',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: isDark ? const Color(0xFF26191B) : const Color(0xFFFFF1F2),
                        side: BorderSide.none,
                        onPressed: _toggleAudioSpeech,
                      ),
                      const Spacer(),

                      // Font Resizer
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkCard : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.text_decrease_rounded, size: 18),
                              tooltip: 'எழுத்து அளவை குறைக்க',
                              onPressed: () {
                                if (_fontSize > 13) {
                                  setState(() => _fontSize -= 1.5);
                                }
                              },
                            ),
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.text_increase_rounded, size: 18),
                              tooltip: 'எழுத்து அளவை கூட்ட',
                              onPressed: () {
                                if (_fontSize < 24) {
                                  setState(() => _fontSize += 1.5);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // 3. HTML Content Rendering
                  HtmlWidget(
                    widget.article.content.isNotEmpty ? widget.article.content : '<p>${widget.article.excerpt}</p>',
                    textStyle: TextStyle(
                      fontSize: _fontSize,
                      height: 1.65,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
