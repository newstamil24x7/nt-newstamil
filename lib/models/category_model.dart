import 'package:flutter/material.dart';

class CategoryModel {
  final int? id;
  final String slug;
  final String tamilName;
  final IconData? icon;

  const CategoryModel({
    this.id,
    required this.slug,
    required this.tamilName,
    this.icon,
  });

  // Updated to match the live categories on newstamil.in
  static const List<CategoryModel> defaultCategories = [
    CategoryModel(id: null, slug: 'all', tamilName: 'முகப்பு', icon: Icons.home_rounded),
    CategoryModel(id: 16, slug: 'news', tamilName: 'செய்திகள்', icon: Icons.newspaper_rounded),
    CategoryModel(id: 18, slug: 'entertainment', tamilName: 'சினிமா', icon: Icons.movie_filter_rounded),
    CategoryModel(id: 7, slug: 'videos', tamilName: 'வீடியோக்கள்', icon: Icons.play_circle_fill_rounded),
    CategoryModel(id: 1830, slug: 'review', tamilName: 'திரை விமர்சனம்', icon: Icons.rate_review_rounded),
    CategoryModel(id: 10746, slug: 'gold', tamilName: 'தங்கம் விலை', icon: Icons.monetization_on_rounded),
    CategoryModel(id: 8542, slug: 'jobs', tamilName: 'வேலைவாய்ப்பு', icon: Icons.work_outline_rounded),
    CategoryModel(id: 11148, slug: 'sports-news', tamilName: 'விளையாட்டு', icon: Icons.sports_cricket_rounded),
    CategoryModel(id: 63, slug: 'photos', tamilName: 'புகைப்படங்கள்', icon: Icons.photo_library_rounded),
    CategoryModel(id: 11, slug: 'recipes', tamilName: 'சமையல்', icon: Icons.restaurant_menu_rounded),
  ];
}
