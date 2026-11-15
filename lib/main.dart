import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Core
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'ui/core_widgets/telegram_theme_switcher.dart';

// Data Repositories
import 'data/repositories/products_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/cart_repository.dart';
import 'data/repositories/wishlist_repository.dart';
import 'data/repositories/orders_repository.dart';
import 'data/repositories/support_repository.dart';

// ViewModels
import 'ui/view_models/app_theme_view_model.dart';
import 'ui/view_models/auth_view_model.dart';
import 'ui/view_models/products_view_model.dart';
import 'ui/view_models/cart_view_model.dart';
import 'ui/view_models/wishlist_view_model.dart';
import 'ui/view_models/orders_view_model.dart';
import 'ui/view_models/support_view_model.dart';

// Initial Screen
import 'ui/features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate Repositories (Data Layer)
  final productsRepository = ProductsRepository();
  final authRepository = AuthRepository();
  final cartRepository = CartRepository();
  final wishlistRepository = WishlistRepository();
  final ordersRepository = OrdersRepository();
  final supportRepository = SupportRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppThemeViewModel()),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ProductsViewModel(productsRepository: productsRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CartViewModel(cartRepository: cartRepository),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              WishlistViewModel(wishlistRepository: wishlistRepository),
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
}

class HomePlusApp extends StatelessWidget {
  const HomePlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<AppThemeViewModel>();
    final isArabic = themeVm.isRTL;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(
        isArabic,
        christmas: themeVm.appearance == AppAppearance.christmas,
      ),
      darkTheme: AppTheme.getDarkTheme(isArabic),
      themeMode: themeVm.themeMode,
      themeAnimationStyle: AnimationStyle.noAnimation,
      locale: themeVm.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return TelegramThemeOverlay(child: child ?? const SizedBox.shrink());
      },
      home: const SplashScreen(),
    );
  }
}
