import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_text_field.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/view_models/support_view_model.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supportVm = context.watch<SupportViewModel>();
    final faqs = supportVm.faqs;

    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxReadableWidth,
          child: Column(
          children: [
            CustomTextField(
              controller: _searchController,
              hintText: 'Search questions and help topics...',
              prefixIcon: Icon(Icons.search, color: context.textSecondaryColor),
              onChanged: (val) => supportVm.searchFaqs(val),
            ),
            const SizedBox(height: 16),

            ...faqs.map((f) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: context.surfaceBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor, width: 0.8),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Text(
                    f.question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimaryColor,
                    ),
                  ),
                  subtitle: Text(
                    f.category,
                    style: TextStyle(fontSize: 11, color: accentPrimary, fontWeight: FontWeight.w600),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(
                        f.answer,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondaryColor,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
        ),
      ),
    );
  }
}


