import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/main.dart';
import 'package:homeplus/data/repositories/products_repository.dart';
import 'package:homeplus/data/repositories/auth_repository.dart';
import 'package:homeplus/data/repositories/cart_repository.dart';
import 'package:homeplus/data/repositories/wishlist_repository.dart';
import 'package:homeplus/data/repositories/orders_repository.dart';
import 'package:homeplus/data/repositories/support_repository.dart';
import 'package:homeplus/ui/view_models/app_theme_view_model.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';
import 'package:homeplus/ui/view_models/orders_view_model.dart';
import 'package:homeplus/ui/view_models/support_view_model.dart';

void main() {
  testWidgets('HomePlus smoke test', (WidgetTester tester) async {
    final productsRepository = ProductsRepository();
    final authRepository = AuthRepository();
    final cartRepository = CartRepository();
    final wishlistRepository = WishlistRepository();
    final ordersRepository = OrdersRepository();
    final supportRepository = SupportRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppThemeViewModel()),
          ChangeNotifierProvider(
            create: (_) => AuthViewModel(authRepository: authRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => ProductsViewModel(productsRepository: productsRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => CartViewModel(cartRepository: cartRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => WishlistViewModel(wishlistRepository: wishlistRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => OrdersViewModel(ordersRepository: ordersRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => SupportViewModel(supportRepository: supportRepository),
          ),
        ],
        child: const HomePlusApp(),
      ),
    );

    // Pump past the 2-second splash timer so no timers remain pending
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(HomePlusApp), findsOneWidget);
  });
}
