import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';

void main() {
  testWidgets('ApplianceImage uses CachedNetworkImage for valid HTTP(S) URLs',
      (WidgetTester tester) async {
    const testUrl = 'https://example.com/fridge.jpg';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 120,
            child: ApplianceImage(imageUrl: testUrl),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CachedNetworkImage), findsOneWidget);
    final widget = tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage));
    expect(widget.imageUrl, testUrl);
    expect(widget.maxWidthDiskCache, 1000);
  });

  testWidgets('ApplianceImage renders fallback icon cleanly for empty or invalid URLs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ApplianceImage(
                imageUrl: '',
                width: 80,
                height: 80,
                fallbackIcon: Icons.kitchen_outlined,
              ),
              ApplianceImage(
                imageUrl: 'not-a-valid-url',
                width: 80,
                height: 80,
                fallbackIcon: Icons.local_laundry_service_outlined,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.kitchen_outlined), findsOneWidget);
    expect(find.byIcon(Icons.local_laundry_service_outlined), findsOneWidget);
  });

  test('ApplianceImage.provider returns CachedNetworkImageProvider for HTTP(S) URLs only', () {
    final validProvider = ApplianceImage.provider('https://example.com/oven.png');
    expect(validProvider, isA<CachedNetworkImageProvider>());

    expect(ApplianceImage.provider(''), isNull);
    expect(ApplianceImage.provider('assets/images/logo.png'), isNull);
    expect(ApplianceImage.provider('ftp://example.com/file.png'), isNull);
  });
}
