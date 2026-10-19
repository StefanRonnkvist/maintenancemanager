import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/local_record_store.dart';
import '../widgets/work_order_table.dart';

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
  Map<String, List<String>> _componentOptions = const {};
  String? _selectedComponentCategory;
  String? _selectedComponent;
  bool _formExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _loadComponentOptions();
  }

  Future<void> _loadComponentOptions() async {
    try {
      final csv = await rootBundle.loadString('assets/components.csv');
      final options = <String, List<String>>{};
      for (final line in const LineSplitter().convert(csv).skip(1)) {
        final columns = line.split(',');
        if (columns.length < 2) continue;
        final category = columns[0].trim();
        final component = columns[1].trim();
        if (category.isEmpty || component.isEmpty) continue;
        options.putIfAbsent(category, () => <String>[]).add(component);
      }
      if (!mounted) return;
      setState(() => _componentOptions = options);
    } catch (_) {
      // Keep work order entry available if the optional CSV asset fails.
    }
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
      'componentCategory': _selectedComponentCategory ?? '',
      'component': _selectedComponent ?? '',
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
        Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('Work order details'),
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
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 280,
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(_selectedComponentCategory),
                              initialValue: _selectedComponentCategory,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Component Category',
                                border: OutlineInputBorder(),
                              ),
                              items: _componentOptions.keys
                                  .map(
                                    (category) => DropdownMenuItem(
                                      value: category,
                                      child: Text(
                                        category,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: _componentOptions.isEmpty
                                  ? null
                                  : (category) => setState(() {
                                      _selectedComponentCategory = category;
                                      _selectedComponent = null;
                                    }),
                            ),
                          ),
                          SizedBox(
                            width: 280,
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(
                                '${_selectedComponentCategory}_$_selectedComponent',
                              ),
                              initialValue: _selectedComponent,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Component',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  (_selectedComponentCategory == null
                                          ? const <String>[]
                                          : _componentOptions[_selectedComponentCategory] ??
                                                const <String>[])
                                      .map(
                                        (component) => DropdownMenuItem(
                                          value: component,
                                          child: Text(
                                            component,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: _selectedComponentCategory == null
                                  ? null
                                  : (component) => setState(
                                      () => _selectedComponent = component,
                                    ),
                            ),
                          ),
                        ],
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
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Saved Work Orders',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        WorkOrderTable(records: _records),
      ],
    );
  }
}
