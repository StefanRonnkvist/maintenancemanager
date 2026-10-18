import 'package:flutter/material.dart';

import '../models/app_tab.dart';
import '../models/business_entry.dart';
import '../models/equipment_record.dart';
import '../services/local_record_store.dart';
import '../widgets/management_tab_layout.dart';

/// Builds the equipment browser with the starter equipment taxonomy.
class EquipmentTab extends StatelessWidget {
  const EquipmentTab({required this.businesses, super.key});

  final List<BusinessEntry> businesses;

  // These defaults are copied into per-session state so users can add options.
  static const Map<String, List<String>> _equipmentCategories = {
    'Manufacturing and Production Machinery': [
      'CNC machines',
      'Lathes',
      'Lasers',
      'Milling machines',
      'Stamping presses',
      'Robotic welders',
    ],
    'Material Handling and Transport': [
      'Conveyor systems',
      'Forklifts',
      'Cranes',
      'Auger conveyors',
      'Automation',
    ],
    'Heavy Construction and Earthmoving Equipment': [
      'Bulldozers',
      'Excavators',
      'Articulated trucks',
      'Compactors',
    ],
    'Facility and HVAC Systems': [
      'Furnaces',
      'Boilers',
      'Heat exchangers',
      'Industrial compressors',
      'Large-scale water pumps',
    ],
    'Processing and Packaging Equipment': [
      'Extrusion machines',
      'Injection molds',
      'Granulators',
      'Bagging machinery',
      'Shrink-wrapping machines',
    ],
  };

  @override
  Widget build(BuildContext context) => _EquipmentBrowser(
    categories: _equipmentCategories,
    businesses: businesses,
  );
}

class _EquipmentBrowser extends StatefulWidget {
  const _EquipmentBrowser({required this.categories, required this.businesses});

  final Map<String, List<String>> categories;
  final List<BusinessEntry> businesses;

  @override
  State<_EquipmentBrowser> createState() => _EquipmentBrowserState();
}

class _EquipmentBrowserState extends State<_EquipmentBrowser> {
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
  final _newCategoryController = TextEditingController();
  final _newEquipmentController = TextEditingController();
  String? _selectedCategory;
  String? _selectedEquipment;
  String? _selectedBusinessName;
  String? _selectedLocationName;
  final List<EquipmentRecord> _records = [];
  // Copy nested lists to avoid mutating the immutable defaults above.
  late final Map<String, List<String>> _categories = {
    for (final entry in widget.categories.entries)
      entry.key: List<String>.from(entry.value),
  };

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
    _newCategoryController.dispose();
    _newEquipmentController.dispose();
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

  /// Adds a non-empty category locally and selects it for the next entry.
  void _addCategory() {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty || _categories.containsKey(name)) return;
    setState(() {
      _categories[name] = [];
      _selectedCategory = name;
      _selectedEquipment = null;
      _newCategoryController.clear();
    });
  }

  /// Adds a type to the currently selected category without duplicates.
  void _addEquipmentOption() {
    final category = _selectedCategory;
    final name = _newEquipmentController.text.trim();
    if (category == null || name.isEmpty) return;
    final options = _categories[category]!;
    if (options.contains(name)) return;
    setState(() {
      options.add(name);
      _selectedEquipment = name;
      _newEquipmentController.clear();
    });
  }

  /// Builds a record from the form, then appends and persists it.
  void _addEquipment() {
    final record = EquipmentRecord(
      businessName: _selectedBusinessName ?? '',
      locationName: _selectedLocationName ?? '',
      localName: _localNameController.text.trim(),
      localNumber: _localNumberController.text.trim(),
      manufacturerName: _manufacturerNameController.text.trim(),
      equipmentName: _equipmentNameController.text.trim().isNotEmpty
          ? _equipmentNameController.text.trim()
          : (_selectedEquipment ?? ''),
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
    });
    _persistRecords();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories.keys.toList();
    final equipment = _selectedCategory == null
        ? const <String>[]
        : _categories[_selectedCategory] ?? const <String>[];
    final selectedBusiness = widget.businesses
        .where((business) => business.name == _selectedBusinessName)
        .firstOrNull;
    final locations = selectedBusiness?.locations ?? const <BusinessLocation>[];
    final colors = Theme.of(context).colorScheme;

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
                    DropdownButtonFormField<String>(
                      initialValue: categories.contains(_selectedCategory)
                          ? _selectedCategory
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Equipment category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (category) => setState(() {
                        _selectedCategory = category;
                        _selectedEquipment = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newCategoryController,
                            decoration: const InputDecoration(
                              labelText: 'New equipment category',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addCategory(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          tooltip: 'Add category',
                          onPressed: _addCategory,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: equipment.contains(_selectedEquipment)
                          ? _selectedEquipment
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Equipment',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(
                          Icons.precision_manufacturing_outlined,
                        ),
                      ),
                      items: equipment
                          .map(
                            (name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ),
                          )
                          .toList(),
                      onChanged: equipment.isEmpty
                          ? null
                          : (name) => setState(() => _selectedEquipment = name),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newEquipmentController,
                            decoration: const InputDecoration(
                              labelText: 'New equipment',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addEquipmentOption(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          tooltip: 'Add equipment',
                          onPressed: _addEquipmentOption,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Business and location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue:
                          widget.businesses.any(
                            (business) =>
                                business.name == _selectedBusinessName,
                          )
                          ? _selectedBusinessName
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      items: widget.businesses
                          .map(
                            (business) => DropdownMenuItem<String>(
                              value: business.name,
                              child: Text(business.name),
                            ),
                          )
                          .toList(),
                      onChanged: (name) => setState(() {
                        _selectedBusinessName = name;
                        _selectedLocationName = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue:
                          locations.any(
                            (location) =>
                                location.name == _selectedLocationName,
                          )
                          ? _selectedLocationName
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Location Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: locations
                          .map(
                            (location) => DropdownMenuItem<String>(
                              value: location.name,
                              child: Text(location.name),
                            ),
                          )
                          .toList(),
                      onChanged: _selectedBusinessName == null
                          ? null
                          : (name) =>
                                setState(() => _selectedLocationName = name),
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
                    if (_selectedEquipment != null) ...[
                      const SizedBox(height: 20),
                      ListTile(
                        leading: Icon(
                          Icons.check_circle_outline,
                          color: colors.primary,
                        ),
                        title: Text(_selectedEquipment!),
                        subtitle: Text(_selectedCategory!),
                        tileColor: colors.surfaceContainerLow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
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
