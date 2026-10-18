import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import '../services/local_record_store.dart';

/// Work order page with business and location details selected from Business.
class WorkOrderTab extends StatefulWidget {
  const WorkOrderTab({required this.businesses, super.key});

  final List<BusinessEntry> businesses;

  @override
  State<WorkOrderTab> createState() => _WorkOrderTabState();
}

class _WorkOrderTabState extends State<WorkOrderTab> {
  static const _storageKey = 'work_order_records_v1';
  String? _selectedBusinessName;
  String? _selectedLocationName;
  final List<Map<String, dynamic>> _records = [];

  BusinessEntry? get _selectedBusiness => widget.businesses
      .where((business) => business.name == _selectedBusinessName)
      .firstOrNull;

  BusinessLocation? get _selectedLocation => _selectedBusiness?.locations
      .where((location) => location.name == _selectedLocationName)
      .firstOrNull;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final records = await LocalRecordStore.read(_storageKey);
      if (!mounted) return;
      setState(() => _records.addAll(records));
    } catch (error) {
      if (mounted) _showMessage('Could not load work orders: $error');
    }
  }

  Future<void> _saveCurrentWorkOrder() async {
    final business = _selectedBusiness;
    final location = _selectedLocation;
    if (business == null || location == null) {
      _showMessage('Select a business and location first.');
      return;
    }

    final record = <String, dynamic>{
      'businessName': business.name,
      'locationName': location.name,
      'locationAddress': location.address,
      'locationDirectPhone': location.directPhone,
      'locationAirport': location.nearestAirport,
    };
    final updated = [record, ..._records];
    try {
      await LocalRecordStore.write(_storageKey, updated);
      if (!mounted) return;
      setState(() {
        _records
          ..clear()
          ..addAll(updated);
      });
      _showMessage('Work order saved.');
    } catch (error) {
      _showMessage('Could not save work order: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final business = _selectedBusiness;
    final location = _selectedLocation;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Work Order', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 280,
              child: DropdownButtonFormField<String>(
                initialValue: widget.businesses.any(
                  (item) => item.name == _selectedBusinessName,
                )
                    ? _selectedBusinessName
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  border: OutlineInputBorder(),
                ),
                items: widget.businesses
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.name,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (name) => setState(() {
                  _selectedBusinessName = name;
                  _selectedLocationName = null;
                }),
              ),
            ),
            SizedBox(
              width: 280,
              child: DropdownButtonFormField<String>(
                initialValue: business?.locations.any(
                  (item) => item.name == _selectedLocationName,
                ) == true
                    ? _selectedLocationName
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  border: OutlineInputBorder(),
                ),
                items: (business?.locations ?? const <BusinessLocation>[])
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.name,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: business == null
                    ? null
                    : (name) => setState(() => _selectedLocationName = name),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _detailField('Location Address', location?.address),
        _detailField('Location Direct Phone Number', location?.directPhone),
        _detailField('Location Airports', location?.nearestAirport),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _saveCurrentWorkOrder,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Work Order'),
          ),
        ),
        const SizedBox(height: 24),
        Text('Saved Work Orders', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_records.isEmpty)
          const Text('No saved work orders yet.')
        else
          for (final record in _records)
            Card(
              child: ListTile(
                title: Text(record['businessName'] as String? ?? ''),
                subtitle: Text(
                  '${record['locationName'] ?? ''} · '
                  '${record['locationAddress'] ?? ''} · '
                  '${record['locationDirectPhone'] ?? ''} · '
                  '${record['locationAirport'] ?? ''}',
                ),
              ),
            ),
      ],
    );
  }

  Widget _detailField(String label, String? value) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      key: ValueKey('$label-${value ?? ''}'),
      initialValue: value ?? '',
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
