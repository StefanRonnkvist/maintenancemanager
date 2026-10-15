import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import '../models/equipment_record.dart';
import '../models/ui_text_catalog.dart';
import '../widgets/management_record_table.dart';
import '../widgets/management_tab_layout.dart';

class EquipmentTab extends StatelessWidget {
  const EquipmentTab({required this.businesses, required this.text, super.key});

  final List<BusinessEntry> businesses;
  final UiTextCatalog text;

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
    text: text,
  );
}

class _EquipmentBrowser extends StatefulWidget {
  const _EquipmentBrowser({
    required this.categories,
    required this.businesses,
    required this.text,
  });

  final Map<String, List<String>> categories;
  final List<BusinessEntry> businesses;
  final UiTextCatalog text;

  @override
  State<_EquipmentBrowser> createState() => _EquipmentBrowserState();
}

class _EquipmentBrowserState extends State<_EquipmentBrowser> {
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
  bool _formExpanded = false;
  late final Map<String, List<String>> _categories = {
    for (final entry in widget.categories.entries)
      entry.key: List<String>.from(entry.value),
  };

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

  void _addEquipment() {
    final record = EquipmentRecord(
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
      businessName: _selectedBusinessName ?? '',
      locationName: _selectedLocationName ?? '',
    );

    if (record.localName.isEmpty &&
        record.localNumber.isEmpty &&
        record.manufacturerName.isEmpty &&
        record.equipmentName.isEmpty &&
        record.equipmentModel.isEmpty &&
        record.serialNumber.isEmpty &&
        record.maintenanceManual.isEmpty &&
        record.publisher.isEmpty &&
        record.businessName.isEmpty &&
        record.locationName.isEmpty) {
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
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories.keys.toList();
    final equipment = _selectedCategory == null
        ? const <String>[]
        : _categories[_selectedCategory] ?? const <String>[];
    final locations = widget.businesses
        .where((business) => business.name == _selectedBusinessName)
        .expand((business) => business.locations)
        .toList();
    final colors = Theme.of(context).colorScheme;

    return ManagementTabLayout(
      title: widget.text.tabTitle('equipment'),
      recordsTitle: widget.text('recordsTitle', tab: 'equipment'),
      form: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              title: Text(
                widget.text('formTitle', tab: 'equipment'),
                style: Theme.of(context).textTheme.titleMedium,
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
                    DropdownButtonFormField<String>(
                      initialValue: categories.contains(_selectedCategory)
                          ? _selectedCategory
                          : null,
                      decoration: InputDecoration(
                        labelText: widget.text.fieldLabel(
                          'equipment',
                          'category',
                        ),
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
                            decoration: InputDecoration(
                              labelText: widget.text.fieldLabel(
                                'equipment',
                                'newCategory',
                              ),
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
                      decoration: InputDecoration(
                        labelText: widget.text.fieldLabel(
                          'equipment',
                          'equipment',
                        ),
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
                            decoration: InputDecoration(
                              labelText: widget.text.fieldLabel(
                                'equipment',
                                'newEquipment',
                              ),
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
                      widget.text.section('equipment', 'businessLocation'),
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
                      decoration: InputDecoration(
                        labelText: widget.text.fieldLabel(
                          'equipment',
                          'businessName',
                        ),
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
                      decoration: InputDecoration(
                        labelText: widget.text.fieldLabel(
                          'equipment',
                          'locationName',
                        ),
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
                      widget.text.section('equipment', 'details'),
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
                                widget.text.fieldLabel(
                                  'equipment',
                                  'localName',
                                ),
                                _localNameController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _textField(
                                widget.text.fieldLabel(
                                  'equipment',
                                  'localNumber',
                                ),
                                _localNumberController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _textField(
                                widget.text.fieldLabel(
                                  'equipment',
                                  'manufacturerName',
                                ),
                                _manufacturerNameController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _textField(
                                widget.text.fieldLabel(
                                  'equipment',
                                  'equipmentName',
                                ),
                                _equipmentNameController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _textField(
                                widget.text.fieldLabel(
                                  'equipment',
                                  'equipmentModel',
                                ),
                                _equipmentModelController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _textField(
                                widget.text.fieldLabel(
                                  'equipment',
                                  'serialNumber',
                                ),
                                _serialNumberController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _textField(
                                widget.text.fieldLabel(
                                  'equipment',
                                  'maintenanceManual',
                                ),
                                _maintenanceManualController,
                              ),
                            ),
                            SizedBox(
                              width: fieldWidth,
                              child: _textField(
                                widget.text.fieldLabel(
                                  'equipment',
                                  'publisher',
                                ),
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
                        label: Text(widget.text.action('equipment', 'add')),
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
      records: ManagementRecordTable(
        columns: EquipmentRecord.columns,
        rows: [for (final record in _records) record.values],
        emptyMessage: widget.text('emptyMessage', tab: 'equipment'),
      ),
    );
  }
}
