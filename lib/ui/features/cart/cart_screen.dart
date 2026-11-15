import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/localization/app_localizations.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/appliance_image.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/empty_state_view.dart';
import 'package:homeplus/ui/core_widgets/product_price_view.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/staggered_list_animation.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/ui/view_models/wishlist_view_model.dart';
import '../auth/sign_in_screen.dart';
import '../checkout/delivery_address_screen.dart';
import 'coupon_bottom_sheet.dart';

class CartScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const CartScreen({super.key, this.onNavigateTab});

  void _showClearConfirmation(BuildContext context) {
    final cartVm = context.read<CartViewModel>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.tr('clear_cart_title')),
        content: Text(ctx.l10n.tr('clear_cart_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.l10n.tr('cancel')),
          ),
          TextButton(
            onPressed: () {
              cartVm.clearCart();
              Navigator.of(ctx).pop();
            },
            child: Text(
              ctx.l10n.tr('clear_all'),
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _openCouponSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CouponBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();
    final wishlistVm = context.read<WishlistViewModel>();

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(context.tr('shopping_cart')),
        actions: [
          if (!cartVm.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearConfirmation(context),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cartVm.isEmpty
          ? EmptyStateView(
              icon: Icons.shopping_cart_outlined,
              title: context.tr('cart_empty_title'),
              message: context.tr('cart_empty_msg'),
              buttonText: context.tr('discover_products'),
              onButtonPressed: () {
                if (onNavigateTab != null) {
                  onNavigateTab!(0); // Switch to Home tab
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 840;
                final hPad = ResponsiveLayout.horizontalPadding(
                  constraints.maxWidth,
                );

                final itemsList = StaggeredListLimiter(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartVm.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartVm.items[index];
                      final p = item.product;

                      return StaggeredListItem(
                        index: index,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: context.borderColor,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Product Image
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: ApplianceImage(
                                  imageUrl: p.images.isNotEmpty
                                      ? p.images.first
                                      : '',
                                  borderRadius: 12,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            context.l10n.productName(
                                              p.id,
                                              p.name,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: context.textPrimaryColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        // Save to wishlist heart icon
                                        GestureDetector(
                                          onTap: () {
                                            wishlistVm.toggleWishlist(p);
                                            final l10nR = context.l10nRead;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  l10nR.savedToWishlistMsg(
                                                    l10nR.productName(
                                                      p.id,
                                                      p.name,
                                                    ),
                                                  ),
                                                ),
                                                backgroundColor:
                                                    context.actionColor,
                                                duration: const Duration(
                                                  seconds: 1,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            Icons.favorite_border,
                                            size: 20,
                                            color: context.textSecondaryColor,
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: context.isArabic
                                              ? 'حذف المنتج'
                                              : 'Remove item',
                                          onPressed: () =>
                                              cartVm.removeFromCart(p.id),
                                          icon: Icon(
                                            Icons.delete_outline,
                                            size: 20,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),

                                    // Price & Stepper Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: ProductPriceView(
                                            price: p.price,
                                            originalPrice: p.originalPrice,
                                            isCompact: true,
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Quantity Controls (- 1 +)
                                        Container(
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: context.surfaceBg,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: context.borderColor,
                                              width: 0.8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  cartVm.updateQuantity(
                                                    p.id,
                                                    item.quantity - 1,
                                                  );
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                  ),
                                                  child: Icon(
                                                    Icons.remove,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${item.quantity}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      context.textPrimaryColor,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  cartVm.updateQuantity(
                                                    p.id,
                                                    item.quantity + 1,
                                                  );
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );

                final summarySection = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CartCouponEntry(onBrowse: () => _openCouponSheet(context)),
                    const SizedBox(height: 20),

                    // Cost Breakdown Card (Mockup Match: Subtotal, Discount, Delivery Fee, Total)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.surfaceBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            context,
                            context.tr('subtotal'),
                            '\$${cartVm.subtotal.toInt()}',
                          ),
                          if (cartVm.couponDiscount > 0) ...[
                            const SizedBox(height: 10),
                            _buildSummaryRow(
                              context,
                              context.tr('discount'),
                              '- \$${cartVm.couponDiscount.toInt()}',
                              textColor: context.themeAccent,
                            ),
                          ],
                          const SizedBox(height: 10),
                          _buildSummaryRow(
                            context,
                            context.tr('delivery_fee'),
                            '\$${cartVm.deliveryFee.toInt()}',
                          ),
                          if (cartVm.installationFee > 0) ...[
                            const SizedBox(height: 10),
                            _buildSummaryRow(
                              context,
                              context.tr('installation'),
                              '\$${cartVm.installationFee.toInt()}',
                            ),
                          ],
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                context.tr('total'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Builder(
                                  builder: (ctx) {
                                    final auth = ctx.watch<AuthViewModel>();
                                    if (!auth.isAuthenticated) {
                                      return Text(
                                        ctx.l10n.tr('sign_in_for_price'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primary,
                                        ),
                                      );
                                    }
                                    return Text(
                                      '\$${cartVm.total.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Proceed to Checkout Button
                    Builder(
                      builder: (ctx) {
                        final auth = ctx.watch<AuthViewModel>();
                        return CustomButton(
                          text: auth.isAuthenticated
                              ? ctx.l10n.tr('proceed_to_checkout')
                              : ctx.l10n.tr('sign_in_checkout_btn'),
                          icon: const Icon(
                            Icons.lock_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            if (!auth.isAuthenticated) {
                              Navigator.of(ctx).push(
                                MaterialPageRoute(
                                  builder: (_) => const SignInScreen(),
                                ),
                              );
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ctx.l10nRead.tr('sign_in_checkout_snack'),
                                  ),
                                  backgroundColor: context.actionColor,
                                ),
                              );
                              return;
                            }
                            Navigator.of(ctx).push(
                              MaterialPageRoute(
                                builder: (_) => const DeliveryAddressScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                );

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                  child: ResponsiveConstrainedBox(
                    maxWidth: isWide ? 1140 : 680,
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: itemsList),
                              const SizedBox(width: 24),
                              Expanded(flex: 4, child: summarySection),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              itemsList,
                              const SizedBox(height: 16),
                              summarySection,
                              const SizedBox(height: 32),
                            ],
                          ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: textColor ?? context.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}

class _CartCouponEntry extends StatefulWidget {
  const _CartCouponEntry({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  State<_CartCouponEntry> createState() => _CartCouponEntryState();
}

class _CartCouponEntryState extends State<_CartCouponEntry> {
  final _controller = TextEditingController();
  bool _applying = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _controller.text.trim();
    if (_applying || code.isEmpty) return;

    final cart = context.read<CartViewModel>();
    setState(() {
      _applying = true;
      _error = null;
    });
    try {
      final applied = await cart.applyCoupon(code);
      if (!mounted) return;
      if (applied) {
        if (_controller.text.trim() == code) _controller.clear();
        FocusScope.of(context).unfocus();
      } else {
        _error = cart.couponError;
      }
    } catch (_) {
      if (!mounted) return;
      _error = context.isArabic
          ? 'تعذر تطبيق الكوبون'
          : 'Unable to apply coupon';
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();
    final arabic = context.isArabic;
    final coupon = cart.appliedCoupon;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            enabled: !_applying,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _apply(),
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              labelText: arabic ? 'كود الخصم' : 'Coupon code',
              prefixIcon: const Icon(Icons.local_offer_outlined),
              errorText: _error,
              errorMaxLines: 3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            children: [
              FilledButton(
                onPressed: _applying || _controller.text.trim().isEmpty
                    ? null
                    : _apply,
                child: Text(arabic ? 'تطبيق' : 'Apply'),
              ),
              TextButton(
                onPressed: _applying ? null : widget.onBrowse,
                child: Text(arabic ? 'الكوبونات المتاحة' : 'Available coupons'),
              ),
            ],
          ),
          if (coupon != null) ...[
            const SizedBox(height: 8),
            Text(
              context.l10n.couponAppliedMsg(
                coupon.code,
                cart.couponDiscount.toInt(),
              ),
              style: TextStyle(
                color: context.themeAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                onPressed: _applying
                    ? null
                    : () {
                        cart.removeCoupon();
                        setState(() => _error = null);
                      },
                child: Text(arabic ? 'إزالة الكوبون' : 'Remove coupon'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
