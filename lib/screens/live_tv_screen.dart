import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../models/news_article.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/news_list_item.dart';
import 'article_detail_screen.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  YoutubePlayerController? _controller;
  List<NewsArticle> _breakingItems = [];
  bool _isLoading = true;

  // NewsTamil 24x7 official live stream ID (or fallback stream)
  static const String liveVideoId = 'dQw4w9WgXcQ'; 

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: liveVideoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          mute: false,
          showFullscreenButton: true,
        ),
      );
    }
    _loadLiveFeed();
  }

  Future<void> _loadLiveFeed() async {
    final news = await ApiService.fetchPosts(perPage: 6);
    if (mounted) {
      setState(() {
        _breakingItems = news;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'NEWSTAMIL 24x7 நேரலை',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Live Video Player
          Container(
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _controller != null
                  ? YoutubePlayer(
                      controller: _controller!,
                      aspectRatio: 16 / 9,
                    )
                  : Container(
                      color: Colors.black87,
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.live_tv_rounded, color: AppTheme.primaryRed, size: 48),
                          SizedBox(height: 8),
                          Text(
                            'NEWSTAMIL 24x7 நேரலை ஒளிபரப்பு',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // 2. Channel Info Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? AppTheme.darkCard : Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'நியூஸ் தமிழ் 24x7 நேரலை ஒளிபரப்பு',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Text(
                        'அனைத்து முக்கியச் செய்திகளும் உடனுக்குடன்',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 3. Live Bulletins Below Player
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: AppTheme.primaryRed, size: 20),
                const SizedBox(width: 6),
                Text(
                  'தற்போதைய தலைப்புச் செய்திகள்',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _breakingItems.length,
                    itemBuilder: (context, index) {
                      final item = _breakingItems[index];
                      return NewsListItem(
                        article: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleDetailScreen(article: item),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
