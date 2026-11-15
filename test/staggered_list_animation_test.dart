import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeplus/ui/core_widgets/staggered_list_animation.dart';

void main() {
  testWidgets('StaggeredListLimiter and StaggeredListItem animate and settle cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaggeredListLimiter(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return StaggeredListItem(
                  index: index,
                  child: ListTile(title: Text('Appliance Item $index')),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AnimationLimiter), findsOneWidget);
    expect(find.byType(SlideAnimation), findsNWidgets(5));
    expect(find.byType(FadeInAnimation), findsNWidgets(5));

    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i++) {
      expect(find.text('Appliance Item $i'), findsOneWidget);
    }
  });

  testWidgets('StaggeredGridItem clamps large indices and settles cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaggeredListLimiter(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return StaggeredGridItem(
                  index: index + 20, // verify clamped index doesn't cause multi-second delay
                  columnCount: 2,
                  child: Card(child: Center(child: Text('Grid $index'))),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ScaleAnimation), findsNWidgets(4));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Grid 0'), findsOneWidget);
    expect(find.text('Grid 3'), findsOneWidget);
  });
}
