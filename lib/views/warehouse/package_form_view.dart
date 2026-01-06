import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/warehouse_controller.dart';
import '../../models/warehouse_order.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';

class PackageFormView extends StatefulWidget {
  const PackageFormView({super.key});

  @override
  State<PackageFormView> createState() => _PackageFormViewState();
}

class _PackageFormViewState extends State<PackageFormView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _materialCostController = TextEditingController();

  String _productType = 'General goods';
  String _transportMode = 'Van';

  WarehouseController get controller => Get.find<WarehouseController>();

  @override
  void dispose() {
    _weightController.dispose();
    _distanceController.dispose();
    _materialCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? orderId = Get.arguments as String?;
    final WarehouseOrder? order = controller.getOrderById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Packaging inputs')),
        body: const Center(child: Text('Order not available anymore.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Packaging inputs')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderContextCard(order: order),
              const SizedBox(height: 20),
              const Text(
                'Tell us about this package',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'We will use these details to tailor packaging suggestions.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 18),
              _buildNumberField(
                controller: _weightController,
                label: 'Package weight',
                hint: 'e.g. 2.5',
                suffix: 'kg',
                icon: Icons.scale_rounded,
              ),
              const SizedBox(height: 14),
              _buildDropdownField(
                label: 'Product type',
                value: _productType,
                icon: Icons.inventory_2_rounded,
                items: const [
                  'Fragile / glass',
                  'Electronics',
                  'Perishable',
                  'Apparel',
                  'General goods',
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _productType = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              _buildNumberField(
                controller: _distanceController,
                label: 'Delivery distance',
                hint: 'e.g. 15',
                suffix: 'km',
                icon: Icons.route_rounded,
              ),
              const SizedBox(height: 14),
              _buildDropdownField(
                label: 'Transport mode',
                value: _transportMode,
                icon: Icons.local_shipping_rounded,
                items: const [
                  'Bike',
                  'Van',
                  'Truck',
                  'Air freight',
                  'Sea freight',
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _transportMode = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              _buildNumberField(
                controller: _materialCostController,
                label: 'Material cost budget',
                hint: 'e.g. 4.00',
                suffix: '\$',
                icon: Icons.account_balance_wallet_rounded,
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'See packaging suggestions',
                icon: Icons.auto_awesome_rounded,
                onTap: () => _submit(order),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      validator: (value) => _validateNumber(value, label.toLowerCase()),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed <= 0) {
      return 'Must be greater than zero';
    }
    return null;
  }

  void _submit(WarehouseOrder order) {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final args = {
      'orderId': order.id,
      'packageWeight': _weightController.text.trim(),
      'productType': _productType,
      'deliveryDistance': _distanceController.text.trim(),
      'transportMode': _transportMode,
      'materialCost': _materialCostController.text.trim(),
    };

    Get.toNamed(Routes.packageSuggestion, arguments: args);
  }
}

class _OrderContextCard extends StatelessWidget {
  const _OrderContextCard({required this.order});

  final WarehouseOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '#${order.id}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            order.itemName.isEmpty ? 'No item name' : order.itemName,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

