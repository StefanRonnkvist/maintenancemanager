import 'package:flutter/material.dart';

import '../models/app_tab.dart';
import '../models/business_entry.dart';
import '../models/spare_part_record.dart';
import '../widgets/management_tab_layout.dart';
import '../widgets/spare_parts_form.dart';
import '../widgets/spare_parts_table.dart';

class SparePartsTab extends StatefulWidget {
  const SparePartsTab({required this.businesses, super.key});

  final List<BusinessEntry> businesses;

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
  final List<SparePartRecord> _records = [];

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

  void _addSparePart(SparePartRecord record) {
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
              child: SparePartsForm(
                oemPartNumber: _oemPartNumber,
                oemDescription: _oemDescription,
                vendorPartNumber: _vendorPartNumber,
                vendorDescription: _vendorDescription,
                serialNumber: _serialNumber,
                vendorName: _vendorName,
                quantityInStock: _quantityInStock,
                location: _location,
                vendors: widget.businesses
                    .where((business) => business.businessType == 'Vendor')
                    .map((business) => business.name)
                    .toList(growable: false),
                onAdd: _addSparePart,
              ),
            ),
        ],
      ),
    ),
    recordsTitle: 'Spare parts list',
    records: SparePartsTable(records: _records),
  );
}
