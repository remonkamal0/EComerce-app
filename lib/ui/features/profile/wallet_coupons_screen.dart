import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_text_field.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';

class WalletCouponsScreen extends StatefulWidget {
  const WalletCouponsScreen({super.key});

  @override
  State<WalletCouponsScreen> createState() => _WalletCouponsScreenState();
}

class _WalletCouponsScreenState extends State<WalletCouponsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _couponInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _couponInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final cartVm = context.watch<CartViewModel>();
    final user = auth.currentUser;

    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Wallet & Coupons'),
      ),
      body: SingleChildScrollView(
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Column(
            children: [
            // Wallet Balance Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'HomePlus Store Credit',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '\$${user?.walletBalance.toStringAsFixed(2) ?? "50.00"}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use store credit for instant discount at checkout',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Coupon Code Input Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _couponInput,
                      hintText: 'Enter coupon code',
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_couponInput.text.trim().isEmpty) return;
                        final ok = await cartVm.applyCoupon(_couponInput.text.trim());
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok ? 'Coupon activated!' : 'Invalid coupon code.'),
                              backgroundColor: ok ? AppColors.primary : AppColors.error,
                            ),
                          );
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tabs for Active vs Used/Expired
            TabBar(
              controller: _tabController,
              indicatorColor: accentPrimary,
              labelColor: accentPrimary,
              unselectedLabelColor: context.textSecondaryColor,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Active Coupons (4)'),
                Tab(text: 'Expired / Used (2)'),
              ],
            ),

            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildActiveCoupons(context),
                  _buildExpiredCoupons(context),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildActiveCoupons(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;

    return FutureBuilder<List<Coupon>>(
      future: cartVm.getAvailableCoupons(),
      builder: (context, snapshot) {
        final coupons = snapshot.data ?? [];

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: coupons.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final c = coupons[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.mintLightBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.isDarkMode ? context.borderColor : AppColors.mintDark,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: context.cardBg, shape: BoxShape.circle),
                    child: Icon(Icons.discount_outlined, color: accentPrimary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.code,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: accentPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(c.description, style: TextStyle(fontSize: 12, color: context.textSecondaryColor)),
                        const SizedBox(height: 4),
                        Text(
                          'Min spend: \$${c.minSpend.toInt()}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(64, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final ok = await cartVm.applyCoupon(c.code);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'Coupon ${c.code} applied!' : cartVm.couponError ?? 'Failed to apply'),
                            backgroundColor: ok ? AppColors.primary : AppColors.error,
                          ),
                        );
                      }
                    },
                    child: const Text('Apply', style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExpiredCoupons(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildExpiredCard(context, 'SUMMER2025', '\$25 Off Summer Special', 'Expired on Sep 30, 2025'),
        _buildExpiredCard(context, 'BLACKFRIDAY', '30% Off Black Friday Appliances', 'Used on Nov 28, 2025'),
      ],
    );
  }

  Widget _buildExpiredCard(BuildContext context, String code, String desc, String note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surfaceBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: AppColors.textMuted, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.lineThrough,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(desc, style: TextStyle(fontSize: 12, color: context.textSecondaryColor)),
                Text(note, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


