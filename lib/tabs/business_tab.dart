import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import '../services/local_record_store.dart';
import '../widgets/business_form.dart';
import '../widgets/business_table.dart';
import '../widgets/management_tab_layout.dart';

/// Displays either People or Business records using the shared form and table.
class BusinessTab extends StatefulWidget {
  const BusinessTab({
    required this.entries,
    required this.onAdd,
    required this.kind,
    required this.businessEntries,
    super.key,
  });

  final List<BusinessEntry> entries;
  final ValueChanged<BusinessEntry> onAdd;
  final BusinessTabKind kind;
  final List<BusinessEntry> businessEntries;

  @override
  State<BusinessTab> createState() => _BusinessTabState();
}

class _BusinessTabState extends State<BusinessTab> {
  static const _peopleStorageKey = 'people_records_v1';
  static const _businessStorageKey = 'business_records_v1';
  bool _formExpanded = false;
  BusinessEntry? _selectedEntry;
  bool _isLoading = true;
  String? _storageError;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  /// Loads the storage collection selected by this tab's [kind].
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

  /// Writes the current people or business list back to local preferences.
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

  /// Selects a row and opens the form populated with its values.
  void _selectEntry(BusinessEntry entry) {
    setState(() {
      _selectedEntry = entry;
      _formExpanded = true;
    });
  }

  /// Adds a new entry or replaces the currently selected table row.
  void _saveEntry(BusinessEntry entry) {
    setState(() {
      if (_selectedEntry == null) {
        widget.onAdd(entry);
      } else {
        final index = widget.entries.indexOf(_selectedEntry!);
        if (index >= 0) {
          widget.entries[index] = entry;
        }
      }
      _selectedEntry = null;
    });
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
              title: Text(
                _selectedEntry == null
                    ? (isPeople ? 'Add person' : 'Add business')
                    : (isPeople ? 'Update person' : 'Update business'),
              ),
              trailing: Icon(
                _formExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onTap: () => setState(() => _formExpanded = !_formExpanded),
            ),
            if (_formExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: BusinessForm(
                  key: ValueKey(_selectedEntry),
                  kind: widget.kind,
                  initialEntry: _selectedEntry,
                  onSubmit: _saveEntry,
                  businessNames:
                      widget.businessEntries
                          .map((entry) => entry.name.trim())
                          .where((name) => name.isNotEmpty)
                          .toSet()
                          .toList()
                        ..sort(),
                  businessLocations:
                      widget.businessEntries
                          .expand((entry) => entry.locations)
                          .map((location) => location.name.trim())
                          .where((name) => name.isNotEmpty)
                          .toSet()
                          .toList()
                        ..sort(),
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
                isPeople
                    ? PeopleTable(
                        entries: widget.entries,
                        onRowTap: _selectEntry,
                        selectedEntry: _selectedEntry,
                      )
                    : BusinessTable(
                        entries: widget.entries,
                        onRowTap: _selectEntry,
                        selectedEntry: _selectedEntry,
                      ),
              ],
            ),
    );
  }
}

enum BusinessTabKind { people, business }
