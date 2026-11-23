import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/news_article.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/breaking_ticker.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hero_news_card.dart';
import '../widgets/news_list_item.dart';
import 'article_detail_screen.dart';
import 'bookmarks_screen.dart';
import 'live_tv_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  int _selectedBottomIndex = 0;
  int _selectedCategoryIndex = 0;

  List<NewsArticle> _articles = [];
  List<NewsArticle> _breakingNews = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        !_isLoading) {
      _loadMorePosts();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final category = CategoryModel.defaultCategories[_selectedCategoryIndex];

    final results = await Future.wait([
      ApiService.fetchPosts(page: 1, categoryId: category.id, search: _searchQuery),
      ApiService.fetchBreakingNews(),
    ]);

    if (mounted) {
      setState(() {
        _articles = results[0];
        _breakingNews = results[1];
        _currentPage = 1;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;
    final category = CategoryModel.defaultCategories[_selectedCategoryIndex];

    final newPosts = await ApiService.fetchPosts(
      page: nextPage,
      categoryId: category.id,
      search: _searchQuery,
    );

    if (mounted) {
      setState(() {
        _articles.addAll(newPosts);
        _currentPage = nextPage;
        _isLoadingMore = false;
      });
    }
  }

  void _onCategorySelected(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() {
      _selectedCategoryIndex = index;
    });
    _loadInitialData();
  }

  void _showSearchDialog() {
    final TextEditingController searchCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('செய்திகளைத் தேடுங்கள்', style: TextStyle(fontSize: 16)),
          content: TextField(
            controller: searchCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'எ.கா: சென்னை, தேர்தல், சினிமா...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ரத்து'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _searchQuery = searchCtrl.text.trim();
                });
                _loadInitialData();
              },
              child: const Text('தேடு'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        isDarkMode: widget.isDarkMode,
        onSearchTap: _showSearchDialog,
        onThemeToggle: widget.onThemeToggle,
      ),
      drawer: _buildDrawer(context, isDark),
      bottomNavigationBar: _buildBottomNav(isDark),
      body: _buildCurrentBody(),
    );
  }

  Widget _buildCurrentBody() {
    switch (_selectedBottomIndex) {
      case 2:
        return const LiveTvScreen();
      case 4:
        return const BookmarksScreen();
      default:
        return _buildHomeFeed();
    }
  }

  Widget _buildHomeFeed() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      color: AppTheme.primaryRed,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 1. Sticky Category Scroll Strip (matches News18 sample design)
          SliverToBoxAdapter(
            child: Container(
              height: 44,
              color: isDark ? AppTheme.darkCard : Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                itemCount: CategoryModel.defaultCategories.length,
                itemBuilder: (context, index) {
                  final cat = CategoryModel.defaultCategories[index];
                  final isSelected = _selectedCategoryIndex == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () => _onCategorySelected(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryRed
                              : (isDark ? Colors.grey.shade900 : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          cat.tamilName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey.shade300 : AppTheme.lightTextPrimary),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Breaking News Ticker
          if (_breakingNews.isNotEmpty)
            SliverToBoxAdapter(
              child: BreakingTicker(
                items: _breakingNews,
                onTap: (item) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: item)),
                  );
                },
              ),
            ),

          // 3. Search Query Filter Indicator (if active)
          if (_searchQuery != null && _searchQuery!.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: Colors.amber.shade100,
                child: Row(
                  children: [
                    Text('தேடல்: "$_searchQuery"', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() => _searchQuery = null);
                        _loadInitialData();
                      },
                      child: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Loading or Empty State
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryRed),
              ),
            )
          else if (_articles.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('செய்திகள் எதுவும் கிடைக்கவில்லை.'),
              ),
            )
          else
            // 5. Hero Card (First Article) & Subsequent List Items
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final article = _articles[index];
                  // First article renders as Lead Hero Card
                  if (index == 0) {
                    return HeroNewsCard(
                      article: article,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
                        );
                      },
                    );
                  }

                  // Subsequent articles render as standard 2nd-style list cards
                  return NewsListItem(
                    article: article,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
                      );
                    },
                  );
                },
                childCount: _articles.length,
              ),
            ),

          // 6. Pagination Loading Indicator
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryRed),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 6-Tab Bottom Navigation Bar matching the user's uploaded screenshot
  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder, width: 0.8)),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
        selectedItemColor: AppTheme.primaryRed,
        unselectedItemColor: isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary,
        selectedLabelStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'முகப்பு',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed_outlined),
            activeIcon: Icon(Icons.feed_rounded),
            label: 'எனக்காக',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv_outlined),
            activeIcon: Icon(Icons.live_tv_rounded),
            label: 'நேரலை',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline_rounded),
            activeIcon: Icon(Icons.play_circle_fill_rounded),
            label: 'வீடியோக்கள்',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline_rounded),
            activeIcon: Icon(Icons.bookmark_rounded),
            label: 'சேமித்தவை',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on_rounded),
            label: 'மாவட்டம்',
          ),
        ],
      ),
    );
  }

  // Slide-out Side Drawer with news portal branding and legal links
  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppTheme.primaryNavy),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'NEWSTAMIL',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('24x7', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'உண்மை உடனுக்குடன் • Tamil News 24x7',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ...CategoryModel.defaultCategories.map(
            (c) => ListTile(
              leading: Icon(c.icon ?? Icons.label_outline, color: AppTheme.primaryRed, size: 22),
              title: Text(c.tamilName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                final idx = CategoryModel.defaultCategories.indexOf(c);
                _onCategorySelected(idx);
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bookmark_rounded, color: Colors.amber),
            title: const Text('சேமிக்கப்பட்ட செய்திகள்'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('தனியுரிமை கொள்கை (Privacy Policy)'),
            onTap: () {
              Navigator.pop(context);
              // Open privacy policy URL
            },
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('பதிப்பு 1.0.0 (NewsTamil.in)', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
