import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/core/constants/app_constants.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/custom_text_field.dart';
import 'package:homeplus/ui/core_widgets/lottie_success_view.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/view_models/support_view_model.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _subject = 'Order Inquiry';
  final _orderIdController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  final List<String> _subjects = [
    'Order Inquiry',
    'Product Information',
    'Warranty Claim',
    'Delivery & Installation',
    'Feedback & Suggestions',
  ];

  @override
  void dispose() {
    _orderIdController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    await context.read<SupportViewModel>().submitContactMessage(
      subject: _subject,
      message: _messageController.text.trim(),
      orderId: _orderIdController.text.trim().isNotEmpty ? _orderIdController.text.trim() : null,
    );
    setState(() => _isSending = false);

    if (mounted) {
      showLottieSuccessDialog(
        context,
        title: 'Message Sent!',
        message: 'Thank you for reaching out to HomePlus support. A customer care representative will respond to your email within 2-4 business hours.',
        buttonText: 'Done',
        onConfirm: () => Navigator.of(context).pop(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Contact Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Channels Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.mintLightBg,
                  borderRadius: BorderRadius.circular(16),
                  border: context.isDarkMode ? Border.all(color: context.borderColor) : null,
                ),
                child: Column(
                  children: [
                    _buildContactRow(context, Icons.phone_outlined, 'Call Us', AppConstants.supportPhone),
                    Divider(color: context.dividerColor),
                    _buildContactRow(context, Icons.email_outlined, 'Email Support', AppConstants.supportEmail),
                    Divider(color: context.dividerColor),
                    _buildContactRow(context, Icons.access_time_outlined, 'Hours', AppConstants.supportWorkingHours),
                    Divider(color: context.dividerColor),
                    _buildContactRow(context, Icons.location_on_outlined, 'Showroom', AppConstants.showroomAddress),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Send Us a Message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.textPrimaryColor),
              ),
              const SizedBox(height: 12),

              // Subject Dropdown
              Text(
                'Inquiry Subject',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimaryColor),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: context.surfaceBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.borderColor),
                ),
                child: DropdownButton<String>(
                  value: _subject,
                  isExpanded: true,
                  dropdownColor: context.cardBg,
                  style: TextStyle(fontSize: 14, color: context.textPrimaryColor),
                  underline: const SizedBox.shrink(),
                  items: _subjects.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s, style: TextStyle(fontSize: 14, color: context.textPrimaryColor)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _subject = val);
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Order ID
              CustomTextField(
                controller: _orderIdController,
                labelText: 'Order Number (Optional)',
                hintText: 'e.g., HP123456',
              ),
              const SizedBox(height: 14),

              // Message
              CustomTextField(
                controller: _messageController,
                labelText: 'Message',
                hintText: 'How can our team help you?',
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your message' : null,
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Send Message',
                isLoading: _isSending,
                onPressed: _submit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: context.isDarkMode ? AppColors.primaryLight : AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textSecondaryColor)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.textPrimaryColor)),
        ],
      ),
    );
  }
}


