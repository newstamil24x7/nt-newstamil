class NewsArticle {
  final int id;
  final String title;
  final String content;
  final String excerpt;
  final String date;
  final String link;
  final String imageUrl;
  final String categoryName;
  final String authorName;

  NewsArticle({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.date,
    required this.link,
    required this.imageUrl,
    required this.categoryName,
    required this.authorName,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    // 1. Clean Title
    String rawTitle = json['title']?['rendered'] ?? 'செய்தி தலைப்பு இல்லை';
    String cleanTitle = _cleanHtml(rawTitle);

    // 2. Clean Content & Excerpt
    String rawContent = json['content']?['rendered'] ?? '';
    String rawExcerpt = json['excerpt']?['rendered'] ?? '';
    String cleanExcerpt = _stripHtml(rawExcerpt);

    // 3. Extract Image URL with fallbacks (supports both WP API and saved bookmarks)
    String img = (json['imageUrl'] ?? '').toString();
    if (img.isEmpty) {
      try {
        if (json.containsKey('_embedded') &&
            json['_embedded']?['wp:featuredmedia'] != null &&
            (json['_embedded']['wp:featuredmedia'] as List).isNotEmpty) {
          img = json['_embedded']['wp:featuredmedia'][0]['source_url'] ?? '';
        }
      } catch (_) {}
    }

    if (img.isEmpty && json['yoast_head_json'] != null) {
      try {
        final ogImg = json['yoast_head_json']?['og_image'];
        if (ogImg is List && ogImg.isNotEmpty) {
          img = ogImg[0]?['url'] ?? '';
        }
      } catch (_) {}
    }

    if (img.isEmpty) {
      // Look for first <img> in content
      final exp = RegExp(r'<img[^>]+src="([^">]+)"');
      final match = exp.firstMatch(rawContent);
      if (match != null && match.groupCount >= 1) {
        img = match.group(1) ?? '';
      }
    }

    // Default high-quality placeholder if no image found
    if (img.isEmpty) {
      img = 'https://images.unsplash.com/photo-1585829365295-ab7cd400c167?w=800&auto=format&fit=crop';
    }

    // 4. Extract Category Name (supports both WP API and saved bookmarks)
    String cat = (json['categoryName'] ?? '').toString();
    if (cat.isEmpty) {
      cat = 'செய்திகள்';
      try {
        if (json.containsKey('_embedded') &&
            json['_embedded']?['wp:term'] != null &&
            (json['_embedded']['wp:term'] as List).isNotEmpty) {
          final termList = json['_embedded']['wp:term'][0];
          if (termList is List && termList.isNotEmpty) {
            cat = termList[0]?['name'] ?? 'செய்திகள்';
          }
        }
      } catch (_) {}
    }

    // 5. Author Name (supports both WP API and saved bookmarks)
    String author = (json['authorName'] ?? '').toString();
    if (author.isEmpty) {
      author = 'NewsTamil';
      try {
        if (json.containsKey('_embedded') &&
            json['_embedded']?['author'] != null &&
            (json['_embedded']['author'] as List).isNotEmpty) {
          author = json['_embedded']['author'][0]?['name'] ?? 'NewsTamil';
        }
      } catch (_) {}
    }

    return NewsArticle(
      id: json['id'] ?? 0,
      title: cleanTitle,
      content: rawContent,
      excerpt: cleanExcerpt,
      date: json['date'] ?? '',
      link: json['link'] ?? 'https://newstamil.in',
      imageUrl: img,
      categoryName: cat,
      authorName: author,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': {'rendered': title},
      'content': {'rendered': content},
      'excerpt': {'rendered': excerpt},
      'date': date,
      'link': link,
      'imageUrl': imageUrl,
      'categoryName': categoryName,
      'authorName': authorName,
    };
  }

  // Extract YouTube ID if article contains embedded YouTube video, short, or live stream
  String? get youtubeVideoId {
    final exp = RegExp(
      r'(?:youtube(?:-nocookie)?\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?|live|shorts)\/|.*[?&]v=)|youtu\.be\/)([\w-]{11})',
      caseSensitive: false,
    );
    final match = exp.firstMatch(content) ?? exp.firstMatch(excerpt);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  bool get isVideo => youtubeVideoId != null || categoryName.toLowerCase().contains('video') || categoryName.contains('வீடியோ');

  static String _cleanHtml(String text) {
    return text
        .replaceAll('&#8216;', '‘')
        .replaceAll('&#8217;', '’')
        .replaceAll('&#8220;', '“')
        .replaceAll('&#8221;', '”')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#038;', '&')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8212;', '—')
        .replaceAll('&hellip;', '...')
        .replaceAll(RegExp(r'<[^>]*>'), '');
  }

  static String _stripHtml(String htmlString) {
    final clean = htmlString.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
    return clean.trim();
  }

  // User-friendly relative time string in Tamil
  String get timeAgo {
    if (date.isEmpty) return 'சமீபத்தியது';
    try {
      final parsedDate = DateTime.parse(date);
      final now = DateTime.now();
      final difference = now.difference(parsedDate);

      if (difference.inMinutes < 60) {
        final m = difference.inMinutes;
        return m <= 1 ? 'இப்போது' : '$m நிமிடங்களுக்கு முன்';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} மணி நேரத்திற்கு முன்';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} நாட்களுக்கு முன்';
      } else {
        return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      }
    } catch (_) {
      return 'சமீபத்தியது';
    }
  }
}
