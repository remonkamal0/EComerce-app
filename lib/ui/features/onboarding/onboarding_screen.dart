import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/app_logo.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/language_toggle_pill.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/telegram_theme_switcher.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import '../auth/sign_in_screen.dart';
import '../auth/create_account_screen.dart';
import '../main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> _buildSlides(AppLocalizations l10n) => [
    {
      'title': l10n.tr('onboard_title_1'),
      'desc': l10n.tr('onboard_desc_1'),
      'image': 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': l10n.tr('onboard_title_2_brand'),
      'desc': l10n.tr('onboard_desc_2_brand'),
      'image': 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=800&auto=format&fit=crop&q=80',
    },
    {
      'title': l10n.tr('onboard_title_3'),
      'desc': l10n.tr('onboard_desc_3'),
      'image': 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=800&auto=format&fit=crop&q=80',
    },
  ];

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToSignIn();
    }
  }

  void _navigateToSignIn() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  void _browseAsGuest() {
    context.read<AuthViewModel>().continueAsGuest();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slides = _buildSlides(l10n);
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const TelegramThemeToggleButton(),
          const SizedBox(width: 6),
          const LanguageTogglePill(),
          const SizedBox(width: 6),
          if (_currentPage < slides.length - 1)
            TextButton(
              onPressed: _navigateToSignIn,
              child: Text(
                l10n.tr('skip'),
                style: TextStyle(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxFormWidth,
          alignment: Alignment.center,
          child: Column(
            children: [
            // Top Logo
            const SizedBox(height: 8),
            const AppLogo(
              iconSize: 42,
              showTagline: true,
              isHorizontal: false,
            ),
            const SizedBox(height: 20),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, index) {
                  final item = slides[index];
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final availableHeight = constraints.maxHeight;
                      final imageHeight = (availableHeight * 0.46).clamp(100.0, 240.0);

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: imageHeight,
                                width: double.infinity,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: context.mintLightBg,
                                  borderRadius: BorderRadius.circular(24),
                                  border: context.isDarkMode ? Border.all(color: context.borderColor) : null,
                                ),
                                child: ApplianceImage(
                                  imageUrl: item['image']!,
                                  borderRadius: 0,
                                  fit: BoxFit.cover,
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              SizedBox(height: availableHeight < 400 ? 14 : 26),

                              // Title
                              Text(
                                item['title']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: availableHeight < 400 ? 21 : 25,
                                  fontWeight: FontWeight.w800,
                                  color: context.textPrimaryColor,
                                  height: 1.25,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Description
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  item['desc']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.textSecondaryColor,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (index) {
                final isSelected = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? accentPrimary : context.borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  CustomButton(
                    text: _currentPage == slides.length - 1 ? l10n.tr('get_started') : l10n.tr('next'),
                    onPressed: _onNext,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _browseAsGuest,
                        child: Text(
                          l10n.tr('browse_as_guest'),
                          style: TextStyle(
                            color: context.textSecondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text('•', style: TextStyle(color: context.borderColor)),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                          );
                        },
                        child: Text(
                          l10n.tr('create_account'),
                          style: TextStyle(
                            color: accentPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
        ),
      ),
    );
  }
}


