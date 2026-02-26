import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/listings/browse_screen.dart';
import 'screens/listings/listing_detail_screen.dart';
import 'screens/listings/create_listing_screen.dart';
import 'screens/community/community_screen.dart';
import 'screens/community/post_detail_screen.dart';
import 'screens/community/create_post_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/profile_edit_screen.dart';
import 'screens/profile/lifestyle_screen.dart';
import 'screens/profile/my_listings_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }
  runApp(const ProviderScope(child: RoomieVerseApp()));
}

// Navigation keys for bottom nav shell
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/browse',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: BrowseScreen()),
        ),
        GoRoute(
          path: '/community',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CommunityScreen()),
        ),
        GoRoute(
          path: '/favorites',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: FavoritesScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
    // Full-screen routes (outside bottom nav shell)
    GoRoute(
      path: '/listing/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          ListingDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/community/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          PostDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/auth',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/create-listing',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return CreateListingScreen(initialCategory: category);
      },
    ),
    GoRoute(
      path: '/community/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return CreatePostScreen(initialCategory: category);
      },
    ),
    GoRoute(
      path: '/profile/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: '/profile/lifestyle',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LifestyleScreen(),
    ),
    GoRoute(
      path: '/profile/listings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const MyListingsScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class RoomieVerseApp extends StatelessWidget {
  const RoomieVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'roomieVerse',
      theme: AppTheme.theme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/browse')) return 1;
    if (location.startsWith('/community')) return 2;
    if (location.startsWith('/favorites')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: LucideIcons.home,
                  activeIcon: LucideIcons.home,
                  label: 'Trang chủ',
                  selected: index == 0,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: LucideIcons.search,
                  activeIcon: LucideIcons.search,
                  label: 'Tìm phòng',
                  selected: index == 1,
                  onTap: () => context.go('/browse'),
                ),
                _NavItem(
                  icon: LucideIcons.users,
                  activeIcon: LucideIcons.users,
                  label: 'Cộng đồng',
                  selected: index == 2,
                  onTap: () => context.go('/community'),
                ),
                _NavItem(
                  icon: LucideIcons.heart,
                  activeIcon: LucideIcons.heart,
                  label: 'Yêu thích',
                  selected: index == 3,
                  onTap: () => context.go('/favorites'),
                ),
                _NavItem(
                  icon: LucideIcons.user,
                  activeIcon: LucideIcons.user,
                  label: 'Hồ sơ',
                  selected: index == 4,
                  onTap: () => context.go('/profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.blueDark.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 22,
              color: selected ? AppColors.blueDark : AppColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.blueDark : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
