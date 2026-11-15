import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeplus/data/repositories/cart_repository.dart';
import 'package:homeplus/data/services/mock_data_service.dart';
import 'package:homeplus/ui/features/checkout/payment_methods_screen.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Checkout can add two demo cards and review the selected card', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CartViewModel(cartRepository: CartRepository()),
        child: MaterialApp(
          home: PaymentMethodsScreen(
            selectedAddress: MockDataService.getDefaultAddress(),
            deliveryMethod: 'Standard',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Credit / Debit Card'));
    await tester.pumpAndSettle();
    for (final digits in ['1234', '9876']) {
      final add = find.text('Add demo Visa');
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), digits);
      await tester.pump();
      await tester.tap(find.text('Add card'));
      await tester.pumpAndSettle();
    }

    final first = find.text('Demo Visa •••• 1234');
    expect(find.text('Demo Visa •••• 9876'), findsOneWidget);
    final carousel = find.byType(PageView);
    await tester.ensureVisible(carousel);
    await tester.drag(carousel, const Offset(430, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to Review Order'));
    await tester.pumpAndSettle();
    expect(first, findsOneWidget);
    expect(find.text('Demo Visa •••• 9876'), findsNothing);
  });
}
