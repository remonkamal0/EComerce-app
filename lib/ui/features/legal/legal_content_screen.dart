import 'package:flutter/material.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';

class LegalContentScreen extends StatelessWidget {
  final String title;

  const LegalContentScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
            ),
            const SizedBox(height: 6),
            const Text(
              'Last Updated: April 2026',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),

            _buildSection(
              context,
              '1. Introduction & Acceptance',
              'Welcome to HomePlus ("we", "our", or "us"). By accessing or using the HomePlus mobile application, you agree to be bound by these terms and conditions and all applicable regulations governing retail purchases of household electrical appliances and electronics.',
            ),
            _buildSection(
              context,
              '2. Genuine Products & Official Warranty',
              'HomePlus guarantees that all appliances, including refrigerators, cookers, washing machines, air conditioners, and consumer electronics, are 100% brand new, authentic, and sourced directly from authorized brand distributors. All products come with official manufacturer warranties ranging from 1 to 10 years depending on the specific appliance and motor/compressor.',
            ),
            _buildSection(
              context,
              '3. Ordering, Pricing & Availability',
              'All displayed prices include applicable taxes. We strive to maintain real-time stock levels, however in the rare event an appliance becomes unavailable after placement, HomePlus will notify you immediately with an expedited replacement or a full refund.',
            ),
            _buildSection(
              context,
              '4. Doorstep Delivery & Professional Installation',
              'Appliances are delivered to the recipient address provided at checkout. If professional installation is selected, certified technicians will safely unbox, level, test, and mount/connect the unit according to manufacturer standards. The customer is responsible for ensuring doorways and elevator dimensions accommodate the appliance size.',
            ),
            _buildSection(
              context,
              '5. 14-Day Return & Refund Guarantee',
              'You may request a return within 14 calendar days of receipt if the product is defective, damaged, or does not match specifications. Refunds can be credited instantly to your HomePlus Wallet or reversed to your original payment method.',
            ),
            _buildSection(
              context,
              '6. Privacy & Data Protection',
              'We respect your privacy and utilize enterprise-grade 256-bit SSL encryption to protect your personal details, saved delivery addresses, and payment data. We do not sell or share customer records with third-party marketers.',
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String heading, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(fontSize: 13, color: context.textSecondaryColor, height: 1.5),
          ),
        ],
      ),
    );
  }
}


