import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  final List<Map<String, dynamic>> _records = [];
  Map<String, List<String>> _componentOptions = const {};
  String? _selectedComponentCategory;
  String? _selectedComponent;
  String? _selectedBusinessName;
  String? _selectedLocationName;
  Map<String, dynamic>? _editingRecord;
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

  List<BusinessEntry> get _principlePeople {
    final principleBusinessNames = widget.businessEntries
        .where((business) => business.businessType.trim() == 'Principle')
        .map((business) => business.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet();
    return widget.peopleEntries
        .where(
          (person) =>
              person.name.trim().isNotEmpty &&
              principleBusinessNames.contains(person.businessName.trim()),
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
    super.dispose();
  }

  Future<void> _printWorkOrder() async {
    final record = _editingRecord;
    if (record == null) return;
    try {
      final document = pw.Document();
      document.addPage(
        pw.MultiPage(
          pageFormat: pdf.PdfPageFormat.letter.portrait,
          margin: const pw.EdgeInsets.all(24),
          build: (_) => [
            pw.Text(
              'Work Order',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 6),
            for (final (label, key) in const [
              ('Work Order Number', 'workOrderNumber'),
              ('Business Name', 'businessName'),
              ('Location Name', 'locationName'),
              ('Location Address', 'locationAddress'),
              ('Location Direct Phone Number', 'locationDirectPhone'),
              ('Location Airports', 'locationAirport'),
              ('Notes', 'notes'),
              ('Component Category', 'componentCategory'),
              ('Component', 'component'),
            ]) ...[
              pw.Text(
                '$label: ${_formatPrintValue(record[key])}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 2),
            ],
            pw.SizedBox(height: 12),
            ..._printContactsTable(
              'People at this business and location',
              record['matchingPeople'],
              showEmptyMessage: true,
              includeTitle: true,
            ),
            pw.SizedBox(height: 12),
            ..._printContactsTable(
              'People at Principle businesses',
              record['principlePeople'],
              showEmptyMessage: true,
              includeTitle: true,
            ),
            pw.SizedBox(height: 12),
          ],
          footer: (context) => pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.only(top: 6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: pdf.PdfColors.grey, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Work Order ${_formatPrintValue(record['workOrderNumber'])}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (_) async => document.save());
    } catch (error) {
      if (mounted) _showMessage('Could not print work order: $error');
    }
  }

  List<pw.Widget> _printContactsTable(
    String title,
    Object? value, {
    required bool showEmptyMessage,
    bool includeTitle = false,
  }) {
    List<Map<String, dynamic>> contacts = const [];
    try {
      final decoded = jsonDecode(value?.toString() ?? '[]');
      if (decoded is List) {
        contacts = decoded
            .whereType<Map>()
            .map((person) => Map<String, dynamic>.from(person))
            .toList();
      }
    } on FormatException {
      // Show an empty-state message if saved contact data is malformed.
    }

    return [
      if (includeTitle) ...[
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 2),
      ],
      if (contacts.isEmpty)
        pw.Text('No contacts available.')
      else
        pw.TableHelper.fromTextArray(
          headers: const [
            'Name',
            'Title',
            'Phone',
            'Ext',
            'Cell Phone',
            'Email',
          ],
          data: [
            for (final contact in contacts)
              [
                for (final key in const [
                  'name',
                  'title',
                  'directPhone',
                  'directPhoneExtension',
                  'cellPhone',
                  'email',
                ])
                  contact[key]?.toString() ?? '',
              ],
          ],
          headerStyle: pw.TextStyle(
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
          cellStyle: const pw.TextStyle(fontSize: 8),
          headerDecoration: const pw.BoxDecoration(
            color: pdf.PdfColors.grey300,
          ),
          border: pw.TableBorder.all(color: pdf.PdfColors.grey, width: 0.5),
          cellPadding: const pw.EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 3,
          ),
          columnWidths: const {
            0: pw.FlexColumnWidth(0.8),
            1: pw.FlexColumnWidth(0.35),
            2: pw.FlexColumnWidth(0.4),
            3: pw.FlexColumnWidth(0.25),
            4: pw.FlexColumnWidth(0.4),
            5: pw.FlexColumnWidth(0.7),
          },
        ),
    ];
  }

  String _formatPrintValue(Object? value) => value?.toString() ?? '';

  void _editWorkOrder(Map<String, dynamic> record) {
    setState(() {
      _editingRecord = record;
      _formExpanded = true;
      _selectedBusinessName = _businessOptions.contains(record['businessName'])
          ? record['businessName'] as String
          : null;
      _selectedLocationName = _locationOptions.contains(record['locationName'])
          ? record['locationName'] as String
          : null;
      _selectedComponentCategory =
          _componentOptions.containsKey(record['componentCategory'])
          ? record['componentCategory'] as String
          : null;
      _selectedComponent =
          (_componentOptions[_selectedComponentCategory] ?? const []).contains(
            record['component'],
          )
          ? record['component'] as String
          : null;
      _businessNameController.text = record['businessName']?.toString() ?? '';
      _locationNameController.text = record['locationName']?.toString() ?? '';
      _locationAddressController.text =
          record['locationAddress']?.toString() ?? '';
      _locationPhoneController.text =
          record['locationDirectPhone']?.toString() ?? '';
      _locationAirportController.text =
          record['locationAirport']?.toString() ?? '';
      _notesController.text = record['notes']?.toString() ?? '';
    });
  }

  Future<void> _saveCurrentWorkOrder() async {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.year.toString().padLeft(4, '0')}';
    final sequence = _records.length + 1;
    final record = <String, dynamic>{
      'workOrderNumber':
          _editingRecord?['workOrderNumber'] ?? '$date-$sequence',
      'businessName': _businessNameController.text.trim(),
      'locationName': _locationNameController.text.trim(),
      'locationAddress': _locationAddressController.text.trim(),
      'locationDirectPhone': _locationPhoneController.text.trim(),
      'locationAirport': _locationAirportController.text.trim(),
      'notes': _notesController.text.trim(),
      'matchingPeople': jsonEncode([
        for (final person in _matchingPeople)
          {
            'name': person.name,
            'title': person.title,
            //'businessName': person.businessName,
            //'locationName': person.locationName,
            'directPhone': person.directPhone,
            'directPhoneExtension': person.directPhoneExtension,
            'cellPhone': person.cellPhone,
            'email': person.email,
          },
      ]),
      'principlePeople': jsonEncode([
        for (final person in _principlePeople)
          {
            'name': person.name,
            'title': person.title,
            //'businessName': person.businessName,
            //'locationName': person.locationName,
            'directPhone': person.directPhone,
            'directPhoneExtension': person.directPhoneExtension,
            'cellPhone': person.cellPhone,
            'email': person.email,
          },
      ]),
      'componentCategory': _selectedComponentCategory ?? '',
      'component': _selectedComponent ?? '',
    };
    if (record.values.every(
      (value) => value == null || (value is String && value.isEmpty),
    )) {
      return;
    }
    final updated = [..._records];
    final editingRecord = _editingRecord;
    if (editingRecord == null) {
      updated.insert(0, record);
    } else {
      final index = updated.indexOf(editingRecord);
      if (index == -1) return;
      updated[index] = record;
    }
    try {
      await LocalRecordStore.write(_storageKey, updated);
      if (!mounted) return;
      setState(() {
        _records
          ..clear()
          ..addAll(updated);
        _editingRecord = null;
        _selectedBusinessName = null;
        _selectedLocationName = null;
        _selectedComponentCategory = null;
        _selectedComponent = null;
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
                      const SizedBox(height: 24),
                      _PrinciplePeopleTable(people: _principlePeople),
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
                      Wrap(
                        spacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: _saveCurrentWorkOrder,
                            icon: Icon(
                              _editingRecord == null
                                  ? Icons.save_outlined
                                  : Icons.update_outlined,
                            ),
                            label: Text(
                              _editingRecord == null
                                  ? 'Save Work Order'
                                  : 'Update Work Order',
                            ),
                          ),
                          if (_editingRecord != null)
                            OutlinedButton.icon(
                              onPressed: _printWorkOrder,
                              icon: const Icon(Icons.print_outlined),
                              label: const Text('Print Work Order'),
                            ),
                        ],
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
        WorkOrderTable(records: _records, onRowTap: _editWorkOrder),
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
                DataColumn(label: Text('Business Name')),
                DataColumn(label: Text('Location Name')),
                DataColumn(label: Text('Direct Phone')),
                DataColumn(label: Text('Extension')),
                DataColumn(label: Text('Cell Phone')),
                DataColumn(label: Text('eMail')),
              ],
              rows: [
                for (final person in people)
                  DataRow(
                    cells: [
                      DataCell(Text(person.name)),
                      DataCell(Text(person.title)),
                      DataCell(Text(person.businessName)),
                      DataCell(Text(person.locationName)),
                      DataCell(Text(person.directPhone)),
                      DataCell(Text(person.directPhoneExtension)),
                      DataCell(Text(person.cellPhone)),
                      DataCell(Text(person.email)),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PrinciplePeopleTable extends StatelessWidget {
  const _PrinciplePeopleTable({required this.people});

  final List<BusinessEntry> people;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'People at Principle businesses',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (people.isEmpty)
          const Text('No people are associated with a Principle business.')
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Business Name')),
                DataColumn(label: Text('Business Location')),
              ],
              rows: [
                for (final person in people)
                  DataRow(
                    cells: [
                      DataCell(Text(person.name)),
                      DataCell(Text(person.businessName)),
                      DataCell(Text(person.locationName)),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
