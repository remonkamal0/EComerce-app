import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/custom_text_field.dart';
import 'package:homeplus/ui/core_widgets/lottie_success_view.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/view_models/orders_view_model.dart';

class ReturnRequestScreen extends StatefulWidget {
  final OrderModel order;

  const ReturnRequestScreen({super.key, required this.order});

  @override
  State<ReturnRequestScreen> createState() => _ReturnRequestScreenState();
}

class _ReturnRequestScreenState extends State<ReturnRequestScreen> {
  final _notesController = TextEditingController();
  String _selectedReason = 'Defective / Not working properly';
  String _refundMethod = 'HomePlus Wallet (Instant Credit)';
  bool _photoAttached = false;
  bool _submitted = false;

  final List<String> _reasons = [
    'Defective / Not working properly',
    'Damaged in transit / Scratched',
    'Wrong item delivered',
    'Missing accessories or parts',
    'Does not match specifications',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submitReturn() {
    context.read<OrdersViewModel>().requestReturn(
      widget.order.id,
      _selectedReason,
      _refundMethod,
      _notesController.text.trim(),
    );
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
    if (_submitted) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(title: const Text('Return Request Submitted')),
        body: Center(
          child: ResponsiveConstrainedBox(
            maxWidth: ResponsiveLayout.maxFormWidth,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LottieSuccessView(size: 150),
                  const SizedBox(height: 16),
                  Text(
                    'Request Submitted Successfully!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Return Ticket #RET-${widget.order.id} has been created. Our inspection team will contact you within 24 hours to schedule doorstep pickup.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: context.textSecondaryColor, height: 1.45),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Back to Orders',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Request Return'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(
              'Select Return Reason',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
            ),
            const SizedBox(height: 8),

            ..._reasons.map((r) {
              return RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                activeColor: accentPrimary,
                title: Text(r, style: TextStyle(fontSize: 14, color: context.textPrimaryColor)),
                value: r,
                groupValue: _selectedReason,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedReason = val);
                },
              );
            }),
            const SizedBox(height: 16),
            Divider(color: context.dividerColor),

            // Explanation
            Text(
              'Additional Details (Optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _notesController,
              hintText: 'Describe the issue or defect in detail...',
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Photo attachment simulation
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _photoAttached = !_photoAttached);
              },
              icon: Icon(
                _photoAttached ? Icons.check_circle : Icons.camera_alt_outlined,
                color: _photoAttached ? accentPrimary : context.textSecondaryColor,
              ),
              label: Text(
                _photoAttached ? '1 Photo Attached (damage_proof.jpg)' : 'Attach Photos of Damage (Optional)',
                style: TextStyle(
                  color: _photoAttached ? accentPrimary : context.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: context.dividerColor),

            // Refund Method
            Text(
              'Preferred Refund Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
            ),
            const SizedBox(height: 8),

            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              activeColor: accentPrimary,
              title: Text('HomePlus Wallet (Instant Store Credit)', style: TextStyle(fontSize: 14, color: context.textPrimaryColor)),
              subtitle: Text('Available immediately for your next purchase', style: TextStyle(fontSize: 12, color: context.textSecondaryColor)),
              value: 'HomePlus Wallet (Instant Credit)',
              groupValue: _refundMethod,
              onChanged: (val) {
                if (val != null) setState(() => _refundMethod = val);
              },
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              activeColor: accentPrimary,
              title: Text('Original Payment Method', style: TextStyle(fontSize: 14, color: context.textPrimaryColor)),
              subtitle: Text('Processed in 3-5 business days to your bank/card', style: TextStyle(fontSize: 12, color: context.textSecondaryColor)),
              value: 'Original Payment Method',
              groupValue: _refundMethod,
              onChanged: (val) {
                if (val != null) setState(() => _refundMethod = val);
              },
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
              text: 'Submit Return Request',
              onPressed: _submitReturn,
            ),
          ),
        ),
      ),
    );
  }
}


