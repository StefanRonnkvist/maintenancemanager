import 'package:flutter/material.dart';

import '../models/spare_part_record.dart';

class SparePartsForm extends StatelessWidget {
  const SparePartsForm({
    required this.oemPartNumber,
    required this.oemDescription,
    required this.vendorPartNumber,
    required this.vendorDescription,
    required this.serialNumber,
    required this.vendorName,
    required this.quantityInStock,
    required this.location,
    required this.vendors,
    required this.onAdd,
    super.key,
  });

  final TextEditingController oemPartNumber;
  final TextEditingController oemDescription;
  final TextEditingController vendorPartNumber;
  final TextEditingController vendorDescription;
  final TextEditingController serialNumber;
  final TextEditingController vendorName;
  final TextEditingController quantityInStock;
  final TextEditingController location;
  final List<String> vendors;
  final ValueChanged<SparePartRecord> onAdd;

  void _submit() {
    final record = SparePartRecord(
      oemPartNumber: oemPartNumber.text.trim(),
      oemDescription: oemDescription.text.trim(),
      vendorPartNumber: vendorPartNumber.text.trim(),
      vendorDescription: vendorDescription.text.trim(),
      serialNumber: serialNumber.text.trim(),
      vendorName: vendorName.text.trim(),
      quantityInStock: quantityInStock.text.trim(),
      location: location.text.trim(),
    );
    if (record.values.every((value) => value.isEmpty)) return;
    onAdd(record);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _field(oemPartNumber, 'OEM Part Number'),
      const SizedBox(height: 16),
      _field(oemDescription, 'OEM Description'),
      const SizedBox(height: 16),
      _field(vendorPartNumber, 'Vendor Part Number'),
      const SizedBox(height: 16),
      _field(vendorDescription, 'Vendor Description'),
      const SizedBox(height: 16),
      _field(serialNumber, 'Serial Number'),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        initialValue: vendors.contains(vendorName.text)
            ? vendorName.text
            : null,
        decoration: const InputDecoration(
          labelText: 'Vendor Name',
          border: OutlineInputBorder(),
        ),
        items: vendors
            .map((name) => DropdownMenuItem(value: name, child: Text(name)))
            .toList(),
        onChanged: (name) => vendorName.text = name ?? '',
      ),
      const SizedBox(height: 16),
      _field(
        quantityInStock,
        'Quantity in Stock',
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _field(location, 'Location'),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.add),
          label: const Text('Add Spare Part'),
        ),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}
