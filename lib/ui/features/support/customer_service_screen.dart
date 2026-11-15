import 'package:flutter/material.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'live_chat_screen.dart';
import 'faq_screen.dart';
import 'contact_us_screen.dart';
import '../orders/my_orders_screen.dart';
import '../legal/legal_content_screen.dart';

class CustomerServiceScreen extends StatelessWidget {
  const CustomerServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(l10n.tr('customer_services')),
        actions: [
          IconButton(
            icon: const Icon(Icons.headphones_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LiveChatScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Column(
            children: [
            // Hero Card with Headphones (Mockup Match)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.mintLightBg,
                borderRadius: BorderRadius.circular(24),
                border: context.isDarkMode ? Border.all(color: context.borderColor) : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ApplianceImage(
                      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&auto=format&fit=crop&q=80',
                      borderRadius: 16,
                      fit: BoxFit.contain,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tr('here_to_help'),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimaryColor,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.tr('support_sub'),
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondaryColor,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search for help field
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FaqScreen()),
                );
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: context.surfaceBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.borderColor, width: 0.8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 20, color: context.textSecondaryColor),
                    const SizedBox(width: 10),
                    Text(
                      l10n.tr('search_help'),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Support Menu Options (Mockup Match)
            _buildSupportTile(
              icon: Icons.help_outline,
              title: l10n.tr('faqs'),
              subtitle: l10n.tr('faqs_sub'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FaqScreen()),
                );
              },
            ),
            _buildSupportTile(
              icon: Icons.assignment_return_outlined,
              title: l10n.tr('returns_refunds'),
              subtitle: l10n.tr('returns_sub_14'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LegalContentScreen(title: context.l10nRead.tr('returns_policy_title')),
                  ),
                );
              },
            ),
            _buildSupportTile(
              icon: Icons.local_shipping_outlined,
              title: l10n.tr('track_your_order'),
              subtitle: l10n.tr('track_sub_live'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                );
              },
            ),
            _buildSupportTile(
              icon: Icons.email_outlined,
              title: l10n.tr('contact_us'),
              subtitle: l10n.tr('contact_sub_care'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                );
              },
            ),
            _buildSupportTile(
              icon: Icons.headset_mic_outlined,
              title: l10n.tr('live_chat'),
              subtitle: l10n.tr('live_chat_sub'),
              trailingBadge: l10n.tr('online'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LiveChatScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Mint Bottom Banner: "Need instant help? Start a live chat now ->" (Mockup Match)
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LiveChatScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.mintBg,
                  borderRadius: BorderRadius.circular(18),
                  border: context.isDarkMode ? Border.all(color: context.borderColor) : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tr('need_instant_help'),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.tr('start_live_chat'),
                            style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingBadge,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: context.surfaceBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderColor, width: 0.8),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentPrimary, size: 20),
            ),
            title: Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingBadge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trailingBadge,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18, color: context.textSecondaryColor),
              ],
            ),
            onTap: onTap,
          ),
        );
      },
    );
  }
}


