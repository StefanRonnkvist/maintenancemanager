import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A lightweight persisted local database for application records.
class ApplicationDbPage extends StatefulWidget {
  const ApplicationDbPage({super.key});

  @override
  State<ApplicationDbPage> createState() => _ApplicationDbPageState();
}

class _ApplicationDbPageState extends State<ApplicationDbPage> {
  static const String _storageKey = 'application_db_records_v1';

  final List<_AppRecord> _records = <_AppRecord>[];
  bool _isLoading = true;
  String? _storageError;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      final String? stored = preferences.getString(_storageKey);
      if (stored != null) {
        final List<dynamic> decoded = jsonDecode(stored) as List<dynamic>;
        _records
          ..clear()
          ..addAll(decoded.map(
            (dynamic item) => _AppRecord.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ),
          ));
      }
    } catch (error) {
      _storageError = 'Could not read local records: $error';
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _persistRecords() async {
    try {
      final SharedPreferences preferences = await SharedPreferences.getInstance();
      final bool saved = await preferences.setString(
        _storageKey,
        jsonEncode(_records.map((record) => record.toJson()).toList()),
      );
      if (!saved) throw StateError('The device did not save the records.');
      if (mounted) setState(() => _storageError = null);
    } catch (error) {
      if (mounted) setState(() => _storageError = 'Could not save local records: $error');
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

  Future<_AppRecord?> _showRecordDialog({_AppRecord? existing}) async {
    final TextEditingController name = TextEditingController(text: existing?.name ?? '');
    final TextEditingController value = TextEditingController(text: existing?.value ?? '');
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final _AppRecord? result = await showDialog<_AppRecord>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(existing == null ? 'Add application record' : 'Edit application record'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name / key'),
                validator: (String? input) => input == null || input.trim().isEmpty
                    ? 'Enter a name.'
                    : null,
              ),
              TextFormField(
                controller: value,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Value'),
                validator: (String? input) => input == null || input.trim().isEmpty
                    ? 'Enter a value.'
                    : null,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.pop(
                context,
                _AppRecord(
                  id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
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
                child: Text('Local application records', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
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
            child: Text(_storageError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        Expanded(
          child: _records.isEmpty
              ? const Center(child: Text('No records yet. Add a record to get started.'))
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
                        trailing: PopupMenuButton<String>(
                          onSelected: (String action) {
                            if (action == 'edit') _updateRecord(record);
                            if (action == 'delete') _deleteRecord(record);
                          },
                          itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                            PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
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
  const _AppRecord({required this.id, required this.name, required this.value, required this.updatedAt});

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
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      );
}
