import 'package:flutter/material.dart';

import '../models/spare_part_record.dart';
import '../widgets/management_record_table.dart';
import '../widgets/management_tab_layout.dart';

class SparePartsTab extends StatefulWidget {
  const SparePartsTab({super.key});

  @override
  State<SparePartsTab> createState() => _SparePartsTabState();
}

class _SparePartsTabState extends State<SparePartsTab> {
  final _oemPartNumberController = TextEditingController();
  final _oemDescriptionController = TextEditingController();
  final _vendorPartNumberController = TextEditingController();
  final _vendorDescriptionController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _quantityInStockController = TextEditingController();
  final _locationController = TextEditingController();
  final List<SparePartRecord> _records = [];
  bool _formExpanded = false;

  @override
  void dispose() {
    _oemPartNumberController.dispose();
    _oemDescriptionController.dispose();
    _vendorPartNumberController.dispose();
    _vendorDescriptionController.dispose();
    _serialNumberController.dispose();
    _vendorNameController.dispose();
    _quantityInStockController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Widget _textField(String label, TextEditingController controller) =>
      TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      );

  void _addSparePart() {
    final record = SparePartRecord(
      oemPartNumber: _oemPartNumberController.text.trim(),
      oemDescription: _oemDescriptionController.text.trim(),
      vendorPartNumber: _vendorPartNumberController.text.trim(),
      vendorDescription: _vendorDescriptionController.text.trim(),
      serialNumber: _serialNumberController.text.trim(),
      vendorName: _vendorNameController.text.trim(),
      quantityInStock: _quantityInStockController.text.trim(),
      location: _locationController.text.trim(),
    );

    if (record.values.every((value) => value.isEmpty)) return;

    setState(() {
      _records.add(record);
      _oemPartNumberController.clear();
      _oemDescriptionController.clear();
      _vendorPartNumberController.clear();
      _vendorDescriptionController.clear();
      _serialNumberController.clear();
      _vendorNameController.clear();
      _quantityInStockController.clear();
      _locationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) => ManagementTabLayout(
    recordsTitle: 'Spare parts list',
    form: Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Add Spare Part',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: Icon(
              _formExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () => setState(() => _formExpanded = !_formExpanded),
          ),
          if (_formExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final fieldWidth = constraints.maxWidth >= 560
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              'OEM Part Number',
                              _oemPartNumberController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              'OEM Description',
                              _oemDescriptionController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              'Vendor Part Number',
                              _vendorPartNumberController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              'Vendor Description',
                              _vendorDescriptionController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              'Serial Number',
                              _serialNumberController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              'Vendor Name',
                              _vendorNameController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              'Quantity in Stock',
                              _quantityInStockController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField('Location', _locationController),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _addSparePart,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Spare Part'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
    records: ManagementRecordTable(
      columns: SparePartRecord.columns,
      rows: [for (final record in _records) record.values],
      emptyMessage: 'No spare parts added yet.',
    ),
  );
}
