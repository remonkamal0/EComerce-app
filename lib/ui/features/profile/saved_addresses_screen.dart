import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/empty_state_view.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/ui/core_widgets/staggered_list_animation.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';
import '../checkout/add_edit_address_screen.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Address address,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          backgroundColor: dialogContext.cardBg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          scrollable: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.delete_outline, color: colors.error),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Delete address?'),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remove this address from your saved addresses?',
                style: TextStyle(color: dialogContext.textSecondaryColor),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: dialogContext.surfaceBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: dialogContext.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(address.formattedAddress),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(88, 44)),
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
                minimumSize: const Size(88, 44),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthViewModel>().deleteAddress(address.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final addresses = auth.currentUser?.addresses ?? [];

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(title: const Text('Saved Addresses')),
      body: addresses.isEmpty
          ? EmptyStateView(
              icon: Icons.location_off_outlined,
              title: 'No Saved Addresses',
              message:
                  'Add your home or office address for fast, one-tap checkout.',
              buttonText: 'Add New Address',
              onButtonPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddEditAddressScreen(),
                  ),
                );
              },
            )
          : ResponsiveConstrainedBox(
              maxWidth: ResponsiveLayout.maxReadableWidth,
              child: StaggeredListLimiter(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: addresses.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return StaggeredListItem(
                      index: index,
                      child: _SavedAddressCard(
                        address: address,
                        onEdit: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditAddressScreen(addressToEdit: address),
                          ),
                        ),
                        onDelete: () =>
                            _showDeleteConfirmation(context, address),
                        onSetDefault: () => auth.setDefaultAddress(address.id),
                      ),
                    );
                  },
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ResponsiveConstrainedBox(
            maxWidth: ResponsiveLayout.maxFormWidth,
            child: CustomButton(
              text: 'Add New Address',
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AddEditAddressScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedAddressCard extends StatelessWidget {
  const _SavedAddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final accent = context.themeAccent;
    final secondary = context.textSecondaryColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: address.isDefault
              ? accent.withValues(alpha: 0.55)
              : context.borderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    switch (address.label.toLowerCase()) {
                      'home' => Icons.home_outlined,
                      'work' => Icons.business_outlined,
                      _ => Icons.place_outlined,
                    },
                    size: 21,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.label,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (address.isDefault)
                        Text(
                          'Default address',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit address',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 19),
                ),
                IconButton(
                  tooltip: 'Delete address',
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: context.dividerColor),
            const SizedBox(height: 12),
            Text(
              address.recipientName,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(address.formattedAddress, style: TextStyle(color: secondary)),
            const SizedBox(height: 6),
            Text(
              address.phone,
              textDirection: TextDirection.ltr,
              style: TextStyle(color: secondary),
            ),
            if (!address.isDefault) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onSetDefault,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Set as Default Address'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
