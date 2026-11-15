import 'package:flutter/material.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/core/constants/app_constants.dart';
import 'package:homeplus/ui/core_widgets/app_logo.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('About HomePlus'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Column(
            children: [
            const SizedBox(height: 12),
            const AppLogo(
              iconSize: 52,
              showTagline: true,
              isHorizontal: false,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: context.mintBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Version ${AppConstants.appVersion} (Build 102)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'HomePlus is the premier digital retail platform for home appliances, electronics, and kitchen essentials. Designed to combine smart online discovery, side-by-side model comparison, and certified doorstep installation services, HomePlus empowers millions of homeowners to upgrade their homes with confidence.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: context.textSecondaryColor, height: 1.55),
            ),
            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surfaceBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                children: [
                  _buildAboutRow(context, 'Brand Tagline', 'Your Home. Our Priority.'),
                  Divider(color: context.dividerColor),
                  _buildAboutRow(context, 'Customer Support', AppConstants.supportEmail),
                  Divider(color: context.dividerColor),
                  _buildAboutRow(context, 'Toll Free Support', AppConstants.supportPhone),
                  Divider(color: context.dividerColor),
                  _buildAboutRow(context, 'Working Hours', AppConstants.supportWorkingHours),
                  Divider(color: context.dividerColor),
                  _buildAboutRow(context, 'Headquarters', AppConstants.showroomAddress),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              '© 2026 HomePlus Inc. All rights reserved.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildAboutRow(BuildContext context, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: context.textSecondaryColor)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              val,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


