import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_article.dart';

class BookmarkService {
  static const String _key = 'saved_bookmarks_v1';
  static final ValueNotifier<int> bookmarkCountNotifier = ValueNotifier<int>(0);

  // Retrieve all saved articles
  static Future<List<NewsArticle>> getBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_key) ?? [];
      final articles = list.map((item) => NewsArticle.fromJson(jsonDecode(item))).toList();
      bookmarkCountNotifier.value = articles.length;
      return articles;
    } catch (_) {
      return [];
    }
  }

  // Check if article is already saved
  static Future<bool> isBookmarked(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_key) ?? [];
      return list.any((item) {
        final data = jsonDecode(item);
        return data['id'] == id;
      });
    } catch (_) {
      return false;
    }
  }

  // Toggle bookmark state (returns true if saved, false if removed)
  static Future<bool> toggleBookmark(NewsArticle article) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> list = prefs.getStringList(_key) ?? [];
      
      final index = list.indexWhere((item) {
        final data = jsonDecode(item);
        return data['id'] == article.id;
      });

      if (index >= 0) {
        // Already bookmarked -> Remove
        list.removeAt(index);
        await prefs.setStringList(_key, list);
        bookmarkCountNotifier.value = list.length;
        return false;
      } else {
        // Not bookmarked -> Save
        list.insert(0, jsonEncode(article.toJson()));
        await prefs.setStringList(_key, list);
        bookmarkCountNotifier.value = list.length;
        return true;
      }
    } catch (_) {
      return false;
    }
  }
}
