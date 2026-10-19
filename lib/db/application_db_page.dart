import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _selectedTable = 'Equipment';
  final TextEditingController _selectedTableController = TextEditingController(
    text: 'Equipment',
  );
  bool _isLoading = true;
  String? _storageError;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _selectedTableController.dispose();
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
        // Backfill fields introduced after older equipment records were saved.
        if (entry.key == 'Equipment') {
          final equipment = _managedRecords[entry.key]!;
          if (equipment.isNotEmpty &&
              !equipment.first.containsKey('equipmentCategory')) {
            for (final record in equipment) {
              record.putIfAbsent('equipmentCategory', () => '');
              record.putIfAbsent('businessName', () => '');
              record.putIfAbsent('locationName', () => '');
              record.putIfAbsent('maintenanceManual', () => '');
              record.putIfAbsent('publisher', () => '');
            }
            await LocalRecordStore.write(entry.value, equipment);
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

  /// Builds a header row and properly quoted data rows for the selected table.
  String _encodeCsv(
    List<Map<String, dynamic>> records, {
    required List<String> columns,
  }) {
    final rows = <List<String>>[
      columns,
      for (final record in records)
        columns.map((column) {
          final value = record[column];
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
      'quantityInStock',
      'location',
    ],
    'People' => [
      'name',
      'title',
      'address',
      'directPhone',
      'directPhoneExtension',
      'businessType',
      'cellPhone',
      'email',
      'businessName',
      'locationName',
      'nearestAirport',
      'locations',
      'airports',
    ],
    'Business' => [
      'name',
      'title',
      'address',
      'directPhone',
      'directPhoneExtension',
      'businessType',
      'cellPhone',
      'email',
      'businessName',
      'locationName',
      'nearestAirport',
      'locations',
      'airports',
    ],
    'Work Order' => [
      'businessName',
      'locationName',
      'locationAddress',
      'locationDirectPhone',
      'locationAirport',
    ],
    'Messages' => ['to', 'cc', 'subject', 'message'],
    _ => const ['name', 'value', 'updatedAt'],
  };

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '"');
    return '"$escaped"';
  }

  List<List<String>> _parseCsv(String source) {
    final rows = <List<String>>[];
    var row = <String>[];
    final field = StringBuffer();
    var quoted = false;
    for (var index = 0; index < source.length; index++) {
      final char = source[index];
      if (quoted) {
        if (char == '"') {
          if (index + 1 < source.length && source[index + 1] == '"') {
            field.write('"');
            index++;
          } else {
            quoted = false;
          }
        } else {
          field.write(char);
        }
      } else if (char == '"') {
        quoted = true;
      } else if (char == ',') {
        row.add(field.toString());
        field.clear();
      } else if (char == '\n' || char == '\r') {
        if (char == '\r' &&
            index + 1 < source.length &&
            source[index + 1] == '\n') {
          index++;
        }
        row.add(field.toString());
        field.clear();
        if (row.any((cell) => cell.isNotEmpty)) rows.add(row);
        row = <String>[];
      } else {
        field.write(char);
      }
    }
    if (quoted) {
      throw const FormatException('CSV contains an unclosed quoted field.');
    }
    if (field.length > 0 || row.isNotEmpty) {
      row.add(field.toString());
      if (row.any((cell) => cell.isNotEmpty)) rows.add(row);
    }
    return rows;
  }

  Future<void> _exportCsv(String table) async {
    try {
      if (!_managedStores.containsKey(table)) {
        throw FormatException('Unknown table: $table');
      }
      final columns = _columnsFor(table);
      final records = _managedRecords[table] ?? const <Map<String, dynamic>>[];
      final csv = _encodeCsv(records, columns: columns);
      final safeName = table.toLowerCase().replaceAll(' ', '_');
      await _saveCsv('${safeName}_records.csv', csv);
    } catch (error) {
      _showMessage('Could not export CSV: $error');
    }
  }

  Future<void> _importCsv(String table) async {
    try {
      if (!_managedStores.containsKey(table)) {
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
      final rows = _parseCsv(utf8.decode(bytes, allowMalformed: false));
      final expected = _columnsFor(table);
      if (rows.isEmpty) throw const FormatException('CSV is empty.');
      final headers = rows.first.map((value) => value.trim()).toList();
      if (headers.length != expected.length ||
          !headers.toSet().containsAll(expected)) {
        throw FormatException('CSV headers do not match the $table template.');
      }
      final indexes = [for (final column in expected) headers.indexOf(column)];
      final imported = <Map<String, dynamic>>[];
      for (final row in rows.skip(1)) {
        if (row.length < headers.length) continue;
        final mapped = <String, dynamic>{};
        for (
          var columnIndex = 0;
          columnIndex < expected.length;
          columnIndex++
        ) {
          final name = expected[columnIndex];
          final value = row[indexes[columnIndex]];
          if ((table == 'People' || table == 'Business') &&
              (name == 'airports' || name == 'locations')) {
            try {
              mapped[name] = jsonDecode(value);
            } catch (_) {
              mapped[name] = <dynamic>[];
            }
          } else {
            mapped[name] = value;
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
      final existing = _managedRecords[table] ?? <Map<String, dynamic>>[];
      final merged = [...imported, ...existing];
      await LocalRecordStore.write(key, merged);
      setState(() => _managedRecords[table] = merged);
      if (mounted) _showMessage('Imported ${imported.length} $table records.');
    } catch (error) {
      _showMessage('Could not import CSV: $error');
    }
  }

  Future<void> _shareTemplate(String table, {required bool example}) async {
    if (!_managedStores.containsKey(table)) {
      _showMessage('Enter a valid table name.');
      return;
    }
    final columns = _columnsFor(table);
    final sample = <String, dynamic>{for (final column in columns) column: ''};
    if (example) {
      if (table == 'Equipment') sample['equipmentName'] = 'Example equipment';
      if (table == 'Spare Parts') sample['oemPartNumber'] = 'PART-001';
      if (table == 'People' || table == 'Business') sample['name'] = 'Example';
      if (table == 'Work Order') {
        sample['businessName'] = 'Example Business';
        sample['locationName'] = 'Example Location';
      }
      if (table == 'Messages') sample['subject'] = 'Example message';
    }
    for (final field in ['locations', 'airports']) {
      if (sample.containsKey(field)) {
        sample[field] = '[]';
      }
    }
    final csv = _encodeCsv(example ? [sample] : [], columns: columns);
    try {
      final filename =
          '${table.toLowerCase().replaceAll(' ', '_')}_template.csv';
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
          files: [XFile.fromData(bytes, mimeType: 'text/csv')],
          fileNameOverrides: [filename],
          subject: filename,
        ),
      );
      return;
    }

    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save CSV file',
      fileName: filename,
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: bytes,
    );
    if (outputPath == null) return;
    if (mounted) _showMessage('Saved CSV: $outputPath');
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
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Local application records',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _selectedTableController,
                  decoration: const InputDecoration(
                    labelText: 'Table',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (table) {
                    setState(() => _selectedTable = table.trim());
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
          child: _records.isEmpty
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
