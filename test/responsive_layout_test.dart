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
import 'package:homeplus/ui/core_widgets/bottom_nav_bar.dart';
import 'package:homeplus/ui/core_widgets/telegram_theme_switcher.dart';
import 'package:homeplus/ui/features/cart/cart_screen.dart';
import 'package:homeplus/ui/features/categories/main_categories_screen.dart';
import 'package:homeplus/ui/features/home/home_screen.dart';
import 'package:homeplus/ui/features/main_navigation_screen.dart';
import 'package:homeplus/ui/features/orders/my_orders_screen.dart';
import 'package:homeplus/ui/features/products/product_details_screen.dart';
import 'package:homeplus/ui/features/profile/saved_addresses_screen.dart';
import 'package:homeplus/ui/features/support/customer_service_screen.dart';
import 'package:homeplus/ui/features/support/faq_screen.dart';
import 'package:homeplus/ui/features/support/live_chat_screen.dart';
import 'package:homeplus/ui/view_models/app_theme_view_model.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/ui/view_models/orders_view_model.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import 'package:homeplus/ui/view_models/support_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';

Widget _wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppThemeViewModel()),
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
    child: MaterialApp(
      theme: AppTheme.getLightTheme(false),
      darkTheme: AppTheme.getDarkTheme(false),
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
    ),
  );
}

void main() {
  testWidgets(
    'MainNavigationScreen adapts between BottomNavBar on compact phones and NavigationRail on tablets/desktops',
    (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      tester.view.devicePixelRatio = 1.0;

      // 1. Small phone (320x568): BottomNavBar, no overflow
      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpWidget(_wrapWithProviders(const MainNavigationScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(HomePlusBottomNavBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(tester.takeException(), isNull);

      // 2. Tablet (800x1024): Compact NavigationRail
      tester.view.physicalSize = const Size(800, 1024);
      await tester.pumpWidget(_wrapWithProviders(const MainNavigationScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(HomePlusBottomNavBar), findsNothing);
      final tabletRail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(tabletRail.extended, false);

      // 3. Desktop (1280x800): Extended NavigationRail
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpWidget(_wrapWithProviders(const MainNavigationScreen()));
      await tester.pumpAndSettle();
      final desktopRail = tester.widget<NavigationRail>(find.byType(NavigationRail));
      expect(desktopRail.extended, true);
    },
  );

  testWidgets(
    'HomeScreen and MainCategoriesScreen adapt GridView column counts across breakpoints',
    (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;

      // Small phone (320x640) -> HomeScreen 2 cols, MainCategories 2 cols
      tester.view.physicalSize = const Size(320, 640);
      await tester.pumpWidget(_wrapWithProviders(const HomeScreen()));
      await tester.pumpAndSettle();
      final homePhoneGrid = tester.widget<GridView>(find.byType(GridView));
      expect((homePhoneGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount, 2);

      await tester.pumpWidget(_wrapWithProviders(const MainCategoriesScreen()));
      await tester.pumpAndSettle();
      final catSmallGrid = tester.widget<GridView>(find.byType(GridView));
      expect((catSmallGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount, 2);

      // Tablet (760x1024) -> HomeScreen 3 cols
      tester.view.physicalSize = const Size(760, 1024);
      await tester.pumpWidget(_wrapWithProviders(const HomeScreen()));
      await tester.pumpAndSettle();
      final homeTabletGrid = tester.widget<GridView>(find.byType(GridView));
      expect((homeTabletGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount, 3);

      // Desktop (1280x800) -> HomeScreen 5 cols, MainCategories 5 cols
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpWidget(_wrapWithProviders(const HomeScreen()));
      await tester.pumpAndSettle();
      final homeDesktopGrid = tester.widget<GridView>(find.byType(GridView));
      expect((homeDesktopGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount, 5);

      await tester.pumpWidget(_wrapWithProviders(const MainCategoriesScreen()));
      await tester.pumpAndSettle();
      final catDesktopGrid = tester.widget<GridView>(find.byType(GridView));
      expect((catDesktopGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount).crossAxisCount, 5);
    },
  );

  testWidgets(
    'CartScreen and ProductDetailsScreen adapt cleanly on desktop and small phones',
    (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;

      // Desktop CartScreen renders two-column Row without overflow
      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpWidget(_wrapWithProviders(const CartScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpAndSettle();
      final removeButtons = find.byTooltip('Remove item');
      final itemCount = removeButtons.evaluate().length;
      expect(itemCount, greaterThan(1));
      await tester.tap(removeButtons.first);
      await tester.pumpAndSettle();
      expect(removeButtons, findsNWidgets(itemCount - 1));
      expect(tester.takeException(), isNull);

      // Small phone ProductDetailsScreen renders without overflow
      final productsRepo = ProductsRepository();
      final products = await productsRepo.getProducts();
      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpWidget(
        _wrapWithProviders(ProductDetailsScreen(product: products.first)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Desktop ProductDetailsScreen renders two-column layout without overflow
      tester.view.physicalSize = const Size(1200, 800);
      await tester.pumpWidget(
        _wrapWithProviders(ProductDetailsScreen(product: products.first)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Secondary screens render cleanly on compact phones (320x568) and desktop (1280x800)',
    (WidgetTester tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;

      final screens = <Widget>[
        const MyOrdersScreen(),
        const CustomerServiceScreen(),
        const FaqScreen(),
        const SavedAddressesScreen(),
        const LiveChatScreen(),
      ];

      for (final size in const [Size(320, 568), Size(1280, 800)]) {
        tester.view.physicalSize = size;
        for (final screen in screens) {
          await tester.pumpWidget(_wrapWithProviders(screen));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${screen.runtimeType} threw an exception at $size',
          );
        }
      }
    },
  );
}
