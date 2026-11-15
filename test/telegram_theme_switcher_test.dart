import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_theme.dart';
import 'package:homeplus/ui/core_widgets/telegram_theme_switcher.dart';
import 'package:homeplus/ui/view_models/app_theme_view_model.dart';

void main() {
  testWidgets(
    'TelegramThemeToggleButton expands circular reveal Light -> Dark -> Light via TelegramThemeOverlay',
    (WidgetTester tester) async {
      final themeVm = AppThemeViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppThemeViewModel>.value(
          value: themeVm,
          child: Consumer<AppThemeViewModel>(
            builder: (context, vm, _) {
              return MaterialApp(
                theme: AppTheme.getLightTheme(false),
                darkTheme: AppTheme.getDarkTheme(false),
                themeMode: vm.themeMode,
                themeAnimationStyle: AnimationStyle.noAnimation,
                builder: (context, child) {
                  return TelegramThemeOverlay(
                    child: child ?? const SizedBox.shrink(),
                  );
                },
                home: Scaffold(
                  appBar: AppBar(
                    title: const Text('Theme Test'),
                    actions: const [
                      Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: TelegramThemeToggleButton(),
                      ),
                    ],
                  ),
                  body: Builder(
                    builder: (ctx) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Theme.of(ctx).brightness == Brightness.dark
                                  ? 'dark-active'
                                  : 'light-active',
                            ),
                            TelegramThemeToggleButton.builder(
                              builder: (chipCtx, targetKey) {
                                return ActionChip(
                                  key: targetKey,
                                  label: const Text('Apply System'),
                                  onPressed: () {
                                    TelegramThemeToggleButton.applyThemeMode(
                                      context: chipCtx,
                                      mode: ThemeMode.system,
                                      sourceKey: targetKey,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(themeVm.isDarkMode, isFalse);
      expect(find.text('light-active'), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);
      expect(find.byType(ClipPath), findsNothing);

      // Tap Moon button to reveal Dark theme in an expanding circle.
      await tester.runAsync(() async {
        await tester.tap(find.byIcon(Icons.dark_mode_rounded));
        // Allow async snapshot capture (or fallback) to schedule animation.
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(themeVm.isDarkMode, isTrue);
      expect(find.text('dark-active'), findsOneWidget);
      expect(find.byType(ClipPath), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(ClipPath), findsNothing);
      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);

      // Tap Sun button to reveal Light theme in an expanding circle.
      await tester.runAsync(() async {
        await tester.tap(find.byIcon(Icons.light_mode_rounded));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(themeVm.isDarkMode, isFalse);
      expect(find.text('light-active'), findsOneWidget);
      expect(find.byType(ClipPath), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(ClipPath), findsNothing);
      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

      // Also verify builder + applyThemeMode works without throwing.
      await tester.runAsync(() async {
        await tester.tap(find.text('Apply System'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pumpAndSettle();
      expect(themeVm.themeMode, ThemeMode.system);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'TelegramThemeToggleButton falls back gracefully without TelegramThemeOverlay ancestor',
    (WidgetTester tester) async {
      final themeVm = AppThemeViewModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppThemeViewModel>.value(
          value: themeVm,
          child: MaterialApp(
            home: Scaffold(
              body: const Center(
                child: TelegramThemeToggleButton(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(themeVm.isDarkMode, isFalse);

      await tester.tap(find.byIcon(Icons.dark_mode_rounded));
      await tester.pumpAndSettle();

      expect(themeVm.isDarkMode, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
