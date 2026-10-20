import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/business_entry.dart';
import '../services/local_record_store.dart';
import '../widgets/work_order_table.dart';

/// Work order page with free-entry business and location details.
class WorkOrderTab extends StatefulWidget {
  const WorkOrderTab({
    required this.businessEntries,
    required this.peopleEntries,
    super.key,
  });

  final List<BusinessEntry> businessEntries;
  final List<BusinessEntry> peopleEntries;

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
  final _notesController = TextEditingController();
  final List<TextEditingController> _assignedNameControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _assignedEmailControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _assignedPhoneControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<Map<String, dynamic>> _records = [];
  Map<String, List<String>> _componentOptions = const {};
  String? _selectedComponentCategory;
  String? _selectedComponent;
  String? _selectedBusinessName;
  String? _selectedLocationName;
  bool _formExpanded = false;

  List<String> get _businessOptions =>
      widget.businessEntries
          .map((entry) => entry.name.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  BusinessEntry? get _selectedBusiness => widget.businessEntries
      .where((entry) => entry.name.trim() == _selectedBusinessName)
      .firstOrNull;

  @override
  void didUpdateWidget(covariant WorkOrderTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedBusinessName != null &&
        !_businessOptions.contains(_selectedBusinessName)) {
      _selectedBusinessName = null;
      _selectedLocationName = null;
      _businessNameController.clear();
      _locationNameController.clear();
    }
  }

  List<String> get _locationOptions =>
      _selectedBusiness?.locations
          .map((location) => location.name.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList() ??
      const [];

  final List<bool> _assignedExpanded = List.filled(4, false);

  List<BusinessEntry> get _matchingPeople {
    final businessName = _selectedBusinessName?.trim() ?? '';
    final locationName = _selectedLocationName?.trim() ?? '';
    if (businessName.isEmpty || locationName.isEmpty) return const [];
    return widget.peopleEntries
        .where(
          (entry) =>
              entry.businessName.trim() == businessName &&
              entry.locationName.trim() == locationName,
        )
        .toList(growable: false);
  }

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
    _notesController.dispose();
    for (final controller in [
      ..._assignedNameControllers,
      ..._assignedEmailControllers,
      ..._assignedPhoneControllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveCurrentWorkOrder() async {
    final record = <String, dynamic>{
      'businessName': _businessNameController.text.trim(),
      'locationName': _locationNameController.text.trim(),
      'locationAddress': _locationAddressController.text.trim(),
      'locationDirectPhone': _locationPhoneController.text.trim(),
      'locationAirport': _locationAirportController.text.trim(),
      'notes': _notesController.text.trim(),
      for (var index = 0; index < 4; index++) ...{
        'assigned${index + 1}Name': _assignedNameControllers[index].text.trim(),
        'assigned${index + 1}Email': _assignedEmailControllers[index].text
            .trim(),
        'assigned${index + 1}Phone': _assignedPhoneControllers[index].text
            .trim(),
      },
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
        _selectedBusinessName = null;
        _selectedLocationName = null;
      });
      _businessNameController.clear();
      _locationNameController.clear();
      _locationAddressController.clear();
      _locationPhoneController.clear();
      _locationAirportController.clear();
      _notesController.clear();
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
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(_selectedBusinessName),
                              initialValue: _selectedBusinessName,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Business Name',
                                border: OutlineInputBorder(),
                              ),
                              items: _businessOptions
                                  .map(
                                    (businessName) => DropdownMenuItem(
                                      value: businessName,
                                      child: Text(businessName),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (businessName) => setState(() {
                                _selectedBusinessName = businessName;
                                _selectedLocationName = null;
                                _businessNameController.text =
                                    businessName ?? '';
                                _locationNameController.clear();
                                _locationAddressController.clear();
                                _locationPhoneController.clear();
                                _locationAirportController.clear();
                              }),
                            ),
                          ),
                          SizedBox(
                            width: 280,
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(
                                '${_selectedBusinessName}_$_selectedLocationName',
                              ),
                              initialValue: _selectedLocationName,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Location Name',
                                border: OutlineInputBorder(),
                              ),
                              items: _locationOptions
                                  .map(
                                    (locationName) => DropdownMenuItem(
                                      value: locationName,
                                      child: Text(locationName),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (locationName) => setState(() {
                                _selectedLocationName = locationName;
                                _locationNameController.text =
                                    locationName ?? '';
                                final location = _selectedBusiness?.locations
                                    .where((item) => item.name == locationName)
                                    .firstOrNull;
                                _locationAddressController.text =
                                    location?.address ?? '';
                                _locationPhoneController.text =
                                    location?.directPhone ?? '';
                                _locationAirportController.text =
                                    location?.nearestAirport ?? '';
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _locationAddressController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Location Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _locationPhoneController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Location Direct Phone Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _locationAirportController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Location Airports',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _MatchingPeopleTable(people: _matchingPeople),
                      const SizedBox(height: 12),
                      for (
                        var assignedIndex = 0;
                        assignedIndex < 4;
                        assignedIndex++
                      ) ...[
                        const SizedBox(height: 12),
                        Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              ListTile(
                                title: Text('Assigned ${assignedIndex + 1}'),
                                trailing: Icon(
                                  _assignedExpanded[assignedIndex]
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onTap: () => setState(() {
                                  _assignedExpanded[assignedIndex] =
                                      !_assignedExpanded[assignedIndex];
                                }),
                              ),
                              if (_assignedExpanded[assignedIndex])
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      SizedBox(
                                        width: 280,
                                        child: TextField(
                                          controller:
                                              _assignedNameControllers[assignedIndex],
                                          decoration: InputDecoration(
                                            labelText:
                                                'Assigned ${assignedIndex + 1} Name',
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 280,
                                        child: TextField(
                                          controller:
                                              _assignedEmailControllers[assignedIndex],
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Assigned ${assignedIndex + 1} Email',
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 280,
                                        child: TextField(
                                          controller:
                                              _assignedPhoneControllers[assignedIndex],
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            labelText:
                                                'Assigned ${assignedIndex + 1} Phone',
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      TextField(
                        controller: _notesController,
                        minLines: 4,
                        maxLines: 8,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          alignLabelWithHint: true,
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

class _MatchingPeopleTable extends StatelessWidget {
  const _MatchingPeopleTable({required this.people});

  final List<BusinessEntry> people;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'People at this business and location',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (people.isEmpty)
          const Text('No people match the selected business and location.')
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Direct Phone')),
                DataColumn(label: Text('Cell Phone')),
              ],
              rows: [
                for (final person in people)
                  DataRow(
                    cells: [
                      DataCell(Text(person.name)),
                      DataCell(Text(person.title)),
                      DataCell(Text(person.email)),
                      DataCell(Text(person.directPhone)),
                      DataCell(Text(person.cellPhone)),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
