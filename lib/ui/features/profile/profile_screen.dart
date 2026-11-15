import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/language_toggle_pill.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/telegram_theme_switcher.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/support_view_model.dart';
import 'package:homeplus/ui/view_models/orders_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';
import '../auth/sign_in_screen.dart';
import '../settings/settings_screen.dart';
import '../orders/my_orders_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../support/customer_service_screen.dart';
import '../notifications/notifications_screen.dart';
import '../legal/about_app_screen.dart';
import 'personal_info_screen.dart';
import 'saved_addresses_screen.dart';
import 'wallet_coupons_screen.dart';
import 'my_reviews_screen.dart';

class ProfileScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const ProfileScreen({super.key, this.onNavigateTab});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.tr('log_out')),
        content: Text(ctx.l10n.tr('logout_confirm_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.l10n.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthViewModel>().signOut();
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SignInScreen()),
                (route) => false,
              );
            },
            child: Text(ctx.l10n.tr('log_out'), style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.currentUser;
    final supportVm = context.watch<SupportViewModel>();
    final ordersVm = context.watch<OrdersViewModel>();
    final wishlistVm = context.watch<WishlistViewModel>();
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(l10n.tr('my_profile')),
        actions: [
          const TelegramThemeToggleButton(),
          const SizedBox(width: 6),
          const LanguageTogglePill(),
          const SizedBox(width: 2),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final hPad = ResponsiveLayout.horizontalPadding(constraints.maxWidth);
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
            child: ResponsiveConstrainedBox(
              maxWidth: ResponsiveLayout.maxReadableWidth,
              child: Column(
                children: [
            // User Header Card (Mockup Match)
            if (user != null && !user.isGuest)
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.mintLightBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.mintBg,
                        ),
                        child: ClipOval(
                          child: ApplianceImage(
                            imageUrl: user.avatarUrl,
                            borderRadius: 30,
                            fit: BoxFit.cover,
                            fallbackIcon: Icons.person,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: context.textSecondaryColor),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.mintLightBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: context.mintBg,
                      child: Icon(
                        Icons.person,
                        color: context.isDarkMode
                            ? AppColors.primaryLight
                            : AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tr('welcome_homeplus'),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: context.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SignInScreen()),
                              );
                            },
                            child: Text(
                              l10n.tr('guest_register_sub'),
                              style: TextStyle(
                                color: context.isDarkMode
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // 3 Stat Cards (Mockup Match: Orders, Wishlist, Rating / Reviews)
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    count: '${ordersVm.orders.length}',
                    label: l10n.tr('orders'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.favorite_border,
                    count: '${wishlistVm.itemCount}',
                    label: l10n.tr('wishlist'),
                    onTap: () {
                      if (onNavigateTab != null) {
                        onNavigateTab!(3);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WishlistScreen()),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.star_border,
                    count: '4.6',
                    label: l10n.tr('reviews_label'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MyReviewsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Menu Items List (Mockup Match)
            _buildMenuItem(
              context,
              icon: Icons.receipt_long_outlined,
              title: l10n.tr('my_orders'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.location_on_outlined,
              title: l10n.tr('my_addresses'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SavedAddressesScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.favorite_border,
              title: l10n.tr('my_wishlist'),
              onTap: () {
                if (onNavigateTab != null) {
                  onNavigateTab!(3);
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  );
                }
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.star_outline,
              title: l10n.tr('my_reviews'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyReviewsScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.tr('wallet_coupons'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WalletCouponsScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.notifications_outlined,
              title: l10n.tr('notifications'),
              badge: supportVm.unreadNotificationsCount > 0 ? '${supportVm.unreadNotificationsCount}' : null,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.headset_mic_outlined,
              title: l10n.tr('help_support'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CustomerServiceScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              title: l10n.tr('about_app'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutAppScreen()),
                );
              },
            ),
            const SizedBox(height: 20),

            // Log Out Button (or Sign In / Register if Guest)
            if (auth.isAuthenticated)
              CustomButton(
                text: l10n.tr('log_out'),
                variant: ButtonVariant.outline,
                icon: Icon(
                  Icons.logout,
                  color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                  size: 20,
                ),
                onPressed: () => _showLogoutDialog(context),
              )
            else
              CustomButton(
                text: l10n.tr('sign_in_register'),
                variant: ButtonVariant.primary,
                icon: const Icon(Icons.login, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
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

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: context.surfaceBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor, width: 0.8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: context.textPrimaryColor),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? badge,
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
            fontWeight: FontWeight.w700,
            color: context.textPrimaryColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 20, color: context.textSecondaryColor),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}


