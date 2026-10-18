import 'package:flutter/material.dart';

import '../models/app_tab.dart';
import '../models/equipment_record.dart';
import '../services/local_record_store.dart';
import '../widgets/management_tab_layout.dart';

/// Builds the equipment browser and its free-entry equipment form.
class EquipmentTab extends StatefulWidget {
  const EquipmentTab({super.key});

  @override
  State<EquipmentTab> createState() => _EquipmentTabState();
}

class _EquipmentTabState extends State<EquipmentTab> {
  static const _storageKey = 'equipment_records_v1';
  bool _isLoading = true;
  String? _storageError;
  bool _formExpanded = false;
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
  final List<EquipmentRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
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
    );

    if (record.toJson().values.every((value) => value == '')) {
      return;
    }

    setState(() {
      _records.add(record);
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
                _EquipmentTable(records: _records),
              ],
            ),
      form: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              title: const Text('Add equipment'),
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
                    _textField('Equipment category', _categoryController),
                    const SizedBox(height: 16),
                    const SizedBox(height: 24),
                    Text(
                      'Business and location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _textField('Business Name', _businessNameController),
                    const SizedBox(height: 16),
                    _textField('Location Name', _locationNameController),
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
                              child: _textField(
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
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _addEquipment,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Equipment'),
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
  const _EquipmentTable({required this.records});

  final List<EquipmentRecord> records;

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
      headingRowColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      dataRowMinHeight: 52,
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
        DataColumn(label: Text('Business Name')),
        DataColumn(label: Text('Location Name')),
      ],
      rows: records
          .map(
            (record) => DataRow(
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
                DataCell(Text(record.businessName)),
                DataCell(Text(record.locationName)),
              ],
            ),
          )
          .toList(),
    ),
  );
}
