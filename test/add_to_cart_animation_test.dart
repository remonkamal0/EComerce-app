import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_theme.dart';
import 'package:homeplus/data/repositories/auth_repository.dart';
import 'package:homeplus/data/repositories/cart_repository.dart';
import 'package:homeplus/data/repositories/products_repository.dart';
import 'package:homeplus/data/repositories/wishlist_repository.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/core_widgets/add_to_cart_animation.dart';
import 'package:homeplus/ui/core_widgets/bottom_nav_bar.dart';
import 'package:homeplus/ui/core_widgets/product_card.dart';
import 'package:homeplus/ui/features/cart/cart_screen.dart';
import 'package:homeplus/ui/features/products/product_details_screen.dart';
import 'package:homeplus/ui/view_models/app_theme_view_model.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';

class _SignedInTestAuthRepository extends AuthRepository {
  @override
  Future<UserModel?> getCurrentUser() async {
    return const UserModel(
      id: 'test_user',
      name: 'Test Shopper',
      email: 'shopper@example.com',
      phone: '+201000000000',
      isGuest: false,
    );
  }
}

Product _sampleProduct({List<String> images = const []}) {
  return Product(
    id: 'test_fridge',
    name: 'LG Smart Refrigerator',
    brand: 'LG',
    categoryId: 'cat_fridge',
    categoryName: 'Refrigerators',
    price: 999.0,
    originalPrice: 1199.0,
    rating: 4.8,
    reviewCount: 42,
    description: 'Inverter cooling technology',
    images: images,
  );
}

void main() {
  testWidgets(
    'GlobalKey fly-to-cart animates thumbnail from ProductGridCard to BottomNavBar and disposes cleanly',
    (WidgetTester tester) async {
      final authVm = AuthViewModel(authRepository: _SignedInTestAuthRepository());
      var addCount = 0;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppThemeViewModel()),
            ChangeNotifierProvider.value(value: authVm),
          ],
          child: MaterialApp(
            home: AddToCartOverlayScope(
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: 190,
                    height: 290,
                    child: ProductGridCard(
                      product: _sampleProduct(),
                      onWishlistTap: () {},
                      onAddToCart: () => addCount++,
                    ),
                  ),
                ),
                bottomNavigationBar: HomePlusBottomNavBar(
                  currentIndex: 0,
                  onTabSelected: (_) {},
                  cartItemCount: 1,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(authVm.isAuthenticated, isTrue);

      // Flying bag thumbnail is not in the tree before tapping Add to Cart.
      expect(find.byIcon(Icons.shopping_bag_rounded), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(ProductGridCard),
          matching: find.byIcon(Icons.favorite_border),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 170));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();

      // Tap Add to Cart button on ProductGridCard.
      await tester.tap(find.byIcon(Icons.add_shopping_cart));
      await tester.pump();
      expect(addCount, 1);

      // Advance into the flight curve (~300ms of 620ms) and verify overlay entry is flying.
      await tester.pump(const Duration(milliseconds: 140));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 160));
      final flyingIconFinder = find.byIcon(Icons.shopping_bag_rounded);
      expect(flyingIconFinder, findsOneWidget);

      final midFlightPos = tester.getCenter(flyingIconFinder);
      final targetCartPos = tester.getCenter(find.byIcon(Icons.shopping_cart_outlined));
      expect(midFlightPos.dy, lessThan(targetCartPos.dy));

      // Finish both the flight animation and the CartTargetBounce landing animation.
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.shopping_bag_rounded), findsNothing);
    },
  );

  testWidgets(
    'AddToCartOverlayScope disposes mid-flight controllers without ticker leaks and supports CartAppBarButton',
    (WidgetTester tester) async {
      final sourceKey = GlobalKey();
      final authVm = AuthViewModel(authRepository: _SignedInTestAuthRepository());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppThemeViewModel()),
            ChangeNotifierProvider.value(value: authVm),
          ],
          child: MaterialApp(
            home: AddToCartOverlayScope(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Shop'),
                  actions: const [CartAppBarButton()],
                ),
                body: Center(
                  child: Builder(
                    builder: (ctx) => ElevatedButton(
                      key: sourceKey,
                      onPressed: () {
                        AddToCartOverlayScope.maybeOf(ctx)?.flyToCart(
                          sourceKey: sourceKey,
                        );
                      },
                      child: const Text('Fly'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byKey(sourceKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byIcon(Icons.shopping_bag_rounded), findsOneWidget);

      // Dispose the scope mid-flight to verify active AnimationControllers/OverlayEntries clean up cleanly.
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.shopping_bag_rounded), findsNothing);
    },
  );

  testWidgets(
    'ProductDetailsScreen bottom Add to Cart button launches visible upward flight into CartAppBarButton',
    (WidgetTester tester) async {
      final authVm = AuthViewModel(authRepository: _SignedInTestAuthRepository());
      final cartVm = CartViewModel(cartRepository: CartRepository());
      final productsVm = ProductsViewModel(productsRepository: ProductsRepository());
      final wishlistVm = WishlistViewModel(wishlistRepository: WishlistRepository());
      final product = _sampleProduct();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppThemeViewModel()),
            ChangeNotifierProvider.value(value: authVm),
            ChangeNotifierProvider.value(value: cartVm),
            ChangeNotifierProvider.value(value: productsVm),
            ChangeNotifierProvider.value(value: wishlistVm),
          ],
          child: MaterialApp(
            home: ProductDetailsScreen(product: product),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(authVm.isAuthenticated, isTrue);
      final initialCount = cartVm.itemCount;

      final addButton = find.widgetWithText(ElevatedButton, 'Add to Cart');
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final flyingIconFinder = find.byIcon(Icons.shopping_bag_rounded);
      expect(flyingIconFinder, findsOneWidget);

      final midFlightPos = tester.getCenter(flyingIconFinder);
      final appBarCartFinder = find.descendant(
        of: find.byType(CartAppBarButton),
        matching: find.byIcon(Icons.shopping_cart_outlined),
      );
      final targetCartPos = tester.getCenter(appBarCartFinder);
      final buttonPos = tester.getCenter(addButton);

      // Must remain comfortably inside the visible viewport while flying upward.
      expect(midFlightPos.dy, greaterThan(0));
      expect(midFlightPos.dy, lessThan(buttonPos.dy));
      expect(midFlightPos.dy, greaterThan(targetCartPos.dy));
      expect(cartVm.itemCount, initialCount + 1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('View Cart'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.shopping_bag_rounded), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    },
  );

  testWidgets(
    'Arabic RTL SnackBar renders white View Cart action above Add to Cart button and opens CartScreen',
    (WidgetTester tester) async {
      final authVm = AuthViewModel(authRepository: _SignedInTestAuthRepository());
      final cartVm = CartViewModel(cartRepository: CartRepository());
      final productsVm = ProductsViewModel(productsRepository: ProductsRepository());
      final wishlistVm = WishlistViewModel(wishlistRepository: WishlistRepository());
      final themeVm = AppThemeViewModel()..setLocale(const Locale('ar'));
      final product = _sampleProduct();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeVm),
            ChangeNotifierProvider.value(value: authVm),
            ChangeNotifierProvider.value(value: cartVm),
            ChangeNotifierProvider.value(value: productsVm),
            ChangeNotifierProvider.value(value: wishlistVm),
          ],
          child: MaterialApp(
            theme: AppTheme.getLightTheme(true),
            darkTheme: AppTheme.getDarkTheme(true),
            home: Directionality(
              textDirection: TextDirection.rtl,
              child: ProductDetailsScreen(product: product),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final addButton = find.widgetWithText(ElevatedButton, 'أضف إلى السلة');
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      final snackBarFinder = find.byType(SnackBar);
      final actionFinder = find.byType(SnackBarAction);
      expect(snackBarFinder, findsOneWidget);
      expect(actionFinder, findsOneWidget);
      expect(find.text('عرض السلة'), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(snackBarFinder);
      final action = tester.widget<SnackBarAction>(actionFinder);
      final theme = Theme.of(tester.element(snackBarFinder));

      expect(snackBar.behavior, SnackBarBehavior.floating);
      expect(snackBar.persist, isFalse);
      expect(action.textColor, Colors.white);
      expect(action.disabledTextColor, Colors.white70);
      expect(theme.snackBarTheme.actionTextColor, Colors.white);
      expect(theme.snackBarTheme.disabledActionTextColor, Colors.white70);

      // Floating SnackBar sits cleanly above the Add to Cart bar without overlapping it.
      final snackRect = tester.getRect(snackBarFinder);
      final buttonRect = tester.getRect(addButton);
      expect(snackRect.bottom, lessThanOrEqualTo(buttonRect.top));

      await tester.tap(find.text('عرض السلة'));
      await tester.pumpAndSettle();

      expect(find.byType(CartScreen), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    },
  );
}
