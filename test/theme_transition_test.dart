import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/core/theme/app_theme.dart';
import 'package:homeplus/ui/core_widgets/telegram_theme_switcher.dart';
import 'package:homeplus/ui/view_models/app_theme_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Light and dark themes paint behind the fully covered frame', (
    tester,
  ) async {
    final theme = AppThemeViewModel();
    addTearDown(theme.dispose);
    const pageKey = ValueKey('theme test page');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: theme,
        child: Consumer<AppThemeViewModel>(
          builder: (context, model, child) => MaterialApp(
            themeMode: model.themeMode,
            theme: AppTheme.getLightTheme(
              false,
              christmas: model.appearance == AppAppearance.christmas,
            ),
            darkTheme: ThemeData.dark(),
            themeAnimationStyle: AnimationStyle.noAnimation,
            builder: (context, child) => TelegramThemeOverlay(child: child!),
            home: const Scaffold(key: pageKey),
          ),
        ),
      ),
    );

    final overlay = tester.state<TelegramThemeOverlayState>(
      find.byType(TelegramThemeOverlay),
    );
    final clip = find.ancestor(
      of: find.byType(RawImage),
      matching: find.byType(ClipPath),
    );
    final page = find.byKey(pageKey);

    for (final target in [AppAppearance.dark, AppAppearance.light]) {
      final before = Theme.of(tester.element(page)).brightness;
      final switching = overlay.switchTheme(targetMode: target);
      await tester.pump();
      await tester.pump();
      expect(clip, findsOneWidget);
      expect(Theme.of(tester.element(page)).brightness, before);

      await tester.pump();
      final path = tester
          .widget<ClipPath>(clip)
          .clipper!
          .getClip(tester.getSize(page));
      expect(path.contains(tester.getSize(page).center(Offset.zero)), isTrue);
      expect(Theme.of(tester.element(page)).brightness, isNot(before));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      final reveal = tester
          .widget<ClipPath>(clip)
          .clipper!
          .getClip(tester.getSize(page));
      expect(
        reveal.contains(tester.getSize(page).center(Offset.zero)),
        isFalse,
      );
      await tester.pumpAndSettle();
      await switching;
      expect(clip, findsNothing);
    }

    final christmas = overlay.switchTheme(targetMode: AppAppearance.christmas);
    for (var frame = 0; frame < 4; frame++) {
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 1500));
    await christmas;

    const decorations = ValueKey('christmas-decorations');
    expect(find.byKey(decorations), findsOneWidget);
    final pageContext = tester.element(page);
    expect(Theme.of(pageContext).brightness, Brightness.light);
    expect(pageContext.themeAccent, AppColors.christmasRed);

    var tapped = false;
    Navigator.of(pageContext).push<void>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => tapped = true,
              child: const Text('Next screen'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(decorations), findsOneWidget);
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    await tester.tap(find.text('Next screen'));
    expect(tapped, isTrue);

    theme.setAppearance(AppAppearance.light);
    await tester.pumpAndSettle();
    expect(find.byKey(decorations), findsNothing);
  });
}
