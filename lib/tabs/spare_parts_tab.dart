import 'package:flutter/material.dart';

import '../models/spare_part_record.dart';
import '../models/ui_text_catalog.dart';
import '../widgets/management_record_table.dart';
import '../widgets/management_tab_layout.dart';

class SparePartsTab extends StatefulWidget {
  const SparePartsTab({required this.text, super.key});

  final UiTextCatalog text;

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
    text: widget.text,
    title: widget.text('title', tab: 'spareParts'),
    recordsTitle: widget.text('recordsTitle', tab: 'spareParts'),
    form: Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.text('formTitle', tab: 'spareParts'),
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
                              widget.text.fieldLabel(
                                'spareParts',
                                'oemPartNumber',
                              ),
                              _oemPartNumberController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              widget.text.fieldLabel(
                                'spareParts',
                                'oemDescription',
                              ),
                              _oemDescriptionController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              widget.text.fieldLabel(
                                'spareParts',
                                'vendorPartNumber',
                              ),
                              _vendorPartNumberController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              widget.text.fieldLabel(
                                'spareParts',
                                'vendorDescription',
                              ),
                              _vendorDescriptionController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              widget.text.fieldLabel(
                                'spareParts',
                                'serialNumber',
                              ),
                              _serialNumberController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              widget.text.fieldLabel(
                                'spareParts',
                                'vendorName',
                              ),
                              _vendorNameController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              widget.text.fieldLabel(
                                'spareParts',
                                'quantityInStock',
                              ),
                              _quantityInStockController,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _textField(
                              widget.text.fieldLabel('spareParts', 'location'),
                              _locationController,
                            ),
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
                      label: Text(widget.text.action('spareParts', 'add')),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
    records: ManagementRecordTable(
      columns: widget.text.list('sparePartsTableColumns'),
      rows: [for (final record in _records) record.values],
      emptyMessage: widget.text('emptyMessage', tab: 'spareParts'),
    ),
  );
}
