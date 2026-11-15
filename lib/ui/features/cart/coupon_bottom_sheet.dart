import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/domain/models/models.dart';

class CouponBottomSheet extends StatefulWidget {
  const CouponBottomSheet({super.key});

  @override
  State<CouponBottomSheet> createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<CouponBottomSheet> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 40,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Discount Coupons',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter a promo code or select from available store vouchers below.',
            style: TextStyle(fontSize: 13, color: context.textSecondaryColor),
          ),
          const SizedBox(height: 18),

          // Code Input with Apply button
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.surfaceBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.borderColor, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'Enter coupon code',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  onPressed: () async {
                    if (_codeController.text.trim().isEmpty) return;
                    final success = await cartVm.applyCoupon(_codeController.text.trim());
                    if (success && context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coupon applied successfully!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          if (cartVm.couponError != null) ...[
            const SizedBox(height: 8),
            Text(
              cartVm.couponError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),

          Text(
            'Available Coupons',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 10),

          // Available coupons list
          FutureBuilder<List<Coupon>>(
            future: cartVm.getAvailableCoupons(),
            builder: (context, snapshot) {
              final coupons = snapshot.data ?? [];
              return Column(
                children: coupons.map((c) {
                  final isApplied = cartVm.appliedCoupon?.code == c.code;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isApplied ? context.mintLightBg : context.surfaceBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isApplied ? AppColors.primary : context.borderColor,
                        width: isApplied ? 1.5 : 1,
                      ),
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
                            Icons.card_giftcard,
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
                                c.code,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isApplied)
                          TextButton(
                            onPressed: () => cartVm.removeCoupon(),
                            child: const Text('Remove', style: TextStyle(color: AppColors.error, fontSize: 13)),
                          )
                        else
                          TextButton(
                            onPressed: () async {
                              final ok = await cartVm.applyCoupon(c.code);
                              if (ok && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}


