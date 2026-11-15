import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/add_to_cart_animation.dart';
import 'package:homeplus/ui/core_widgets/app_logo.dart';
import 'package:homeplus/ui/core_widgets/bottom_nav_bar.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';
import 'home/home_screen.dart';
import 'categories/main_categories_screen.dart';
import 'cart/cart_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();
    final wishlistVm = context.watch<WishlistViewModel>();

    final screens = [
      HomeScreen(onNavigateTab: _onTabSelected),
      const MainCategoriesScreen(),
      CartScreen(onNavigateTab: _onTabSelected),
      WishlistScreen(onNavigateTab: _onTabSelected),
      ProfileScreen(onNavigateTab: _onTabSelected),
    ];

    return AddToCartOverlayScope(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useRail = ResponsiveLayout.useNavigationRail(constraints.maxWidth);
          final isExpanded = ResponsiveLayout.isExpanded(constraints.maxWidth);

          return Scaffold(
            body: useRail
                ? Row(
                    children: [
                      _AdaptiveNavigationRail(
                        currentIndex: _currentIndex,
                        extended: isExpanded,
                        cartItemCount: cartVm.itemCount,
                        wishlistCount: wishlistVm.itemCount,
                        onDestinationSelected: _onTabSelected,
                      ),
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: context.borderColor,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: screens,
                        ),
                      ),
                    ],
                  )
                : IndexedStack(
                    index: _currentIndex,
                    children: screens,
                  ),
            bottomNavigationBar: useRail
                ? null
                : HomePlusBottomNavBar(
                    currentIndex: _currentIndex,
                    onTabSelected: _onTabSelected,
                    cartItemCount: cartVm.itemCount,
                    wishlistCount: wishlistVm.itemCount,
                  ),
          );
        },
      ),
    );
  }
}

class _AdaptiveNavigationRail extends StatelessWidget {
  final int currentIndex;
  final bool extended;
  final int cartItemCount;
  final int wishlistCount;
  final ValueChanged<int> onDestinationSelected;

  const _AdaptiveNavigationRail({
    required this.currentIndex,
    required this.extended,
    required this.cartItemCount,
    required this.wishlistCount,
    required this.onDestinationSelected,
  });

  Widget _badgedIcon(IconData icon, int count, {Key? iconKey}) {
    if (count <= 0) {
      return Icon(icon, key: iconKey);
    }
    return Badge.count(
      count: count > 99 ? 99 : count,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      child: Icon(icon, key: iconKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final accent = isDark ? AppColors.primaryLight : AppColors.primary;
    final cartScope = AddToCartOverlayScope.maybeOf(context);

    return NavigationRail(
      extended: extended,
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      indicatorColor: context.mintBg,
      selectedIconTheme: IconThemeData(color: accent),
      unselectedIconTheme: IconThemeData(color: context.textSecondaryColor),
      selectedLabelTextStyle: TextStyle(
        color: accent,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: context.textSecondaryColor,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: extended
            ? const AppLogo(iconSize: 32, showTagline: false, isHorizontal: true)
            : const HomePlusIcon(size: 36),
      ),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: Text(context.tr('nav_home')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.grid_view_outlined),
          selectedIcon: const Icon(Icons.grid_view),
          label: Text(context.tr('nav_categories')),
        ),
        NavigationRailDestination(
          icon: _badgedIcon(
            Icons.shopping_cart_outlined,
            cartItemCount,
            iconKey: currentIndex != 2 ? cartScope?.cartTargetKey : null,
          ),
          selectedIcon: _badgedIcon(
            Icons.shopping_cart,
            cartItemCount,
            iconKey: currentIndex == 2 ? cartScope?.cartTargetKey : null,
          ),
          label: Text(context.tr('nav_cart')),
        ),
        NavigationRailDestination(
          icon: _badgedIcon(Icons.favorite_border, wishlistCount),
          selectedIcon: _badgedIcon(Icons.favorite, wishlistCount),
          label: Text(context.tr('nav_wishlist')),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: Text(context.tr('nav_profile')),
        ),
      ],
    );
  }
}
