import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_tab.dart';
import '../models/business_entry.dart';
import '../models/equipment_record.dart';
import '../services/local_record_store.dart';
import '../widgets/management_tab_layout.dart';

/// Builds the equipment browser and its free-entry equipment form.
class EquipmentTab extends StatefulWidget {
  const EquipmentTab({required this.businessEntries, super.key});

  final List<BusinessEntry> businessEntries;

  @override
  State<EquipmentTab> createState() => _EquipmentTabState();
}

class _EquipmentTabState extends State<EquipmentTab> {
  static const _storageKey = 'equipment_records_v1';
  bool _isLoading = true;
  String? _storageError;
  bool _formExpanded = false;
  EquipmentRecord? _selectedRecord;
  final List<bool> _subsectionExpanded = List.filled(4, false);
  final _localNameController = TextEditingController();
  final _localNumberController = TextEditingController();
  final _manufacturerNameController = TextEditingController();
  final _equipmentNameController = TextEditingController();
  final _equipmentModelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _maintenanceManualController = TextEditingController();
  final _publisherController = TextEditingController();
  final _categoryController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _subsectionControllers = List.generate(
    4,
    (_) => List.generate(8, (_) => TextEditingController()),
  );
  final List<EquipmentRecord> _records = [];
  String? _selectedBusinessName;
  String? _selectedLocationName;
  List<String> _componentOptions = const [];
  bool _componentsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _loadComponentOptions();
  }

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

  List<String> get _locationOptions =>
      _selectedBusiness?.locations
          .map((location) => location.name.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList() ??
      const [];

  Future<void> _loadComponentOptions() async {
    try {
      final csv = await rootBundle.loadString('assets/components.csv');
      final options = <String>{};
      for (final line in const LineSplitter().convert(csv).skip(1)) {
        final columns = line.split(',');
        if (columns.length < 2) continue;
        final component = columns[1].trim();
        if (component.isNotEmpty) options.add(component);
      }
      if (!mounted) return;
      setState(() {
        _componentOptions = options.toList()..sort();
        _componentsLoaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _storageError = 'Could not load equipment components: $error',
      );
    }
  }

  /// Restores persisted equipment rows before the table is shown.
  Future<void> _loadRecords() async {
    try {
      final rows = await LocalRecordStore.read(_storageKey);
      _records.addAll(rows.map(EquipmentRecord.fromJson));
    } catch (error) {
      _storageError = 'Could not load equipment: $error';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  /// Saves the current equipment list and exposes failures in the tab UI.
  Future<void> _persistRecords() async {
    try {
      await LocalRecordStore.write(
        _storageKey,
        _records.map((record) => record.toJson()).toList(),
      );
      if (mounted) setState(() => _storageError = null);
    } catch (error) {
      if (mounted) {
        setState(() => _storageError = 'Could not save equipment: $error');
      }
    }
  }

  @override
  void dispose() {
    _localNameController.dispose();
    _localNumberController.dispose();
    _manufacturerNameController.dispose();
    _equipmentNameController.dispose();
    _equipmentModelController.dispose();
    _serialNumberController.dispose();
    _maintenanceManualController.dispose();
    _publisherController.dispose();
    _categoryController.dispose();
    _businessNameController.dispose();
    _locationNameController.dispose();
    for (final subsection in _subsectionControllers) {
      for (final controller in subsection) {
        controller.dispose();
      }
    }
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

  Widget _componentDropdown(String label, TextEditingController controller) {
    final currentValue = controller.text;
    final options = <String>{..._componentOptions};
    if (currentValue.isNotEmpty) options.add(currentValue);
    final sortedOptions = options.toList()..sort();

    return DropdownButtonFormField<String>(
      key: ValueKey('$label:$currentValue:$_componentsLoaded'),
      initialValue: currentValue.isNotEmpty ? currentValue : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: sortedOptions
          .map(
            (component) =>
                DropdownMenuItem(value: component, child: Text(component)),
          )
          .toList(),
      onChanged: (value) => controller.text = value ?? '',
    );
  }

  void _selectEquipment(EquipmentRecord record) {
    setState(() {
      _selectedRecord = record;
      _formExpanded = true;
      _selectedBusinessName = _businessOptions.contains(record.businessName)
          ? record.businessName
          : null;
      _selectedLocationName = _locationOptions.contains(record.locationName)
          ? record.locationName
          : null;
      _businessNameController.text = record.businessName;
      _locationNameController.text = record.locationName;
      _categoryController.text = record.equipmentCategory;
      _localNameController.text = record.localName;
      _localNumberController.text = record.localNumber;
      _manufacturerNameController.text = record.manufacturerName;
      _equipmentNameController.text = record.equipmentName;
      _equipmentModelController.text = record.equipmentModel;
      _serialNumberController.text = record.serialNumber;
      _maintenanceManualController.text = record.maintenanceManual;
      _publisherController.text = record.publisher;
      final subsectionValues = [
        [
          record.subsection1LocalName,
          record.subsection1LocalNumber,
          record.subsection1ManufacturerName,
          record.subsection1EquipmentName,
          record.subsection1EquipmentModel,
          record.subsection1SerialNumber,
          record.subsection1MaintenanceManual,
          record.subsection1Publisher,
        ],
        [
          record.subsection2LocalName,
          record.subsection2LocalNumber,
          record.subsection2ManufacturerName,
          record.subsection2EquipmentName,
          record.subsection2EquipmentModel,
          record.subsection2SerialNumber,
          record.subsection2MaintenanceManual,
          record.subsection2Publisher,
        ],
        [
          record.subsection3LocalName,
          record.subsection3LocalNumber,
          record.subsection3ManufacturerName,
          record.subsection3EquipmentName,
          record.subsection3EquipmentModel,
          record.subsection3SerialNumber,
          record.subsection3MaintenanceManual,
          record.subsection3Publisher,
        ],
        [
          record.subsection4LocalName,
          record.subsection4LocalNumber,
          record.subsection4ManufacturerName,
          record.subsection4EquipmentName,
          record.subsection4EquipmentModel,
          record.subsection4SerialNumber,
          record.subsection4MaintenanceManual,
          record.subsection4Publisher,
        ],
      ];
      for (var section = 0; section < 4; section++) {
        for (var field = 0; field < 8; field++) {
          _subsectionControllers[section][field].text =
              subsectionValues[section][field];
        }
        _subsectionExpanded[section] = subsectionValues[section].any(
          (value) => value.isNotEmpty,
        );
      }
    });
  }

  /// Builds a record from the form, then appends and persists it.
  void _addEquipment() {
    final record = EquipmentRecord(
      businessName: _businessNameController.text.trim(),
      locationName: _locationNameController.text.trim(),
      equipmentCategory: _categoryController.text.trim(),
      localName: _localNameController.text.trim(),
      localNumber: _localNumberController.text.trim(),
      manufacturerName: _manufacturerNameController.text.trim(),
      equipmentName: _equipmentNameController.text.trim(),
      equipmentModel: _equipmentModelController.text.trim(),
      serialNumber: _serialNumberController.text.trim(),
      maintenanceManual: _maintenanceManualController.text.trim(),
      publisher: _publisherController.text.trim(),
      subsection1LocalName: _subsectionControllers[0][0].text.trim(),
      subsection1LocalNumber: _subsectionControllers[0][1].text.trim(),
      subsection1ManufacturerName: _subsectionControllers[0][2].text.trim(),
      subsection1EquipmentName: _subsectionControllers[0][3].text.trim(),
      subsection1EquipmentModel: _subsectionControllers[0][4].text.trim(),
      subsection1SerialNumber: _subsectionControllers[0][5].text.trim(),
      subsection1MaintenanceManual: _subsectionControllers[0][6].text.trim(),
      subsection1Publisher: _subsectionControllers[0][7].text.trim(),
      subsection2LocalName: _subsectionControllers[1][0].text.trim(),
      subsection2LocalNumber: _subsectionControllers[1][1].text.trim(),
      subsection2ManufacturerName: _subsectionControllers[1][2].text.trim(),
      subsection2EquipmentName: _subsectionControllers[1][3].text.trim(),
      subsection2EquipmentModel: _subsectionControllers[1][4].text.trim(),
      subsection2SerialNumber: _subsectionControllers[1][5].text.trim(),
      subsection2MaintenanceManual: _subsectionControllers[1][6].text.trim(),
      subsection2Publisher: _subsectionControllers[1][7].text.trim(),
      subsection3LocalName: _subsectionControllers[2][0].text.trim(),
      subsection3LocalNumber: _subsectionControllers[2][1].text.trim(),
      subsection3ManufacturerName: _subsectionControllers[2][2].text.trim(),
      subsection3EquipmentName: _subsectionControllers[2][3].text.trim(),
      subsection3EquipmentModel: _subsectionControllers[2][4].text.trim(),
      subsection3SerialNumber: _subsectionControllers[2][5].text.trim(),
      subsection3MaintenanceManual: _subsectionControllers[2][6].text.trim(),
      subsection3Publisher: _subsectionControllers[2][7].text.trim(),
      subsection4LocalName: _subsectionControllers[3][0].text.trim(),
      subsection4LocalNumber: _subsectionControllers[3][1].text.trim(),
      subsection4ManufacturerName: _subsectionControllers[3][2].text.trim(),
      subsection4EquipmentName: _subsectionControllers[3][3].text.trim(),
      subsection4EquipmentModel: _subsectionControllers[3][4].text.trim(),
      subsection4SerialNumber: _subsectionControllers[3][5].text.trim(),
      subsection4MaintenanceManual: _subsectionControllers[3][6].text.trim(),
      subsection4Publisher: _subsectionControllers[3][7].text.trim(),
    );

    if (record.toJson().values.every((value) => value == '')) {
      return;
    }

    setState(() {
      if (_selectedRecord == null) {
        _records.add(record);
      } else {
        final index = _records.indexOf(_selectedRecord!);
        if (index >= 0) _records[index] = record;
      }
      _selectedRecord = null;
      _selectedBusinessName = null;
      _selectedLocationName = null;
      _localNameController.clear();
      _localNumberController.clear();
      _manufacturerNameController.clear();
      _equipmentNameController.clear();
      _equipmentModelController.clear();
      _serialNumberController.clear();
      _maintenanceManualController.clear();
      _publisherController.clear();
      _categoryController.clear();
      _businessNameController.clear();
      _locationNameController.clear();
      for (final subsection in _subsectionControllers) {
        for (final controller in subsection) {
          controller.clear();
        }
      }
    });
    _persistRecords();
  }

  @override
  Widget build(BuildContext context) {
    return ManagementTabLayout(
      title: AppTab.equipment.label,
      icon: AppTab.equipment.icon,
      recordsTitle: 'Equipment list',
      records: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_storageError != null)
                  Text(
                    _storageError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                LayoutBuilder(
                  builder: (context, constraints) => SizedBox(
                    width: constraints.maxWidth,
                    child: _EquipmentTable(
                      records: _records,
                      onRowTap: _selectEquipment,
                      selectedRecord: _selectedRecord,
                    ),
                  ),
                ),
              ],
            ),
      form: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              title: Text(
                _selectedRecord == null ? 'Add equipment' : 'Update equipment',
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
                    _componentDropdown(
                      'Equipment category',
                      _categoryController,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Business and location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedBusinessName),
                      initialValue: _selectedBusinessName,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        border: OutlineInputBorder(),
                      ),
                      items: _businessOptions
                          .map(
                            (name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ),
                          )
                          .toList(),
                      onChanged: (name) => setState(() {
                        _selectedBusinessName = name;
                        _selectedLocationName = null;
                        _businessNameController.text = name ?? '';
                        _locationNameController.clear();
                      }),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
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
                            (name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ),
                          )
                          .toList(),
                      onChanged: (name) => setState(() {
                        _selectedLocationName = name;
                        _locationNameController.text = name ?? '';
                      }),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Equipment details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
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
                                'Local Name',
                                _localNameController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _textField(
                                'Local Number',
                                _localNumberController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _textField(
                                'Manufacturer Name',
                                _manufacturerNameController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _componentDropdown(
                                'Equipment Name',
                                _equipmentNameController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _textField(
                                'Equipment Model',
                                _equipmentModelController,
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
                                'Maintenance Manual',
                                _maintenanceManualController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _textField(
                                'Publisher',
                                _publisherController,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    for (
                      var subsectionIndex = 0;
                      subsectionIndex < 4;
                      subsectionIndex++
                    ) ...[
                      const SizedBox(height: 12),
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            ListTile(
                              title: Text('Subsection ${subsectionIndex + 1}'),
                              trailing: Icon(
                                _subsectionExpanded[subsectionIndex]
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onTap: () => setState(() {
                                _subsectionExpanded[subsectionIndex] =
                                    !_subsectionExpanded[subsectionIndex];
                              }),
                            ),
                            if (_subsectionExpanded[subsectionIndex])
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final fieldWidth =
                                        constraints.maxWidth >= 560
                                        ? (constraints.maxWidth - 16) / 2
                                        : constraints.maxWidth;
                                    final labels = [
                                      'Local Name',
                                      'Local Number',
                                      'Manufacturer Name',
                                      'Equipment Name',
                                      'Equipment Model',
                                      'Serial Number',
                                      'Maintenance Manual',
                                      'Publisher',
                                    ];
                                    return Wrap(
                                      spacing: 16,
                                      runSpacing: 16,
                                      children: [
                                        for (
                                          var fieldIndex = 0;
                                          fieldIndex < labels.length;
                                          fieldIndex++
                                        )
                                          SizedBox(
                                            width: fieldWidth,
                                            child: _textField(
                                              'Subsection ${subsectionIndex + 1} ${labels[fieldIndex]}',
                                              _subsectionControllers[subsectionIndex][fieldIndex],
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _addEquipment,
                        icon: Icon(
                          _selectedRecord == null ? Icons.add : Icons.save,
                        ),
                        label: Text(
                          _selectedRecord == null
                              ? 'Add Equipment'
                              : 'Update Equipment',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentTable extends StatelessWidget {
  const _EquipmentTable({
    required this.records,
    required this.onRowTap,
    required this.selectedRecord,
  });

  final List<EquipmentRecord> records;
  final ValueChanged<EquipmentRecord> onRowTap;
  final EquipmentRecord? selectedRecord;

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
          child: Center(child: Text('No equipment added yet.')),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      showCheckboxColumn: false,
      headingRowColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      dataRowMinHeight: 48,
      columns: const [
        DataColumn(label: Text('Equipment Category')),
        DataColumn(label: Text('Local Name')),
        DataColumn(label: Text('Local Number')),
        DataColumn(label: Text('Manufacturer Name')),
        DataColumn(label: Text('Equipment Name')),
        DataColumn(label: Text('Equipment Model')),
        DataColumn(label: Text('Serial Number')),
        DataColumn(label: Text('Maintenance Manual')),
        DataColumn(label: Text('Publisher')),
        DataColumn(label: Text('Subsection 1 Local Name')),
        DataColumn(label: Text('Subsection 1 Local Number')),
        DataColumn(label: Text('Subsection 1 Manufacturer Name')),
        DataColumn(label: Text('Subsection 1 Equipment Name')),
        DataColumn(label: Text('Subsection 1 Equipment Model')),
        DataColumn(label: Text('Subsection 1 Serial Number')),
        DataColumn(label: Text('Subsection 1 Maintenance Manual')),
        DataColumn(label: Text('Subsection 1 Publisher')),
        DataColumn(label: Text('Subsection 2 Local Name')),
        DataColumn(label: Text('Subsection 2 Local Number')),
        DataColumn(label: Text('Subsection 2 Manufacturer Name')),
        DataColumn(label: Text('Subsection 2 Equipment Name')),
        DataColumn(label: Text('Subsection 2 Equipment Model')),
        DataColumn(label: Text('Subsection 2 Serial Number')),
        DataColumn(label: Text('Subsection 2 Maintenance Manual')),
        DataColumn(label: Text('Subsection 2 Publisher')),
        DataColumn(label: Text('Subsection 3 Local Name')),
        DataColumn(label: Text('Subsection 3 Local Number')),
        DataColumn(label: Text('Subsection 3 Manufacturer Name')),
        DataColumn(label: Text('Subsection 3 Equipment Name')),
        DataColumn(label: Text('Subsection 3 Equipment Model')),
        DataColumn(label: Text('Subsection 3 Serial Number')),
        DataColumn(label: Text('Subsection 3 Maintenance Manual')),
        DataColumn(label: Text('Subsection 3 Publisher')),
        DataColumn(label: Text('Subsection 4 Local Name')),
        DataColumn(label: Text('Subsection 4 Local Number')),
        DataColumn(label: Text('Subsection 4 Manufacturer Name')),
        DataColumn(label: Text('Subsection 4 Equipment Name')),
        DataColumn(label: Text('Subsection 4 Equipment Model')),
        DataColumn(label: Text('Subsection 4 Serial Number')),
        DataColumn(label: Text('Subsection 4 Maintenance Manual')),
        DataColumn(label: Text('Subsection 4 Publisher')),
        DataColumn(label: Text('Business Name')),
        DataColumn(label: Text('Location Name')),
      ],
      rows: records
          .map(
            (record) => DataRow(
              selected: identical(record, selectedRecord),
              onSelectChanged: (_) => onRowTap(record),
              cells: [
                DataCell(Text(record.equipmentCategory)),
                DataCell(Text(record.localName)),
                DataCell(Text(record.localNumber)),
                DataCell(Text(record.manufacturerName)),
                DataCell(Text(record.equipmentName)),
                DataCell(Text(record.equipmentModel)),
                DataCell(Text(record.serialNumber)),
                DataCell(Text(record.maintenanceManual)),
                DataCell(Text(record.publisher)),
                DataCell(Text(record.subsection1LocalName)),
                DataCell(Text(record.subsection1LocalNumber)),
                DataCell(Text(record.subsection1ManufacturerName)),
                DataCell(Text(record.subsection1EquipmentName)),
                DataCell(Text(record.subsection1EquipmentModel)),
                DataCell(Text(record.subsection1SerialNumber)),
                DataCell(Text(record.subsection1MaintenanceManual)),
                DataCell(Text(record.subsection1Publisher)),
                DataCell(Text(record.subsection2LocalName)),
                DataCell(Text(record.subsection2LocalNumber)),
                DataCell(Text(record.subsection2ManufacturerName)),
                DataCell(Text(record.subsection2EquipmentName)),
                DataCell(Text(record.subsection2EquipmentModel)),
                DataCell(Text(record.subsection2SerialNumber)),
                DataCell(Text(record.subsection2MaintenanceManual)),
                DataCell(Text(record.subsection2Publisher)),
                DataCell(Text(record.subsection3LocalName)),
                DataCell(Text(record.subsection3LocalNumber)),
                DataCell(Text(record.subsection3ManufacturerName)),
                DataCell(Text(record.subsection3EquipmentName)),
                DataCell(Text(record.subsection3EquipmentModel)),
                DataCell(Text(record.subsection3SerialNumber)),
                DataCell(Text(record.subsection3MaintenanceManual)),
                DataCell(Text(record.subsection3Publisher)),
                DataCell(Text(record.subsection4LocalName)),
                DataCell(Text(record.subsection4LocalNumber)),
                DataCell(Text(record.subsection4ManufacturerName)),
                DataCell(Text(record.subsection4EquipmentName)),
                DataCell(Text(record.subsection4EquipmentModel)),
                DataCell(Text(record.subsection4SerialNumber)),
                DataCell(Text(record.subsection4MaintenanceManual)),
                DataCell(Text(record.subsection4Publisher)),
                DataCell(Text(record.businessName)),
                DataCell(Text(record.locationName)),
              ],
            ),
          )
          .toList(),
    ),
  );
}
