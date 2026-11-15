import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'package:homeplus/ui/view_models/orders_view_model.dart';
import 'order_success_screen.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final Address selectedAddress;
  final String deliveryMethod;
  final String paymentMethod;
  final bool hasInstallation;

  const PaymentProcessingScreen({
    super.key,
    required this.selectedAddress,
    required this.deliveryMethod,
    required this.paymentMethod,
    this.hasInstallation = false,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isProcessing = true;
  bool _isBankTransfer = false;
  OrderModel? _placedOrder;

  @override
  void initState() {
    super.initState();
    _isBankTransfer = widget.paymentMethod == 'Bank Transfer';
    _processPayment();
  }

  Future<void> _processPayment() async {
    final cartVm = context.read<CartViewModel>();
    final ordersVm = context.read<OrdersViewModel>();

    // Create the order in orders repository
    final order = await ordersVm.createAndPlaceOrder(
      items: cartVm.items,
      address: widget.selectedAddress,
      deliveryMethod: widget.deliveryMethod,
      paymentMethod: widget.paymentMethod,
      subtotal: cartVm.subtotal,
      discount: cartVm.couponDiscount,
      deliveryFee: cartVm.deliveryFee,
      installationFee: cartVm.installationFee,
      total: cartVm.total,
      hasInstallation: widget.hasInstallation,
    );

    _placedOrder = order;

    if (_isBankTransfer) {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      return;
    }

    // Normal authorization delay
    await Future.delayed(const Duration(milliseconds: 1800));

    // Clear cart once order is placed
    await cartVm.clearCart();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(order: order),
        ),
      );
    }
  }

  void _completeBankTransfer() async {
    final cartVm = context.read<CartViewModel>();
    await cartVm.clearCart();

    if (mounted && _placedOrder != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(order: _placedOrder!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
    if (_isBankTransfer && !_isProcessing) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(title: const Text('Bank Transfer Instructions')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transfer Funds to HomePlus',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Please transfer the exact order amount using the reference below. Your order will be dispatched upon receipt.',
                style: TextStyle(fontSize: 14, color: context.textSecondaryColor),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surfaceBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor),
                ),
                child: Column(
                  children: [
                    _buildBankRow(context, 'Bank Name', 'Commercial International Bank (CIB)'),
                    Divider(color: context.dividerColor),
                    _buildBankRow(context, 'Account Name', 'HomePlus Retail Egypt Ltd.'),
                    Divider(color: context.dividerColor),
                    _buildBankRow(context, 'IBAN', 'EG38 0010 0001 0000 0123 4567 890'),
                    Divider(color: context.dividerColor),
                    _buildBankRow(context, 'Swift / BIC', 'CIBEEGCX'),
                    Divider(color: context.dividerColor),
                    _buildBankRow(context, 'Order Ref', '#${_placedOrder?.id ?? "HP123456"}'),
                  ],
                ),
              ),
              const Spacer(),

              CustomButton(
                text: 'I Have Completed the Transfer',
                onPressed: _completeBankTransfer,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: context.mintBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      valueColor: AlwaysStoppedAnimation<Color>(accentPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Authorizing Payment...',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: context.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Connecting securely with your payment provider. Please do not close or refresh this page.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: context.textSecondaryColor, height: 1.4),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: context.mintLightBg,
                  borderRadius: BorderRadius.circular(20),
                  border: context.isDarkMode ? Border.all(color: context.borderColor) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock, size: 16, color: accentPrimary),
                    const SizedBox(width: 6),
                    Text(
                      widget.paymentMethod,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accentPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: context.textSecondaryColor)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimaryColor)),
        ],
      ),
    );
  }
}


