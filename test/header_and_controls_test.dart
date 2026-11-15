import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_theme.dart';
import 'package:homeplus/data/repositories/auth_repository.dart';
import 'package:homeplus/data/repositories/cart_repository.dart';
import 'package:homeplus/data/repositories/orders_repository.dart';
import 'package:homeplus/data/repositories/products_repository.dart';
import 'package:homeplus/data/repositories/support_repository.dart';
import 'package:homeplus/data/repositories/wishlist_repository.dart';
import 'package:homeplus/ui/core_widgets/app_logo.dart';
import 'package:homeplus/ui/core_widgets/language_toggle_pill.dart';
import 'package:homeplus/ui/core_widgets/telegram_theme_switcher.dart';
import 'package:homeplus/ui/features/auth/sign_in_screen.dart';
import 'package:homeplus/ui/features/home/home_screen.dart';
import 'package:homeplus/ui/features/onboarding/onboarding_screen.dart';
import 'package:homeplus/ui/features/profile/profile_screen.dart';
import 'package:homeplus/ui/view_models/app_theme_view_model.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/ui/view_models/orders_view_model.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import 'package:homeplus/ui/view_models/support_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';

Widget _buildTestHarness({
  required Widget child,
  AppThemeViewModel? themeVm,
}) {
  final vm = themeVm ?? AppThemeViewModel();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AppThemeViewModel>.value(value: vm),
      ChangeNotifierProvider(
        create: (_) => AuthViewModel(authRepository: AuthRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => ProductsViewModel(productsRepository: ProductsRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => CartViewModel(cartRepository: CartRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => WishlistViewModel(wishlistRepository: WishlistRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => OrdersViewModel(ordersRepository: OrdersRepository()),
      ),
      ChangeNotifierProvider(
        create: (_) => SupportViewModel(supportRepository: SupportRepository()),
      ),
    ],
    child: Consumer<AppThemeViewModel>(
      builder: (context, theme, _) {
        final isArabic = theme.isRTL;
        return MaterialApp(
          theme: AppTheme.getLightTheme(isArabic),
          darkTheme: AppTheme.getDarkTheme(isArabic),
          themeMode: theme.themeMode,
          locale: theme.locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, inner) => TelegramThemeOverlay(
            child: inner ?? const SizedBox.shrink(),
          ),
          home: child,
        );
      },
    ),
  );
}

void main() {
  testWidgets(
    'HomeScreen header places logo on left in EN and right in AR, shows Cart/Favorites/Notifications, and hides theme/language toggles',
    (WidgetTester tester) async {
      final themeVm = AppThemeViewModel();
      int? navigatedTab;

      await tester.pumpWidget(
        _buildTestHarness(
          themeVm: themeVm,
          child: HomeScreen(onNavigateTab: (idx) => navigatedTab = idx),
        ),
      );
      await tester.pumpAndSettle();

      // Theme & language toggles must NOT appear on HomeScreen
      expect(find.byType(TelegramThemeToggleButton), findsNothing);
      expect(find.byType(LanguageTogglePill), findsNothing);

      // AppBar should show Logo + Cart + Favorites + Notifications
      final appBarFinder = find.byType(AppBar);
      final logoFinder = find.descendant(of: appBarFinder, matching: find.byType(AppLogo));
      final cartIconFinder = find.descendant(
        of: appBarFinder,
        matching: find.byIcon(Icons.shopping_cart_outlined),
      );
      final favIconFinder = find.descendant(
        of: appBarFinder,
        matching: find.byIcon(Icons.favorite_border),
      );
      final notifIconFinder = find.descendant(
        of: appBarFinder,
        matching: find.byIcon(Icons.notifications_outlined),
      );

      expect(logoFinder, findsOneWidget);
      expect(cartIconFinder, findsOneWidget);
      expect(favIconFinder, findsOneWidget);
      expect(notifIconFinder, findsOneWidget);

      // English (LTR): logo is on the left, actions are on the right
      final enLogoRect = tester.getRect(logoFinder);
      final enCartRect = tester.getRect(cartIconFinder);
      final enNotifRect = tester.getRect(notifIconFinder);
      expect(enLogoRect.left, lessThan(40));
      expect(enCartRect.left, greaterThan(enLogoRect.right));
      expect(enNotifRect.left, greaterThan(enCartRect.left));

      // Tapping Cart and Favorites triggers navigation to tabs 2 and 3
      await tester.tap(cartIconFinder);
      expect(navigatedTab, 2);
      await tester.tap(favIconFinder);
      expect(navigatedTab, 3);

      // Switch to Arabic (RTL): logo moves to the right, actions move to the left
      themeVm.setLocale(const Locale('ar'));
      await tester.pumpAndSettle();

      final screenWidth = tester.getSize(find.byType(Scaffold).first).width;
      final arLogoRect = tester.getRect(logoFinder);
      final arCartRect = tester.getRect(cartIconFinder);
      final arNotifRect = tester.getRect(notifIconFinder);
      expect(arLogoRect.right, greaterThan(screenWidth - 40));
      expect(arCartRect.right, lessThan(arLogoRect.left));
      expect(arNotifRect.right, lessThan(arCartRect.right));
    },
  );

  testWidgets(
    'ProfileScreen, OnboardingScreen, and SignInScreen expose both theme and language toggles',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestHarness(child: const ProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TelegramThemeToggleButton), findsOneWidget);
      expect(find.byType(LanguageTogglePill), findsOneWidget);

      await tester.pumpWidget(_buildTestHarness(child: const OnboardingScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TelegramThemeToggleButton), findsOneWidget);
      expect(find.byType(LanguageTogglePill), findsOneWidget);

      await tester.pumpWidget(_buildTestHarness(child: const SignInScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TelegramThemeToggleButton), findsOneWidget);
      expect(find.byType(LanguageTogglePill), findsOneWidget);
    },
  );
}
