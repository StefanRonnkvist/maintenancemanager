import 'package:flutter/material.dart';

import '../models/app_tab.dart';

class SparePartsTab extends StatelessWidget {
  const SparePartsTab({super.key});

  @override
  Widget build(BuildContext context) => const _SparePartsBrowser();
}

class _SparePartsBrowser extends StatefulWidget {
  const _SparePartsBrowser();

  @override
  State<_SparePartsBrowser> createState() => _SparePartsBrowserState();
}

class _SparePartsBrowserState extends State<_SparePartsBrowser> {
  final _oemPartNumberController = TextEditingController();
  final _oemDescriptionController = TextEditingController();
  final _vendorPartNumberController = TextEditingController();
  final _vendorDescriptionController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _quantityInStockController = TextEditingController();
  final _locationController = TextEditingController();
  final List<_SparePartRecord> _records = [];
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
    final record = _SparePartRecord(
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(AppTab.spareParts.icon, size: 48, color: colors.primary),
                  const SizedBox(height: 12),
                  Text(
                    AppTab.spareParts.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'Add Spare Part',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          trailing: Icon(
                            _formExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          onTap: () =>
                              setState(() => _formExpanded = !_formExpanded),
                        ),
                        if (_formExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final fieldWidth =
                                        constraints.maxWidth >= 560
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
                                          child: _textField(
                                            'Location',
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
                                    label: const Text('Add Spare Part'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 24),
                  Text(
                    'Spare parts list',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Center(child: _SparePartsTable(records: _records)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SparePartRecord {
  const _SparePartRecord({
    required this.oemPartNumber,
    required this.oemDescription,
    required this.vendorPartNumber,
    required this.vendorDescription,
    required this.serialNumber,
    required this.vendorName,
    required this.quantityInStock,
    required this.location,
  });

  final String oemPartNumber;
  final String oemDescription;
  final String vendorPartNumber;
  final String vendorDescription;
  final String serialNumber;
  final String vendorName;
  final String quantityInStock;
  final String location;

  List<String> get values => [
    oemPartNumber,
    oemDescription,
    vendorPartNumber,
    vendorDescription,
    serialNumber,
    vendorName,
    quantityInStock,
    location,
  ];
}

class _SparePartsTable extends StatelessWidget {
  const _SparePartsTable({required this.records});

  final List<_SparePartRecord> records;

  @override
  Widget build(BuildContext context) {
    final table = _buildTable(context);
    if (records.isNotEmpty) return table;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        table,
        const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No spare parts added yet.')),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      headingRowColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      dataRowMinHeight: 52,
      columns: const [
        DataColumn(label: Text('OEM Part Number')),
        DataColumn(label: Text('OEM Description')),
        DataColumn(label: Text('Vendor Part Number')),
        DataColumn(label: Text('Vendor Description')),
        DataColumn(label: Text('Serial Number')),
        DataColumn(label: Text('Vendor Name')),
        DataColumn(label: Text('Quantity in Stock')),
        DataColumn(label: Text('Location')),
      ],
      rows: records
          .map(
            (record) => DataRow(
              cells: [...record.values.map((value) => DataCell(Text(value)))],
            ),
          )
          .toList(),
    ),
  );
}
