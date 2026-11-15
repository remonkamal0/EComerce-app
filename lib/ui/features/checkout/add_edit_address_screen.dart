import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homeplus/core/theme/app_colors.dart';
import 'package:homeplus/ui/core_widgets/custom_button.dart';
import 'package:homeplus/ui/core_widgets/custom_text_field.dart';
import 'package:homeplus/ui/core_widgets/responsive_layout.dart';
import 'package:homeplus/domain/models/models.dart';
import 'package:homeplus/ui/view_models/auth_view_model.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? addressToEdit;

  const AddEditAddressScreen({super.key, this.addressToEdit});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _areaController;
  late TextEditingController _streetController;
  late TextEditingController _buildingController;
  late TextEditingController _aptController;
  late TextEditingController _instructionsController;
  String _label = 'Home';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final a = widget.addressToEdit;
    _nameController = TextEditingController(text: a?.recipientName ?? 'Ahmed Mohamed');
    _phoneController = TextEditingController(text: a?.phone ?? '+20 100 123 4567');
    _cityController = TextEditingController(text: a?.city ?? 'Cairo');
    _areaController = TextEditingController(text: a?.area ?? 'Nasr City');
    _streetController = TextEditingController(text: a?.street ?? '123 Main Street');
    _buildingController = TextEditingController(text: a?.building ?? 'Building 14');
    _aptController = TextEditingController(text: a?.apartment ?? '4B');
    _instructionsController = TextEditingController(text: a?.instructions ?? '');
    _label = a?.label ?? 'Home';
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _aptController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final newAddr = Address(
      id: widget.addressToEdit?.id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}',
      recipientName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      city: _cityController.text.trim(),
      area: _areaController.text.trim(),
      street: _streetController.text.trim(),
      building: _buildingController.text.trim(),
      apartment: _aptController.text.trim(),
      instructions: _instructionsController.text.trim(),
      label: _label,
      isDefault: _isDefault,
    );

    final auth = context.read<AuthViewModel>();
    if (widget.addressToEdit != null) {
      auth.updateAddress(newAddr);
    } else {
      auth.addAddress(newAddr);
    }

    Navigator.of(context).pop(newAddr);
  }

  @override
  Widget build(BuildContext context) {
    final accentPrimary = context.isDarkMode ? AppColors.primaryLight : AppColors.primary;
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(widget.addressToEdit != null ? 'Edit Address' : 'Add New Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ResponsiveConstrainedBox(
          maxWidth: ResponsiveLayout.maxFormWidth,
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address Type Chips
              Text(
                'Address Label',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: context.textPrimaryColor),
              ),
              const SizedBox(height: 8),
              Row(
                children: ['Home', 'Work', 'Other'].map((lbl) {
                  final isSelected = _label == lbl;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(lbl),
                      backgroundColor: context.surfaceBg,
                      selectedColor: context.mintBg,
                      side: BorderSide(color: isSelected ? accentPrimary : context.borderColor),
                      selected: isSelected,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? accentPrimary : context.textPrimaryColor,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _label = lbl);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _nameController,
                labelText: 'Recipient Name',
                hintText: 'Full Name',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone Number',
                hintText: '+20 100 123 4567',
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      labelText: 'City / Governorate',
                      hintText: 'Cairo',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _areaController,
                      labelText: 'Area / District',
                      hintText: 'Nasr City',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _streetController,
                labelText: 'Street Address',
                hintText: '123 Main Street',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _buildingController,
                      labelText: 'Building Name / No.',
                      hintText: 'Building 14',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _aptController,
                      labelText: 'Apartment / Floor',
                      hintText: '4B',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _instructionsController,
                labelText: 'Delivery Instructions (Optional)',
                hintText: 'e.g., Near landmark, call upon arrival',
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              SwitchListTile(contentPadding: EdgeInsets.zero, activeThumbColor: AppColors.primary,
                title: const Text('Set as Default Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Save Address',
                onPressed: _save,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        ),
      ),
    );
  }
}



