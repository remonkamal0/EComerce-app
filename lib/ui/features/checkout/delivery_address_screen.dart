import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import 'package:homeplus/ui/view_models/cart_view_model.dart';
import 'add_edit_address_screen.dart';
import 'payment_methods_screen.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  String? _selectedAddressId;
  String _selectedDeliverySpeed = 'standard'; // 'standard', 'express'
  bool _includeInstallation = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthViewModel>();
    final addresses = auth.currentUser?.addresses ?? [];
    if (addresses.isNotEmpty) {
      _selectedAddressId = addresses.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final cartVm = context.watch<CartViewModel>();
    final addresses = auth.currentUser?.addresses ?? [];
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Delivery & Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Section 1: Delivery Address
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Delivery Address',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimaryColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final newAddr = await Navigator.of(context).push<Address>(
                      MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
                    );
                    if (newAddr != null) {
                      setState(() => _selectedAddressId = newAddr.id);
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add New'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...addresses.map((addr) {
              final isSelected = _selectedAddressId == addr.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? context.mintLightBg : context.surfaceBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? accentPrimary : context.borderColor,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio<String>(
                      value: addr.id,
                      groupValue: _selectedAddressId,
                      activeColor: accentPrimary,
                      onChanged: (val) => setState(() => _selectedAddressId = val),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                addr.recipientName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: context.cardBg,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: context.borderColor),
                                ),
                                child: Text(
                                  addr.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            addr.formattedAddress,
                            style: TextStyle(fontSize: 13, color: context.textSecondaryColor, height: 1.3),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            addr.phone,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 18, color: context.textSecondaryColor),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => AddEditAddressScreen(addressToEdit: addr)),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Divider(color: context.dividerColor),

            // Section 2: Delivery Speed
            Text(
              'Delivery Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),

            _buildOptionCard(
              context: context,
              id: 'standard',
              title: 'Standard Delivery',
              subtitle: 'Estimated 2-3 business days',
              price: '\$20',
              isSelected: _selectedDeliverySpeed == 'standard',
              onTap: () {
                setState(() => _selectedDeliverySpeed = 'standard');
                cartVm.setDeliveryFee(20.0);
              },
            ),
            const SizedBox(height: 10),
            _buildOptionCard(
              context: context,
              id: 'express',
              title: 'Express Doorstep Delivery',
              subtitle: 'Next-day priority delivery',
              price: '\$35',
              isSelected: _selectedDeliverySpeed == 'express',
              onTap: () {
                setState(() => _selectedDeliverySpeed = 'express');
                cartVm.setDeliveryFee(35.0);
              },
            ),
            const SizedBox(height: 16),
            Divider(color: context.dividerColor),

            // Section 3: Professional Installation
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _includeInstallation ? context.mintLightBg : context.surfaceBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _includeInstallation ? accentPrimary : context.borderColor,
                  width: _includeInstallation ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _includeInstallation,
                    activeColor: accentPrimary,
                    onChanged: (val) {
                      final active = val ?? false;
                      setState(() => _includeInstallation = active);
                      cartVm.setInstallationFee(active ? 25.0 : 0.0);
                    },
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Professional Installation (+\$25)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Certified technician setup, leveling & connection',
                          style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ResponsiveConstrainedBox(
            maxWidth: ResponsiveLayout.maxFormWidth,
            child: CustomButton(
              text: 'Continue to Payment',
              onPressed: () {
                final selectedAddr = addresses.firstWhere(
                  (a) => a.id == _selectedAddressId,
                  orElse: () => addresses.first,
                );

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PaymentMethodsScreen(
                      selectedAddress: selectedAddr,
                      deliveryMethod: _selectedDeliverySpeed == 'express' ? 'Express Delivery' : 'Standard Delivery',
                      hasInstallation: _includeInstallation,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String id,
    required String title,
    required String subtitle,
    required String price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? context.mintLightBg : context.surfaceBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentPrimary : context.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              activeColor: accentPrimary,
              onChanged: (_) => onTap(),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: context.textSecondaryColor),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: accentPrimary),
            ),
          ],
        ),
      ),
    );
  }
}


