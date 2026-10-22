import 'package:flutter/material.dart';

import '../models/app_tab.dart';
import '../models/business_entry.dart';
import '../models/spare_part_record.dart';
import '../services/local_record_store.dart';
import '../widgets/business_table.dart';
import '../widgets/management_tab_layout.dart';
import '../widgets/spare_parts_form.dart';
import '../widgets/spare_parts_table.dart';

/// Owns spare-part entry.
class SparePartsTab extends StatefulWidget {
  const SparePartsTab({
    required this.businessEntries,
    required this.peopleEntries,
    super.key,
  });

  final List<BusinessEntry> businessEntries;
  final List<BusinessEntry> peopleEntries;

  @override
  State<SparePartsTab> createState() => _SparePartsTabState();
}

class _SparePartsTabState extends State<SparePartsTab> {
  static const _storageKey = 'spare_parts_records_v1';
  bool _formExpanded = false;
  bool _isLoading = true;
  String? _storageError;
  int? _editingIndex;
  final List<SparePartRecord> _records = [];
  SparePartRecord? _selectedRecord;
  final _oemPartNumber = TextEditingController();
  final _oemDescription = TextEditingController();
  final _vendorPartNumber = TextEditingController();
  final _vendorDescription = TextEditingController();
  final _serialNumber = TextEditingController();
  final _vendorName = TextEditingController();
  final _locationName = TextEditingController();
  final _quantityInStock = TextEditingController();
  final _location = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final rows = await LocalRecordStore.read(_storageKey);
      _records
        ..clear()
        ..addAll(rows.map(SparePartRecord.fromJson));
    } catch (error) {
      _storageError = 'Could not load spare parts: $error';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveRecords() async {
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
    _locationName.dispose();
    _quantityInStock.dispose();
    _location.dispose();
    super.dispose();
  }

  /// Adds or updates the selected record, persists it, and resets the form.
  void _saveSparePart(SparePartRecord record) {
    setState(() {
      final index = _editingIndex;
      if (index == null) {
        _records.add(record);
      } else {
        _records[index] = record;
      }
      _editingIndex = null;
      _selectedRecord = null;
      _formExpanded = false;
    });
    _saveRecords();
    _clearForm();
  }

  List<BusinessEntry> get _matchingVendorPeople {
    final record = _selectedRecord;
    if (record == null ||
        record.vendorName.trim().isEmpty ||
        record.locationName.trim().isEmpty) {
      return const [];
    }
    return widget.peopleEntries
        .where(
          (person) =>
              person.businessName.trim() == record.vendorName.trim() &&
              person.locationName.trim() == record.locationName.trim(),
        )
        .toList(growable: false);
  }

  void _selectSparePart(int index) {
    final record = _records[index];
    setState(() {
      _editingIndex = index;
      _selectedRecord = record;
      _formExpanded = true;
    });
    _oemPartNumber.text = record.oemPartNumber;
    _oemDescription.text = record.oemDescription;
    _vendorPartNumber.text = record.vendorPartNumber;
    _vendorDescription.text = record.vendorDescription;
    _serialNumber.text = record.serialNumber;
    _vendorName.text = record.vendorName;
    _locationName.text = record.locationName;
    _quantityInStock.text = record.quantityInStock;
    _location.text = record.location;
  }

  void _clearForm() {
    _oemPartNumber.clear();
    _oemDescription.clear();
    _vendorPartNumber.clear();
    _vendorDescription.clear();
    _serialNumber.clear();
    _vendorName.clear();
    _locationName.clear();
    _quantityInStock.clear();
    _location.clear();
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
                locationName: _locationName,
                vendorEntries: widget.businessEntries
                    .where(
                      (entry) =>
                          entry.businessType.trim().toLowerCase() == 'vendor',
                    )
                    .toList(growable: false),
                quantityInStock: _quantityInStock,
                location: _location,
                onAdd: _saveSparePart,
                isEditing: _editingIndex != null,
              ),
            ),
        ],
      ),
    ),
    recordsTitle: 'Spare parts list',
    records: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selectedRecord != null) ...[
          Text(
            'People for ${_selectedRecord!.vendorName} — ${_selectedRecord!.locationName}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          PeopleTable(
            entries: _matchingVendorPeople,
            onRowTap: (_) {},
            selectedEntry: null,
            emptyMessage: 'No people match this vendor and location.',
          ),
          const SizedBox(height: 16),
        ],
        if (_storageError != null)
          Text(
            _storageError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          SparePartsTable(
            records: [for (final record in _records) record.values],
            onRowTap: _selectSparePart,
          ),
      ],
    ),
  );
}
