import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeplus/data/repositories/auth_repository.dart';
import 'package:homeplus/ui/features/profile/saved_addresses_screen.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'Address deletion previews the address and requires confirmation',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final auth = AuthViewModel(authRepository: AuthRepository());
      addTearDown(auth.dispose);
      final signingIn = auth.signIn('test@example.com', 'test');
      await tester.pump(const Duration(milliseconds: 400));
      await signingIn;
      final address = auth.currentUser!.addresses.first;
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: auth,
          child: const MaterialApp(home: SavedAddressesScreen()),
        ),
      );
      await tester.pumpAndSettle();
      final deleteAddress = find.byTooltip('Delete address').first;

      await tester.tap(deleteAddress);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(address.formattedAddress),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(auth.currentUser!.addresses.first.id, address.id);

      await tester.tap(deleteAddress);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(
        auth.currentUser!.addresses.map((item) => item.id),
        isNot(contains(address.id)),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
