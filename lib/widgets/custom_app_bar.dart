import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const CustomAppBar({
    super.key,
    required this.onSearchTap,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.scaffoldKey,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0.8,
      backgroundColor: isDark ? AppTheme.darkCard : Colors.white,
      leading: IconButton(
        icon: Icon(
          Icons.menu_rounded,
          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
          size: 26,
        ),
        tooltip: 'மெனு',
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
      centerTitle: true,
      // Official Brand Logo (From NewsTamil.in)
      title: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: isDark
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(6),
              )
            : null,
        child: Image.asset(
          'assets/images/official_logo.png',
          height: 34,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to secondary asset or styled text badge
            return Image.asset(
              'assets/images/app_logo_top.webp',
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEWS',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'TAMIL',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryRed, width: 1.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      '24x7',
                      style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.w800, fontSize: 10),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white : AppTheme.lightTextPrimary,
            size: 24,
          ),
          tooltip: 'தேடுக',
          onPressed: onSearchTap,
        ),
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
            color: isDark ? Colors.amber : AppTheme.lightTextPrimary,
            size: 22,
          ),
          tooltip: 'தீம் மாற்று',
          onPressed: onThemeToggle,
        ),
      ],
    );
  }
}
