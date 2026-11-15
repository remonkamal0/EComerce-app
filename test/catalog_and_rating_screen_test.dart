import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/core/theme/app_theme.dart';
import 'package:homeplus/data/repositories/auth_repository.dart';
import 'package:homeplus/data/repositories/products_repository.dart';
import 'package:homeplus/ui/core_widgets/category_card.dart';
import 'package:homeplus/ui/features/categories/main_categories_screen.dart';
import 'package:homeplus/ui/features/profile/my_reviews_screen.dart';
import 'package:homeplus/ui/view_models/app_theme_view_model.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/products_view_model.dart';

void main() {
  testWidgets(
    'MainCategoriesScreen displays 3-column catalog cards, hero banner, and search toggle',
    (WidgetTester tester) async {
      final themeVm = AppThemeViewModel();
      final productsVm = ProductsViewModel(productsRepository: ProductsRepository());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeVm),
            ChangeNotifierProvider.value(value: productsVm),
          ],
          child: MaterialApp(
            theme: AppTheme.getLightTheme(false),
            darkTheme: AppTheme.getDarkTheme(false),
            home: const MainCategoriesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Quality Appliances\nDelivered Fast'), findsOneWidget);
      expect(find.byType(CategoryCatalogCard), findsWidgets);

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 3);

      // Tap circular Search button to reveal inline category search bar.
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Fridge');
      await tester.pumpAndSettle();
      expect(find.text('Refrigerators'), findsNothing); // search matches "Refrigerators", not "Fridge"
      await tester.enterText(find.byType(TextField), 'Refrig');
      await tester.pumpAndSettle();
      expect(find.text('Refrigerators'), findsOneWidget);
    },
  );

  testWidgets(
    'MyReviewsScreen renders emerald rating mockup UI and submits new review live',
    (WidgetTester tester) async {
      final themeVm = AppThemeViewModel();
      final productsVm = ProductsViewModel(productsRepository: ProductsRepository());
      final authVm = AuthViewModel(authRepository: AuthRepository());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeVm),
            ChangeNotifierProvider.value(value: productsVm),
            ChangeNotifierProvider.value(value: authVm),
          ],
          child: MaterialApp(
            theme: AppTheme.getLightTheme(false),
            darkTheme: AppTheme.getDarkTheme(false),
            home: const MyReviewsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rating & Reviews'), findsOneWidget);
      expect(find.text('How was your experience?'), findsOneWidget);
      expect(find.text('Add a Review (Optional)'), findsOneWidget);
      expect(find.text('Your Recent Reviews'), findsOneWidget);
      expect(find.text('0/500'), findsOneWidget);

      final submitBtn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Submit Review'),
      );
      expect(
        submitBtn.style?.backgroundColor?.resolve(<WidgetState>{}),
        AppColors.primary,
      );

      // Enter comment and verify live character counter + submission.
      const comment = 'Silent inverter motor and fast delivery!';
      await tester.enterText(find.byType(TextField), comment);
      await tester.pumpAndSettle();
      expect(find.text('${comment.length}/500'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Review'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text(comment), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    },
  );
}
