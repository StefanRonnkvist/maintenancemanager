import 'package:flutter/material.dart';

import '../services/local_record_store.dart';

/// Work order page with free-entry business and location details.
class WorkOrderTab extends StatefulWidget {
  const WorkOrderTab({super.key});

  @override
  State<WorkOrderTab> createState() => _WorkOrderTabState();
}

class _WorkOrderTabState extends State<WorkOrderTab> {
  static const _storageKey = 'work_order_records_v1';
  final _businessNameController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _locationAddressController = TextEditingController();
  final _locationPhoneController = TextEditingController();
  final _locationAirportController = TextEditingController();
  final List<Map<String, dynamic>> _records = [];

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

  @override
  void dispose() {
    _businessNameController.dispose();
    _locationNameController.dispose();
    _locationAddressController.dispose();
    _locationPhoneController.dispose();
    _locationAirportController.dispose();
    super.dispose();
  }

  Future<void> _saveCurrentWorkOrder() async {
    final record = <String, dynamic>{
      'businessName': _businessNameController.text.trim(),
      'locationName': _locationNameController.text.trim(),
      'locationAddress': _locationAddressController.text.trim(),
      'locationDirectPhone': _locationPhoneController.text.trim(),
      'locationAirport': _locationAirportController.text.trim(),
    };
    if (record.values.every((value) => (value as String).isEmpty)) return;
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
              child: TextField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              width: 280,
              child: TextField(
                controller: _locationNameController,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _locationAddressController,
          decoration: const InputDecoration(
            labelText: 'Location Address',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _locationPhoneController,
          decoration: const InputDecoration(
            labelText: 'Location Direct Phone Number',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _locationAirportController,
          decoration: const InputDecoration(
            labelText: 'Location Airports',
            border: OutlineInputBorder(),
          ),
        ),
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
        Text(
          'Saved Work Orders',
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
}
