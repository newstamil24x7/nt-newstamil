import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class ApiService {
  static const String baseUrl = 'https://newstamil.in/wp-json/wp/v2';

  // Fetch posts with optional category, search keyword, and pagination
  static Future<List<NewsArticle>> fetchPosts({
    int page = 1,
    int perPage = 10,
    int? categoryId,
    String? search,
  }) async {
    try {
      final queryParameters = <String, String>{
        '_embed': '1',
        'per_page': perPage.toString(),
        'page': page.toString(),
      };

      if (categoryId != null && categoryId > 0) {
        queryParameters['categories'] = categoryId.toString();
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }

      final uri = Uri.parse('$baseUrl/posts').replace(queryParameters: queryParameters);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'NewsTamilMobileApp/1.0',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load news posts: ${response.statusCode}');
      }
    } catch (e) {
      // Return sample fallback data in case network is unreachable during development
      return _getFallbackArticles();
    }
  }

  // Fetch top 5 recent posts specifically for breaking news marquee
  static Future<List<NewsArticle>> fetchBreakingNews() async {
    try {
      final uri = Uri.parse('$baseUrl/posts?_embed=1&per_page=5');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => NewsArticle.fromJson(json)).toList();
      }
    } catch (_) {}
    return _getFallbackArticles().take(3).toList();
  }

  // Local fallback mock articles if live server is temporarily unreachable
  static List<NewsArticle> _getFallbackArticles() {
    return [
      NewsArticle(
        id: 101,
        title: 'சென்னையில் மெட்ரோ ரயில் 2-ம் கட்ட பணிகள் தீவிரம்: முக்கிய வழித்தடங்கள் விரைவில் திறப்பு!',
        content: '<p>சென்னையில் பொது போக்குவரத்தை மேம்படுத்தும் நோக்கில் இரண்டாம் கட்ட மெட்ரோ ரயில் திட்ட பணிகள் தீவிரமாக நடைபெற்று வருகின்றன.</p>',
        excerpt: 'சென்னையில் இரண்டாம் கட்ட மெட்ரோ ரயில் திட்ட பணிகள் முழுவீச்சில் நடைபெற்று வருகின்றன...',
        date: DateTime.now().subtract(const Duration(minutes: 25)).toIso8601String(),
        link: 'https://newstamil.in/',
        imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800&auto=format&fit=crop',
        categoryName: 'தமிழ்நாடு',
        authorName: 'NewsTamil நிருபர்',
      ),
      NewsArticle(
        id: 102,
        title: 'கூலி படத்தின் புதிய அதிரடி போஸ்டர் வெளியீடு: ரஜினி ரசிகர்களுக்கு மிகப்பெரிய கொண்டாட்டம்!',
        content: '<p>லோகேஷ் கனகராஜ் இயக்கத்தில் சூப்பர் ஸ்டார் ரஜினிகாந்த் நடிக்கும் கூலி திரைப்படத்தின் புதிய அப்டேட் இன்று வெளியாகியுள்ளது.</p>',
        excerpt: 'லோகேஷ் கனகராஜ் இயக்கத்தில் உருவாகும் கூலி படத்தின் எதிர்பார்ப்பு எகிறியுள்ளது...',
        date: DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        link: 'https://newstamil.in/',
        imageUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&auto=format&fit=crop',
        categoryName: 'சினிமா',
        authorName: 'சினிமா டெஸ்க்',
      ),
      NewsArticle(
        id: 103,
        title: 'இந்தியா-ஆஸ்திரேலியா டெஸ்ட் தொடர்: இந்திய அணியின் ஆடும் லெவன் அறிவிப்பு!',
        content: '<p>பார்டர்-கவாஸ்கர் கோப்பைக்கான டெஸ்ட் தொடரின் முதல் போட்டிக்கான இந்திய அணி தீவிர பயிற்சியில் ஈடுபட்டுள்ளது.</p>',
        excerpt: 'ஆஸ்திரேலியாவுக்கு எதிரான முதல் டெஸ்ட் போட்டிக்கான இந்திய அணியின் உத்தேச பட்டியல் வெளியீடு...',
        date: DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        link: 'https://newstamil.in/',
        imageUrl: 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=800&auto=format&fit=crop',
        categoryName: 'விளையாட்டு',
        authorName: 'ஸ்போர்ட்ஸ் டெஸ்க்',
      ),
    ];
  }
}
