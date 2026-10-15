import 'package:flutter/material.dart';

import '../models/app_tab.dart';
import '../widgets/management_tab_layout.dart';

class SparePartsTab extends StatefulWidget {
  const SparePartsTab({super.key});

  @override
  State<SparePartsTab> createState() => _SparePartsTabState();
}

class _SparePartsTabState extends State<SparePartsTab> {
  bool _formExpanded = false;
  final _oemPartNumber = TextEditingController();
  final _oemDescription = TextEditingController();
  final _vendorPartNumber = TextEditingController();
  final _vendorDescription = TextEditingController();
  final _serialNumber = TextEditingController();
  final _vendorName = TextEditingController();
  final _quantityInStock = TextEditingController();
  final _location = TextEditingController();
  final List<_SparePartRecord> _records = [];

  @override
  void dispose() {
    _oemPartNumber.dispose();
    _oemDescription.dispose();
    _vendorPartNumber.dispose();
    _vendorDescription.dispose();
    _serialNumber.dispose();
    _vendorName.dispose();
    _quantityInStock.dispose();
    _location.dispose();
    super.dispose();
  }

  void _addSparePart() {
    final record = _SparePartRecord(
      oemPartNumber: _oemPartNumber.text.trim(),
      oemDescription: _oemDescription.text.trim(),
      vendorPartNumber: _vendorPartNumber.text.trim(),
      vendorDescription: _vendorDescription.text.trim(),
      serialNumber: _serialNumber.text.trim(),
      vendorName: _vendorName.text.trim(),
      quantityInStock: _quantityInStock.text.trim(),
      location: _location.text.trim(),
    );
    if (record.values.every((value) => value.isEmpty)) return;
    setState(() {
      _records.add(record);
      _oemPartNumber.clear();
      _oemDescription.clear();
      _vendorPartNumber.clear();
      _vendorDescription.clear();
      _serialNumber.clear();
      _vendorName.clear();
      _quantityInStock.clear();
      _location.clear();
    });
  }

  @override
  Widget build(BuildContext context) => ManagementTabLayout(
    title: AppTab.spareParts.label,
    icon: AppTab.spareParts.icon,
    form: Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            title: const Text('Add spare parts'),
            trailing: Icon(
              _formExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () => setState(() => _formExpanded = !_formExpanded),
          ),
          if (_formExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _SparePartsForm(
                oemPartNumber: _oemPartNumber,
                oemDescription: _oemDescription,
                vendorPartNumber: _vendorPartNumber,
                vendorDescription: _vendorDescription,
                serialNumber: _serialNumber,
                vendorName: _vendorName,
                quantityInStock: _quantityInStock,
                location: _location,
                onAdd: _addSparePart,
              ),
            ),
        ],
      ),
    ),
    recordsTitle: 'Spare parts list',
    records: _SparePartsTable(records: _records),
  );
}

class _SparePartsForm extends StatelessWidget {
  const _SparePartsForm({
    required this.oemPartNumber,
    required this.oemDescription,
    required this.vendorPartNumber,
    required this.vendorDescription,
    required this.serialNumber,
    required this.vendorName,
    required this.quantityInStock,
    required this.location,
    required this.onAdd,
  });

  final TextEditingController oemPartNumber;
  final TextEditingController oemDescription;
  final TextEditingController vendorPartNumber;
  final TextEditingController vendorDescription;
  final TextEditingController serialNumber;
  final TextEditingController vendorName;
  final TextEditingController quantityInStock;
  final TextEditingController location;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextFormField(
        controller: oemPartNumber,
        decoration: const InputDecoration(
          labelText: 'OEM Part Number',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: oemDescription,
        decoration: const InputDecoration(
          labelText: 'OEM Description',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: vendorPartNumber,
        decoration: const InputDecoration(
          labelText: 'Vendor Part Number',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: vendorDescription,
        decoration: const InputDecoration(
          labelText: 'Vendor Description',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: serialNumber,
        decoration: const InputDecoration(
          labelText: 'Serial Number',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: vendorName,
        decoration: const InputDecoration(
          labelText: 'Vendor Name',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: quantityInStock,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Quantity in Stock',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: location,
        decoration: const InputDecoration(
          labelText: 'Location',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add Spare Part'),
        ),
      ),
    ],
  );
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

  static const _columns = [
    'OEM Part Number',
    'OEM Description',
    'Vendor Part Number',
    'Vendor Description',
    'Serial Number',
    'Vendor Name',
    'Quantity in Stock',
    'Location',
  ];

  @override
  Widget build(BuildContext context) {
    final table = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 52,
        columns: [
          for (final column in _columns) DataColumn(label: Text(column)),
        ],
        rows: [
          for (final record in records)
            DataRow(
              cells: [for (final value in record.values) DataCell(Text(value))],
            ),
        ],
      ),
    );
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
}
