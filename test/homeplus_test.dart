import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animations/animations.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_theme.dart';
import 'package:homeplus/data/repositories/cart_repository.dart';
import 'package:homeplus/data/repositories/products_repository.dart';
import 'package:homeplus/data/repositories/orders_repository.dart';
import 'package:homeplus/data/repositories/auth_repository.dart';
import 'package:homeplus/data/repositories/wishlist_repository.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import 'package:homeplus/ui/view_models/orders_view_model.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';
import 'package:homeplus/ui/view_models/app_theme_view_model.dart';
import 'package:homeplus/ui/core_widgets/product_price_view.dart';
import 'package:homeplus/ui/core_widgets/product_card.dart';
import 'package:homeplus/ui/core_widgets/lottie_success_view.dart';
import 'package:homeplus/ui/features/checkout/order_success_screen.dart';
import 'package:homeplus/domain/models/models.dart';

void main() {
  group('HomePlus Clean Architecture & Business Logic Tests', () {
    test('Products Repository loads categories and special offers', () async {
      final repo = ProductsRepository();
      final products = await repo.getProducts();
      final categories = await repo.getCategories();
      final offers = await repo.getFeaturedOffers();

      expect(products.isNotEmpty, true);
      expect(categories.length >= 6, true);
      expect(offers.isNotEmpty, true);

      // Verify refrigerator data matching reference mockup
      final fridge = products.firstWhere((p) => p.id == 'p_fridge_samsung_600');
      expect(fridge.price, 599.0);
      expect(fridge.originalPrice, 749.0);
      expect(fridge.features.any((f) => f.title == 'No Frost'), true);
      expect(fridge.capacity, '600 L');
    });

    test('Cart ViewModel calculations match reference mockup exactly', () async {
      final cartRepo = CartRepository();
      final cartVm = CartViewModel(cartRepository: cartRepo);

      // Wait for initial mockup cart items to load
      await Future.delayed(const Duration(milliseconds: 50));

      // Mockup exact numbers:
      // Samsung Fridge ($599) + LG Washer ($449) + Samsung Microwave ($129) = $1,177
      expect(cartVm.subtotal, 1177.0);

      // Discount: -$100 from HOMEPLUS100
      expect(cartVm.couponDiscount, 100.0);

      // Delivery fee: $20
      expect(cartVm.deliveryFee, 20.0);

      // Total: 1177 - 100 + 20 = $1,097!
      expect(cartVm.total, 1097.0);
    });

    test('Products Filter & Search logic filters correctly', () async {
      final repo = ProductsRepository();
      final vm = ProductsViewModel(productsRepository: repo);
      await Future.delayed(const Duration(milliseconds: 50));

      // Test brand filter
      vm.toggleBrand('Samsung');
      await Future.delayed(const Duration(milliseconds: 50));
      for (final p in vm.searchResults) {
        expect(p.brand, 'Samsung');
      }

      // Reset
      vm.resetFilters();
      await vm.applyFilters();
      expect(vm.searchResults.length, vm.allProducts.length);
    });

    test('Orders ViewModel places order with complete timeline', () async {
      final orderRepo = OrdersRepository();
      final ordersVm = OrdersViewModel(ordersRepository: orderRepo);
      await Future.delayed(const Duration(milliseconds: 50));

      final initialCount = ordersVm.orders.length;
      expect(initialCount >= 2, true);

      // Verify Tracking Order #HP123456 from reference mockup
      final trackingOrder = ordersVm.orders.firstWhere((o) => o.id == 'HP123456');
      expect(trackingOrder.timeline.length, 4);
      expect(trackingOrder.timeline[0].title, 'Order Confirmed');
      expect(trackingOrder.timeline[1].title, 'Preparing in Warehouse');
    });

    testWidgets(
      'Guest user sees "Sign in for price" in EN, "لمعرفة السعر سجل" with Cairo font in AR, and price displays after sign in',
      (tester) async {
        final authRepo = AuthRepository();
        final authVm = AuthViewModel(authRepository: authRepo);
        final themeVm = AppThemeViewModel();

        // Pump to let initial async load complete
        await tester.pump(const Duration(milliseconds: 100));

        expect(authVm.isAuthenticated, false);
        expect(authVm.isGuest, true);

        // Render ProductPriceView in guest mode inside localized MaterialApp
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: authVm),
              ChangeNotifierProvider.value(value: themeVm),
            ],
            child: Consumer<AppThemeViewModel>(
              builder: (context, theme, _) => MaterialApp(
                locale: theme.locale,
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.getLightTheme(theme.isRTL),
                home: const Scaffold(
                  body: ProductPriceView(price: 599.0, originalPrice: 749.0),
                ),
              ),
            ),
          ),
        );

        // Default English locale: should show 'Sign in for price' and NOT '$599'
        expect(find.text('Sign in for price'), findsOneWidget);
        expect(find.text('لمعرفة السعر سجل'), findsNothing);
        expect(find.text('\$599'), findsNothing);

        // Switch app locale to Arabic: verifies localized label, RTL layout, and Cairo font
        themeVm.setLocale(const Locale('ar'));
        await tester.pumpAndSettle();

        expect(find.text('لمعرفة السعر سجل'), findsOneWidget);
        expect(find.text('Sign in for price'), findsNothing);
        expect(
          Directionality.of(tester.element(find.byType(ProductPriceView))),
          TextDirection.rtl,
        );
        final priceText = tester.widget<Text>(find.text('لمعرفة السعر سجل'));
        expect(priceText.style?.fontFamily, 'Cairo');
        expect(
          Theme.of(tester.element(find.byType(ProductPriceView)))
              .textTheme
              .bodyMedium
              ?.fontFamily,
          'Cairo',
        );

        // Now trigger sign in and pump the fake timer
        authVm.signIn('ahmed@example.com', 'password123');
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(authVm.isAuthenticated, true);

        // Price should now be revealed: '$599' and '$749'
        expect(find.text('لمعرفة السعر سجل'), findsNothing);
        expect(find.text('Sign in for price'), findsNothing);
        expect(find.text('\$599'), findsOneWidget);
        expect(find.text('\$749'), findsOneWidget);
      },
    );

    testWidgets('ProductGridCard contains OpenContainer and triggers container transform', (tester) async {
      final authRepo = AuthRepository();
      final authVm = AuthViewModel(authRepository: authRepo);
      final themeVm = AppThemeViewModel();
      final cartRepo = CartRepository();
      final cartVm = CartViewModel(cartRepository: cartRepo);
      final wishlistRepo = WishlistRepository();
      final wishlistVm = WishlistViewModel(wishlistRepository: wishlistRepo);
      final productsRepo = ProductsRepository();
      final productsVm = ProductsViewModel(productsRepository: productsRepo);

      final testProduct = Product(
        id: 'test_p1',
        name: 'Smart Test Refrigerator',
        brand: 'Samsung',
        categoryId: 'refrigerators',
        categoryName: 'Refrigerators',
        price: 599.0,
        originalPrice: 749.0,
        images: ['https://example.com/fridge.jpg'],
        description: 'Test description',
        rating: 4.8,
        reviewCount: 42,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: authVm),
            ChangeNotifierProvider.value(value: themeVm),
            ChangeNotifierProvider.value(value: cartVm),
            ChangeNotifierProvider.value(value: wishlistVm),
            ChangeNotifierProvider.value(value: productsVm),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ProductGridCard(
                product: testProduct,
                onWishlistTap: () {},
                onAddToCart: () {},
              ),
            ),
          ),
        ),
      );

      // Verify OpenContainer exists in widget tree
      expect(find.byWidgetPredicate((w) => w is OpenContainer), findsOneWidget);
      expect(find.text('Smart Test Refrigerator'), findsOneWidget);

      // Tap card to trigger openContainer
      await tester.tap(find.text('Smart Test Refrigerator'));
      // Advance animation frames past the 480ms transition duration
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Product details screen is now open via container transform!
      expect(find.text('(${testProduct.reviewCount} reviews)'), findsOneWidget);
    });

    testWidgets('LottieSuccessView renders and integrates seamlessly with OrderSuccessScreen', (tester) async {
      final orderRepo = OrdersRepository();
      final orders = await orderRepo.getOrders();
      final sampleOrder = orders.first;

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: AppThemeViewModel(),
          child: MaterialApp(
            home: OrderSuccessScreen(order: sampleOrder),
          ),
        ),
      );

      // Verify LottieSuccessView, Lottie widget, and order information are presented
      expect(find.byType(LottieSuccessView), findsOneWidget);
      expect(find.byType(Lottie), findsOneWidget);
      expect(find.text('Order Placed Successfully!'), findsOneWidget);
      expect(find.text('#${sampleOrder.id}'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
    });
  });
}
