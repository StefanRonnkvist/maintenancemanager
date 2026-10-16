import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import '../services/local_record_store.dart';
import '../widgets/business_form.dart';
import '../widgets/business_table.dart';
import '../widgets/management_tab_layout.dart';

class BusinessTab extends StatefulWidget {
  const BusinessTab({
    required this.entries,
    required this.onAdd,
    required this.kind,
    this.businesses = const [],
    super.key,
  });

  final List<BusinessEntry> entries;
  final ValueChanged<BusinessEntry> onAdd;
  final BusinessTabKind kind;
  final List<BusinessEntry> businesses;

  @override
  State<BusinessTab> createState() => _BusinessTabState();
}

class _BusinessTabState extends State<BusinessTab> {
  static const _peopleStorageKey = 'people_records_v1';
  static const _businessStorageKey = 'business_records_v1';
  bool _formExpanded = false;
  bool _isLoading = true;
  String? _storageError;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final key = widget.kind == BusinessTabKind.people
          ? _peopleStorageKey
          : _businessStorageKey;
      final rows = await LocalRecordStore.read(key);
      if (!mounted) return;
      widget.entries
        ..clear()
        ..addAll(rows.map(BusinessEntry.fromJson));
    } catch (error) {
      _storageError = 'Could not load records: $error';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _persistEntries() async {
    try {
      final key = widget.kind == BusinessTabKind.people
          ? _peopleStorageKey
          : _businessStorageKey;
      await LocalRecordStore.write(
        key,
        widget.entries.map((entry) => entry.toJson()).toList(),
      );
      if (mounted) setState(() => _storageError = null);
    } catch (error) {
      if (mounted) {
        setState(() => _storageError = 'Could not save records: $error');
      }
    }
  }

  void _addEntry(BusinessEntry entry) {
    setState(() => widget.onAdd(entry));
    _persistEntries();
  }

  @override
  Widget build(BuildContext context) {
    final isPeople = widget.kind == BusinessTabKind.people;
    final title = isPeople ? 'People' : 'Business';
    return ManagementTabLayout(
      title: title,
      icon: isPeople ? Icons.people_outline : Icons.business_outlined,
      form: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              title: Text(isPeople ? 'Add person' : 'Add business'),
              trailing: Icon(
                _formExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onTap: () => setState(() => _formExpanded = !_formExpanded),
            ),
            if (_formExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: BusinessForm(
                  kind: widget.kind,
                  businesses: widget.businesses,
                  onSubmit: _addEntry,
                ),
              ),
          ],
        ),
      ),
      recordsTitle: isPeople ? 'People' : 'Businesses',
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
                Center(
                  child: isPeople
                      ? PeopleTable(entries: widget.entries)
                      : BusinessTable(entries: widget.entries),
                ),
              ],
            ),
    );
  }
}

enum BusinessTabKind { people, business }
