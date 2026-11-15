import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/telegram_theme_switcher.dart';
import 'package:homeplus/ui/view_models/app_theme_view_model.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import '../profile/personal_info_screen.dart';
import '../profile/saved_addresses_screen.dart';
import '../auth/forgot_password_flow.dart';
import '../auth/sign_in_screen.dart';
import '../legal/legal_content_screen.dart';
import '../legal/about_app_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            Text(ctx.l10n.tr('delete_account_title')),
          ],
        ),
        content: Text(ctx.l10n.tr('delete_account_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.l10n.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthViewModel>().deleteAccount();
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false,
              );
            },
            child: Text(
              ctx.l10n.tr('delete_forever'),
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeVm = context.watch<AppThemeViewModel>();
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(title: Text(l10n.tr('settings'))),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hPad = ResponsiveLayout.horizontalPadding(constraints.maxWidth);
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
            child: ResponsiveConstrainedBox(
              maxWidth: ResponsiveLayout.maxReadableWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Settings
                  _buildSectionHeader(context, l10n.tr('account_settings')),
                  _buildSettingTile(
                    context,
                    icon: Icons.person_outline,
                    title: l10n.tr('personal_info'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PersonalInfoScreen(),
                        ),
                      );
                    },
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.lock_outline,
                    title: l10n.tr('change_password'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordFlow(),
                        ),
                      );
                    },
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.location_on_outlined,
                    title: l10n.tr('saved_addresses'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SavedAddressesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // App Preferences
                  _buildSectionHeader(context, l10n.tr('app_preferences')),
                  // Language
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: context.surfaceBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.borderColor,
                        width: 0.8,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.language,
                        size: 22,
                        color: context.textPrimaryColor,
                      ),
                      title: Text(
                        l10n.tr('language'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: themeVm.locale.languageCode,
                        dropdownColor: context.cardBg,
                        underline: const SizedBox.shrink(),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: context.textSecondaryColor,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(
                              'English',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'ar',
                            child: Text(
                              'العربية',
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Cairo',
                                color: context.textPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) themeVm.setLocale(Locale(val));
                        },
                      ),
                    ),
                  ),
                  // Notifications Toggle
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: context.surfaceBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.borderColor,
                        width: 0.8,
                      ),
                    ),
                    child: SwitchListTile(
                      secondary: Icon(
                        Icons.notifications_outlined,
                        size: 22,
                        color: context.textPrimaryColor,
                      ),
                      title: Text(
                        l10n.tr('notifications'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      activeThumbColor: AppColors.primary,
                      value: true,
                      onChanged: (_) {},
                    ),
                  ),
                  // Appearance (Telegram-style interactive Theme Switcher)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    decoration: BoxDecoration(
                      color: context.surfaceBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.borderColor,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette_outlined,
                              size: 22,
                              color: context.textPrimaryColor,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                l10n.tr('appearance'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                            ),
                            const TelegramThemeToggleButton(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildAppearanceModeChip(
                                context: context,
                                mode: AppAppearance.light,
                                currentMode: themeVm.appearance,
                                label: l10n.tr('light'),
                                icon: Icons.wb_sunny_outlined,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildAppearanceModeChip(
                                context: context,
                                mode: AppAppearance.dark,
                                currentMode: themeVm.appearance,
                                label: l10n.tr('dark'),
                                icon: Icons.nights_stay_outlined,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildAppearanceModeChip(
                                context: context,
                                mode: AppAppearance.system,
                                currentMode: themeVm.appearance,
                                label: l10n.tr('system'),
                                icon: Icons.brightness_auto_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: _buildAppearanceModeChip(
                            context: context,
                            mode: AppAppearance.christmas,
                            currentMode: themeVm.appearance,
                            label: l10n.tr('christmas'),
                            icon: Icons.park,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Other Settings
                  _buildSectionHeader(context, l10n.tr('other_settings')),
                  _buildSettingTile(
                    context,
                    icon: Icons.security_outlined,
                    title: l10n.tr('privacy_security'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LegalContentScreen(
                            title: context.l10nRead.tr('privacy_security'),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.description_outlined,
                    title: l10n.tr('terms_conditions'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LegalContentScreen(
                            title: context.l10nRead.tr('terms_conditions'),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildSettingTile(
                    context,
                    icon: Icons.info_outline,
                    title: l10n.tr('about_app'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AboutAppScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Delete Account (Mockup Match: Red trash can & text)
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showDeleteAccountDialog(context),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      label: Text(
                        l10n.tr('delete_account'),
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppearanceModeChip({
    required BuildContext context,
    required AppAppearance mode,
    required AppAppearance currentMode,
    required String label,
    required IconData icon,
  }) {
    final isSelected = mode == currentMode;
    final accentColor = context.isDarkMode
        ? AppColors.primaryLight
        : AppColors.primary;
    return TelegramThemeToggleButton.builder(
      builder: (switcherContext, targetKey) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            TelegramThemeToggleButton.applyThemeMode(
              context: switcherContext,
              mode: mode,
              sourceKey: targetKey,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(
                      alpha: context.isDarkMode ? 0.2 : 0.12,
                    )
                  : context.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? accentColor : context.borderColor,
                width: isSelected ? 1.4 : 0.8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? accentColor : context.textSecondaryColor,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? accentColor
                        : context.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: context.textPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor, width: 0.8),
      ),
      child: ListTile(
        leading: Icon(icon, size: 22, color: context.textPrimaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.textPrimaryColor,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 20,
          color: context.textSecondaryColor,
        ),
        onTap: onTap,
      ),
    );
  }
}
