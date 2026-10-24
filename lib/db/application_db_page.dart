import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/business_entry.dart';
import '../services/csv_utils.dart';
import '../services/local_record_store.dart';

/// A lightweight persisted local database for application records.
class ApplicationDbPage extends StatefulWidget {
  const ApplicationDbPage({super.key});

  @override
  State<ApplicationDbPage> createState() => _ApplicationDbPageState();
}

class _ApplicationDbPageState extends State<ApplicationDbPage> {
  // Separate key for flexible user-created name/value records.
  static const String _storageKey = 'application_db_records_v1';

  // CSV actions in this page operate on these persisted tab collections.
  static const Map<String, String> _managedStores = {
    'Equipment': 'equipment_records_v1',
    'Spare Parts': 'spare_parts_records_v1',
    'People': 'people_records_v1',
    'Business': 'business_records_v1',
    'Work Order': 'work_order_records_v1',
    'Messages': 'message_records_v1',
  };

  final List<_AppRecord> _records = <_AppRecord>[];
  final Map<String, List<Map<String, dynamic>>> _managedRecords = {};
  String? _selectedTable;
  bool _isLoading = true;
  String? _storageError;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Loads custom records and the management collections exposed for CSV.
  Future<void> _loadRecords() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final String? stored = preferences.getString(_storageKey);
      if (stored != null) {
        final List<dynamic> decoded = jsonDecode(stored) as List<dynamic>;
        _records
          ..clear()
          ..addAll(
            decoded.map(
              (dynamic item) => _AppRecord.fromJson(
                Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
              ),
            ),
          );
      }
      for (final entry in _managedStores.entries) {
        _managedRecords[entry.key] = await LocalRecordStore.read(entry.value);
        // Backfill columns so older records export with the current schema.
        if (entry.key == 'Equipment' || entry.key == 'Work Order') {
          final storedRecords = _managedRecords[entry.key]!;
          var changed = false;
          for (final record in storedRecords) {
            for (final field in _columnsFor(entry.key)) {
              if (!record.containsKey(field)) {
                record[field] = switch (field) {
                  'equipmentSelected' ||
                  'matchingPeople' ||
                  'principlePeople' ||
                  'sparePartsNeeded' => <Map<String, dynamic>>[],
                  _ => '',
                };
                changed = true;
              }
            }
          }
          if (changed) {
            await LocalRecordStore.write(entry.value, storedRecords);
          }
        }
      }
    } catch (error) {
      _storageError = 'Could not read local records: $error';
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  /// Saves only the page's editable key/value records.
  Future<void> _persistRecords() async {
    try {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      final bool saved = await preferences.setString(
        _storageKey,
        jsonEncode(_records.map((record) => record.toJson()).toList()),
      );
      if (!saved) throw StateError('The device did not save the records.');
      if (mounted) setState(() => _storageError = null);
    } catch (error) {
      if (mounted) {
        setState(() => _storageError = 'Could not save local records: $error');
      }
    }
  }

  Future<void> _createRecord() async {
    final _AppRecord? record = await _showRecordDialog();
    if (record == null) return;
    setState(() => _records.insert(0, record));
    await _persistRecords();
  }

  Future<void> _updateRecord(_AppRecord current) async {
    final _AppRecord? updated = await _showRecordDialog(existing: current);
    if (updated == null) return;
    final int index = _records.indexWhere((record) => record.id == current.id);
    if (index < 0) return;
    setState(() => _records[index] = updated);
    await _persistRecords();
  }

  Future<void> _deleteRecord(_AppRecord record) async {
    setState(() => _records.removeWhere((item) => item.id == record.id));
    await _persistRecords();
  }

  Future<bool> _confirmDeleteAll(String collectionName) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete all records?'),
          content: Text(
            'This will permanently delete all records in $collectionName. '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete all'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _deleteAllApplicationRecords() async {
    if (_records.isEmpty ||
        !await _confirmDeleteAll('the application records')) {
      return;
    }
    setState(_records.clear);
    await _persistRecords();
  }

  Future<void> _deleteAllSelectedTableRecords() async {
    final table = _selectedTable;
    if (table == null) return;
    final records = _managedRecords[table] ?? const [];
    if (records.isEmpty ||
        !await _confirmDeleteAll('the $table table')) {
      return;
    }
    try {
      await LocalRecordStore.write(_managedStores[table]!, <Map<String, Object?>>[]);
      if (mounted) {
        setState(() {
          _managedRecords[table] = [];
          _storageError = null;
        });
        _showMessage('Deleted all $table records.');
      }
    } catch (error) {
      if (mounted) {
        setState(() => _storageError = 'Could not delete records: $error');
      }
    }
  }

  /// Builds a header row and properly quoted data rows for the selected table.
  String _encodeCsv(
    List<Map<String, dynamic>> records, {
    required List<String> columns,
    required String table,
  }) {
    final rows = <List<String>>[
      columns,
      for (final record in records)
        columns.map((column) {
          final value = record[column];
          if (table == 'Business' && column.startsWith('location')) {
            final match = RegExp(r'^location(\d+)([A-Z].*)$')
                .firstMatch(column);
            if (match != null) {
              final locationIndex = int.parse(match.group(1)!);
              final suffix = match.group(2)!;
              final locations = BusinessEntry.decodeLocationList(
                record['locations'],
              );
              final location = locationIndex <= locations.length
                  ? locations[locationIndex - 1]
                  : null;
              final key = switch (suffix) {
                'Name' => 'name',
                'Address' => 'address',
                'DirectPhone' => 'directPhone',
                'NearestAirport' => 'nearestAirport',
                _ => '',
              };
              if (location != null && key.isNotEmpty) {
                return location[key] as String? ?? '';
              }
              return '';
            }
          }
          if (table == 'Business' && column == 'locations') {
            return jsonEncode(BusinessEntry.decodeLocationList(value));
          }
          if (table == 'People' && column == 'airports') {
            return jsonEncode(value is List ? value : <Object?>[]);
          }
          if (table == 'Work Order' &&
              (column == 'matchingPeople' ||
                  column == 'principlePeople' ||
                  column == 'sparePartsNeeded')) {
            Object? decoded = value;
            if (value is String) {
              try {
                decoded = jsonDecode(value);
              } on FormatException {
                decoded = value;
              }
            }
            return decoded is List ? jsonEncode(decoded) : jsonEncode([]);
          }
          return value is String ? value : jsonEncode(value ?? '');
        }).toList(),
    ];
    return rows.map((row) => row.map(_escapeCsv).join(',')).join('\r\n');
  }

  /// Defines the CSV field order for each supported management category.
  List<String> _columnsFor(String table) => switch (table) {
    'Equipment' => [
      'equipmentCategory',
      'localName',
      'localNumber',
      'manufacturerName',
      'equipmentName',
      'equipmentModel',
      'serialNumber',
      'maintenanceManual',
      'publisher',
      for (var subsection = 1; subsection <= 4; subsection++) ...[
        'subsection${subsection}LocalName',
        'subsection${subsection}LocalNumber',
        'subsection${subsection}ManufacturerName',
        'subsection${subsection}EquipmentName',
        'subsection${subsection}EquipmentModel',
        'subsection${subsection}SerialNumber',
        'subsection${subsection}MaintenanceManual',
        'subsection${subsection}Publisher',
      ],
      'businessName',
      'locationName',
    ],
    'Spare Parts' => [
      'oemPartNumber',
      'oemDescription',
      'vendorPartNumber',
      'vendorDescription',
      'serialNumber',
      'vendorName',
      'locationName',
      'quantityInStock',
      'storageLocation',
    ],
    'People' => [
      'name',
      'title',
      'businessName',
      'locationName',
      'directPhone',
      'directPhoneExtension',
      'cellPhone',
      'email',
    ],
    'Business' => [
      'name',
      'businessType',
      'address',
      'directPhone',
      'nearestAirport',
      for (var location = 1; location <= 4; location++) ...[
        'location${location}Name',
        'location${location}Address',
        'location${location}DirectPhone',
        'location${location}NearestAirport',
      ],
    ],
    'Work Order' => [
      'workOrderNumber',
      'businessName',
      'locationName',
      'locationAddress',
      'locationDirectPhone',
      'locationAirport',
      'equipmentSelected',
      'matchingPeople',
      'notes',
      'sparePartsNeeded',
      'principlePeople',
      'componentCategory',
      'component',
      'completed',
    ],
    'Messages' => ['business', 'location', 'to', 'cc', 'subject', 'message'],
    _ => const ['name', 'value', 'updatedAt'],
  };

  String _escapeCsv(String value) => '"${value.replaceAll('"', '""')}"';

  List<List<String>> _parseCsv(String source) => CsvUtils.parse(source);



  Future<void> _exportCsv(String? table) async {
    try {
      if (table == null || !_managedStores.containsKey(table)) {
        throw FormatException('Unknown table: $table');
      }
      final columns = _columnsFor(table);
      final records = await LocalRecordStore.read(_managedStores[table]!);
      final csv = _encodeCsv(records, columns: columns, table: table);
      final safeName = table.toLowerCase().replaceAll(' ', '_');
      await _saveCsv('${safeName}_records.csv', csv);
    } catch (error) {
      _showMessage('Could not export CSV: $error');
    }
  }

  Future<void> _importCsv(String? table) async {
    try {
      if (table == null || !_managedStores.containsKey(table)) {
        throw FormatException('Unknown table: $table');
      }
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      final bytes =
          file.bytes ??
          (file.path == null ? null : await XFile(file.path!).readAsBytes());
      if (bytes == null) {
        throw const FormatException('Unable to read selected CSV.');
      }
      var source = utf8.decode(bytes, allowMalformed: false);
      if (source.startsWith('\uFEFF')) source = source.substring(1);
      final rows = _parseCsv(source);
      final expected = _columnsFor(table);
      if (rows.isEmpty) throw const FormatException('CSV is empty.');
      final headers = rows.first.map((value) => value.trim()).toList();
      if (headers.toSet().length != headers.length) {
        throw const FormatException('CSV headers must not contain duplicates.');
      }
      final legacyBusinessHeaders =
          table == 'Business' &&
          headers.length == 7 &&
          headers.toSet().containsAll([
            'name',
            'businessType',
            'address',
            'directPhone',
            'nearestAirport',
            'locations',
            'airports',
          ]);
      if (!legacyBusinessHeaders &&
          (headers.length != expected.length ||
              !headers.toSet().containsAll(expected))) {
        throw FormatException('CSV headers do not match the $table template.');
      }
      final importColumns = legacyBusinessHeaders
          ? const [
              'name',
              'businessType',
              'address',
              'directPhone',
              'nearestAirport',
              'locations',
              'airports',
            ]
          : expected;
      final indexes = [
        for (final column in importColumns) headers.indexOf(column),
      ];
      final imported = <Map<String, dynamic>>[];
      for (var rowIndex = 1; rowIndex < rows.length; rowIndex++) {
        final row = rows[rowIndex];
        if (row.length != headers.length) {
          throw FormatException(
            'CSV row ${rowIndex + 1} has ${row.length} fields; '
            'expected ${headers.length}.',
          );
        }
        final mapped = <String, dynamic>{};
        for (
          var columnIndex = 0;
          columnIndex < importColumns.length;
          columnIndex++
        ) {
          final name = importColumns[columnIndex];
          final value = row[indexes[columnIndex]];
          if ((table == 'People' && name == 'airports') ||
              (table == 'Business' && name == 'locations')) {
            try {
              mapped[name] = jsonDecode(value.isEmpty ? '[]' : value);
            } on FormatException catch (error) {
              throw FormatException(
                'Invalid JSON in CSV row ${rowIndex + 1}, column "$name": '
                '${error.message}',
              );
            }
            if (mapped[name] is! List) {
              throw FormatException(
                'CSV row ${rowIndex + 1}, column "$name" must contain a JSON list.',
              );
            }
          } else if (table == 'Work Order' &&
              (name == 'equipmentSelected' ||
                  name == 'matchingPeople' ||
                  name == 'principlePeople' ||
                  name == 'sparePartsNeeded') &&
              value.isNotEmpty) {
            try {
              final decoded = jsonDecode(value);
              if (decoded is! List || decoded.any((item) => item is! Map)) {
                throw const FormatException('Expected a JSON list of records.');
              }
              mapped[name] = jsonEncode(
                decoded
                    .whereType<Map>()
                    .map((item) => Map<String, dynamic>.from(item))
                    .toList(),
              );
            } on FormatException catch (error) {
              throw FormatException(
                'Invalid JSON in CSV row ${rowIndex + 1}, column "$name": '
                '${error.message}',
              );
            }
          } else if (table == 'Spare Parts' && name == 'storageLocation') {
            mapped['location'] = value;
          } else {
            mapped[name] = value;
          }
        }
        if (table == 'Business') {
          final businessLocations = <Map<String, String>>[];
          if (legacyBusinessHeaders) {
            final legacyLocations = mapped['locations'];
            if (legacyLocations is List) {
              businessLocations.addAll(
                legacyLocations.whereType<Map>().map(
                  (location) => Map<String, String>.from(location),
                ),
              );
            }
          } else {
            for (var location = 1; location <= 4; location++) {
              final locationFields = {
                'name':
                    mapped.remove('location${location}Name') as String? ?? '',
                'address':
                    mapped.remove('location${location}Address') as String? ??
                    '',
                'directPhone':
                    mapped.remove('location${location}DirectPhone')
                        as String? ??
                    '',
                'nearestAirport':
                    mapped.remove('location${location}NearestAirport')
                        as String? ??
                    '',
              };
              if (locationFields.values.any((value) => value.isNotEmpty)) {
                businessLocations.add(locationFields);
              }
            }
          }
          if (businessLocations.isNotEmpty || mapped.containsKey('locations')) {
            mapped['locations'] = businessLocations;
          }
        }
        if (mapped.values.any((value) => '$value'.isNotEmpty)) {
          imported.add(mapped);
        }
      }
      if (imported.isEmpty) {
        throw const FormatException('No valid rows found in CSV.');
      }
      final key = _managedStores[table]!;
      final existing = await LocalRecordStore.read(key);
      final merged = [...imported, ...existing];
      await LocalRecordStore.write(key, merged);
      if (!mounted) return;
      setState(() => _managedRecords[table] = merged);
      if (mounted) _showMessage('Imported ${imported.length} $table records.');
    } catch (error) {
      _showMessage('Could not import CSV: $error');
    }
  }

  Future<void> _shareTemplate(String? table, {required bool example}) async {
    if (table == null || !_managedStores.containsKey(table)) {
      _showMessage('Enter a valid table name.');
      return;
    }
    final columns = _columnsFor(table);
    final sample = <String, dynamic>{for (final column in columns) column: ''};
    if (example) {
      if (table == 'Equipment') {
        sample['equipmentName'] = 'Example equipment';
        for (var subsection = 1; subsection <= 4; subsection++) {
          sample['subsection${subsection}LocalName'] =
              'Subsection $subsection local item';
        }
      }
      if (table == 'Spare Parts') {
        sample['oemPartNumber'] = 'PART-001';
        sample['oemDescription'] = 'Example part';
        sample['vendorPartNumber'] = 'VENDOR-001';
        sample['vendorDescription'] = 'Example vendor part';
        sample['serialNumber'] = 'SERIAL-001';
        sample['vendorName'] = 'Example Vendor';
        sample['locationName'] = 'Main Warehouse';
        sample['quantityInStock'] = '10';
        sample['storageLocation'] = 'A-01';
      }
      if (table == 'People' || table == 'Business') sample['name'] = 'Example';
      if (table == 'Business') {
        for (var location = 1; location <= 4; location++) {
          sample['location${location}Name'] = 'Location $location';
          sample['location${location}Address'] = '$location Example Street';
          sample['location${location}DirectPhone'] = '555-010$location';
          sample['location${location}NearestAirport'] = 'ABC';
        }
      }
      if (table == 'Work Order') {
        sample['workOrderNumber'] =
            '${DateTime.now().day.toString().padLeft(2, '0')}'
            '${DateTime.now().month.toString().padLeft(2, '0')}'
            '${DateTime.now().year.toString().padLeft(4, '0')}-1';
        sample['businessName'] = 'Example Business';
        sample['locationName'] = 'Example Location';
        sample['componentCategory'] = 'Electrical Components';
        sample['component'] = 'Power Supply';
        sample['notes'] = 'Example work order notes';
        sample['matchingPeople'] = '[{"name":"Example Contact","title":"Maintenance Manager","businessName":"Example Business","locationName":"Example Location","directPhone":"555-0100","directPhoneExtension":"123","cellPhone":"555-0101","email":"contact@example.com"}]';
        sample['principlePeople'] = '[{"name":"Example Person","businessName":"Example Principle","locationName":"Example Location"}]';
      }
      if (table == 'Messages') sample['subject'] = 'Example message';
    }
    for (final field in ['locations', 'airports']) {
      if (sample.containsKey(field)) {
        sample[field] = '[]';
      }
    }
    final csv = _encodeCsv(
      example ? [sample] : [],
      columns: columns,
      table: table,
    );
    try {
      final templateType = example ? 'example' : 'blank';
      final filename =
          '${table.toLowerCase().replaceAll(' ', '_')}_${templateType}_template.csv';
      await _saveCsv(filename, csv);
    } catch (error) {
      _showMessage('Could not create CSV template: $error');
    }
  }

  Future<void> _saveCsv(String filename, String csv) async {
    final bytes = Uint8List.fromList(utf8.encode(csv));
    if (kIsWeb) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: 'text/csv', name: filename)],
          fileNameOverrides: [filename],
          subject: filename,
        ),
      );
      if (mounted) _showMessage('CSV export ready to save or share.');
      return;
    }

    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save CSV file',
      fileName: filename,
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: bytes,
    );
    if (!mounted) return;
    if (outputPath != null) {
      _showMessage('Saved CSV: $outputPath');
      return;
    }

    // A null path means the user canceled the save dialog; do not silently
    // switch to a share sheet, which can make the export appear unsuccessful.
    _showMessage('CSV export canceled.');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<_AppRecord?> _showRecordDialog({_AppRecord? existing}) async {
    final TextEditingController name = TextEditingController(
      text: existing?.name ?? '',
    );
    final TextEditingController value = TextEditingController(
      text: existing?.value ?? '',
    );
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final _AppRecord? result = await showDialog<_AppRecord>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          existing == null
              ? 'Add application record'
              : 'Edit application record',
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name / key'),
                validator: (String? input) =>
                    input == null || input.trim().isEmpty
                    ? 'Enter a name.'
                    : null,
              ),
              TextFormField(
                controller: value,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Value'),
                validator: (String? input) =>
                    input == null || input.trim().isEmpty
                    ? 'Enter a value.'
                    : null,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(
                context,
                _AppRecord(
                  id:
                      existing?.id ??
                      DateTime.now().microsecondsSinceEpoch.toString(),
                  name: name.text.trim(),
                  value: value.text.trim(),
                  updatedAt: DateTime.now(),
                ),
              );
            },
            child: Text(existing == null ? 'Create' : 'Save'),
          ),
        ],
      ),
    );
    name.dispose();
    value.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final isPhoneLayout = MediaQuery.sizeOf(context).width < 600;
    final controls = Row(
      children: <Widget>[
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            initialValue: _selectedTable ?? _managedStores.keys.first,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Table',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _managedStores.keys
                .map(
                  (table) => DropdownMenuItem<String>(
                    value: table,
                    child: Text(table, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (table) {
              if (table != null) setState(() => _selectedTable = table);
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Import CSV',
          onPressed: () => _importCsv(_selectedTable),
          icon: const Icon(Icons.file_open_outlined),
        ),
        IconButton(
          tooltip: 'Export CSV',
          onPressed: () => _exportCsv(_selectedTable),
          icon: const Icon(Icons.file_download_outlined),
        ),
        IconButton(
          tooltip: 'Share example CSV template',
          onPressed: () => _shareTemplate(_selectedTable, example: true),
          icon: const Icon(Icons.description_outlined),
        ),
        IconButton(
          tooltip: 'Share blank CSV template',
          onPressed: () => _shareTemplate(_selectedTable, example: false),
          icon: const Icon(Icons.note_add_outlined),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _createRecord,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
        IconButton(
          tooltip: 'Delete all records in selected table',
          onPressed:
              (_selectedTable != null &&
                      (_managedRecords[_selectedTable!]?.isNotEmpty ?? false))
                  ? _deleteAllSelectedTableRecords
                  : null,
          color: Theme.of(context).colorScheme.error,
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
        IconButton(
          tooltip: 'Delete all application records',
          onPressed: _records.isNotEmpty ? _deleteAllApplicationRecords : null,
          color: Theme.of(context).colorScheme.error,
          icon: const Icon(Icons.delete_forever_outlined),
        ),
      ],
    );
    final recordList = _selectedTable == null && _records.isEmpty
        ? const Center(
            child: Text('No records yet. Add a record to get started.'),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _records.length,
            itemBuilder: (BuildContext context, int index) {
              final _AppRecord record = _records[index];
              return Card(
                child: ListTile(
                  title: Text(record.name),
                  subtitle: Text(record.value),
                  isThreeLine: record.value.contains('\n'),
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: 'Edit record',
                        onPressed: () => _updateRecord(record),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Delete record',
                        onPressed: () => _deleteRecord(record),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: isPhoneLayout
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Local application records',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: controls,
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Local application records',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: controls,
                    ),
                  ],
                ),
        ),
        if (_storageError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              _storageError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: isPhoneLayout ? 600 : MediaQuery.sizeOf(context).width,
              child: recordList,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppRecord {
  const _AppRecord({
    required this.id,
    required this.name,
    required this.value,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String value;
  final DateTime updatedAt;

  Map<String, Object> toJson() => <String, Object>{
    'id': id,
    'name': name,
    'value': value,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory _AppRecord.fromJson(Map<String, dynamic> json) => _AppRecord(
    id: json['id'] as String,
    name: json['name'] as String,
    value: json['value'] as String,
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );
}
