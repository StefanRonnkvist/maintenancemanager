import 'package:flutter/material.dart';

import '../models/app_tab.dart';
import '../models/spare_part_record.dart';
import '../services/local_record_store.dart';
import '../widgets/management_tab_layout.dart';
import '../widgets/spare_parts_form.dart';
import '../widgets/spare_parts_table.dart';

/// Owns spare-part entry, local persistence, and the inventory table.
class SparePartsTab extends StatefulWidget {
  const SparePartsTab({super.key});

  @override
  State<SparePartsTab> createState() => _SparePartsTabState();
}

class _SparePartsTabState extends State<SparePartsTab> {
  static const _storageKey = 'spare_parts_records_v1';
  bool _formExpanded = false;
  bool _isLoading = true;
  String? _storageError;
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
  void initState() {
    super.initState();
    _loadRecords();
  }

  /// Restores saved parts and reports storage errors alongside the table.
  Future<void> _loadRecords() async {
    try {
      final rows = await LocalRecordStore.read(_storageKey);
      _records.addAll(rows.map(SparePartRecord.fromJson));
    } catch (error) {
      _storageError = 'Could not load spare parts: $error';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  /// Persists the full parts list after changes.
  Future<void> _persistRecords() async {
    try {
      await LocalRecordStore.write(
        _storageKey,
        _records.map((record) => record.toJson()).toList(),
      );
      if (mounted) setState(() => _storageError = null);
    } catch (error) {
      if (mounted) {
        setState(() => _storageError = 'Could not save spare parts: $error');
      }
    }
  }

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

  /// Appends a part, clears the form controllers, and saves the result.
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
    _persistRecords();
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
                onAdd: _addSparePart,
              ),
            ),
        ],
      ),
    ),
    recordsTitle: 'Spare parts list',
    records: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_storageError != null)
                Text(
                  _storageError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              SparePartsTable(records: _records),
            ],
          ),
  );
}
