import 'package:flutter/material.dart';

import '../models/business_entry.dart';

/// Displays people and their linked businesses, work locations, and contacts.
class PeopleTable extends StatefulWidget {
  const PeopleTable({
    required this.entries,
    required this.onRowTap,
    required this.selectedEntry,
    this.emptyMessage = 'No people added yet.',
    super.key,
  });
  final List<BusinessEntry> entries;
  final ValueChanged<BusinessEntry> onRowTap;
  final BusinessEntry? selectedEntry;
  final String emptyMessage;

  @override
  State<PeopleTable> createState() => _PeopleTableState();
}

class _PeopleTableState extends State<PeopleTable> {
  final Map<int, String> _filters = {};
  List<BusinessEntry> _sortedEntries = [];
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void didUpdateWidget(covariant PeopleTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) _sortedEntries = [];
  }

  List<BusinessEntry> get _entries =>
      _sortedEntries.length == widget.entries.length && _sortColumnIndex != null
      ? _sortedEntries
      : widget.entries;

  void _setFilter(int column, String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _filters.remove(column);
      } else {
        _filters[column] = value;
      }
    });
  }

  void _sort(int columnIndex, bool ascending) {
    String value(BusinessEntry entry) => switch (columnIndex) {
      0 => entry.name,
      1 => entry.title,
      2 => entry.businessName,
      3 => entry.locationName,
      4 => entry.directPhone,
      5 => entry.directPhoneExtension,
      6 => entry.cellPhone,
      7 => entry.email,
      _ => '',
    };
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortedEntries = [..._entries]
        ..sort((a, b) {
          final aValue = value(a);
          final bValue = value(b);
          final aNumber = num.tryParse(aValue);
          final bNumber = num.tryParse(bValue);
          final result = aNumber != null && bNumber != null
              ? aNumber.compareTo(bNumber)
              : aValue.toLowerCase().compareTo(bValue.toLowerCase());
          return ascending ? result : -result;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final table = _ScrollableTable(
      child: DataTable(
        showCheckboxColumn: false,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 48,
        columns: [
          for (final (index, label) in const [
            'Name',
            'Title',
            'Business Name',
            'Location Name',
            'Direct Phone',
            'Extension',
            'Cell Phone',
            'eMail',
          ].indexed)
            DataColumn(
              label: _filterableHeader(label, index, _filters, _setFilter),
              onSort: (_, ascending) => _sort(index, ascending),
            ),
        ],
        rows: entries
            .where((entry) => _matchesFilters([
              entry.name,
              entry.title,
              entry.businessName,
              entry.locationName,
              entry.directPhone,
              entry.directPhoneExtension,
              entry.cellPhone,
              entry.email,
            ], _filters))
            .map(
              (entry) => DataRow(
                selected: identical(entry, widget.selectedEntry),
                onSelectChanged: (_) => widget.onRowTap(entry),
                cells: [
                  DataCell(Text(entry.name)),
                  DataCell(Text(entry.title)),
                  DataCell(Text(entry.businessName)),
                  DataCell(Text(entry.locationName)),
                  DataCell(Text(entry.directPhone)),
                  DataCell(Text(entry.directPhoneExtension)),
                  DataCell(Text(entry.cellPhone)),
                  DataCell(Text(entry.email)),
                ],
              ),
            )
            .toList(),
      ),
    );
    if (entries.isNotEmpty) return table;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        table,
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text(widget.emptyMessage)),
        ),
      ],
    );
  }
}

/// Displays businesses with their company-wide and four location fields.
class BusinessTable extends StatefulWidget {
  const BusinessTable({
    required this.entries,
    required this.onRowTap,
    required this.selectedEntry,
    super.key,
  });
  final List<BusinessEntry> entries;
  final ValueChanged<BusinessEntry> onRowTap;
  final BusinessEntry? selectedEntry;

  @override
  State<BusinessTable> createState() => _BusinessTableState();
}

class _BusinessTableState extends State<BusinessTable> {
  final Map<int, String> _filters = {};
  int? _sortColumnIndex;
  bool _sortAscending = true;
  List<BusinessEntry> _sortedEntries = [];

  @override
  void didUpdateWidget(covariant BusinessTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) _sortedEntries = [];
  }

  List<BusinessEntry> get _entries =>
      _sortedEntries.length == widget.entries.length && _sortColumnIndex != null
      ? _sortedEntries
      : widget.entries;

  void _setFilter(int column, String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _filters.remove(column);
      } else {
        _filters[column] = value;
      }
    });
  }

  void _sort(int columnIndex, bool ascending) {
    String value(BusinessEntry business, int column) {
      if (column == 0) return business.name;
      if (column == 1) return business.businessType;
      if (column == 2) return business.address;
      if (column == 3) return business.directPhone;
      if (column == 4) return business.nearestAirport;
      final locationColumn = column - 5;
      final locationIndex = locationColumn ~/ 4;
      final field = switch (locationColumn % 4) {
        0 => 'name',
        1 => 'address',
        2 => 'directPhone',
        _ => 'nearestAirport',
      };
      return _locationValue(business, locationIndex, field);
    }

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _sortedEntries = [...widget.entries]
        ..sort((a, b) {
          final aValue = value(a, columnIndex);
          final bValue = value(b, columnIndex);
          final aNumber = num.tryParse(aValue);
          final bNumber = num.tryParse(bValue);
          final comparison = aNumber != null && bNumber != null
              ? aNumber.compareTo(bNumber)
              : aValue.toLowerCase().compareTo(bValue.toLowerCase());
          return ascending ? comparison : -comparison;
        });
    });
  }

  String _locationValue(BusinessEntry business, int index, String field) {
    if (index >= business.locations.length) return '';
    final location = business.locations[index];
    return switch (field) {
      'name' => location.name,
      'address' => location.address,
      'directPhone' => location.directPhone,
      'nearestAirport' => location.nearestAirport,
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final table = _ScrollableTable(
      child: DataTable(
        showCheckboxColumn: false,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 48,
        columns: [
          DataColumn(
            label: _filterableHeader('Business Name', 0, _filters, _setFilter),
            onSort: (_, ascending) => _sort(0, ascending),
          ),
          DataColumn(
            label: _filterableHeader('Business Type', 1, _filters, _setFilter),
            onSort: (_, ascending) => _sort(1, ascending),
          ),
          DataColumn(
            label: _filterableHeader('Business Address', 2, _filters, _setFilter),
            onSort: (_, ascending) => _sort(2, ascending),
          ),
          DataColumn(
            label: _filterableHeader('Business Direct Phone', 3, _filters, _setFilter),
            onSort: (_, ascending) => _sort(3, ascending),
          ),
          DataColumn(
            label: _filterableHeader('Business Nearest Airport', 4, _filters, _setFilter),
            onSort: (_, ascending) => _sort(4, ascending),
          ),
          for (var index = 0; index < 4; index++) ...[
            DataColumn(
              label: _filterableHeader('Location ${index + 1} Name', 5 + index * 4, _filters, _setFilter),
              onSort: (_, ascending) => _sort(5 + index * 4, ascending),
            ),
            DataColumn(
              label: _filterableHeader('Location ${index + 1} Address', 6 + index * 4, _filters, _setFilter),
              onSort: (_, ascending) => _sort(6 + index * 4, ascending),
            ),
            DataColumn(
              label: _filterableHeader('Location ${index + 1} Direct Phone', 7 + index * 4, _filters, _setFilter),
              onSort: (_, ascending) => _sort(7 + index * 4, ascending),
            ),
            DataColumn(
              label: _filterableHeader('Location ${index + 1} Nearest Airport', 8 + index * 4, _filters, _setFilter),
              onSort: (_, ascending) => _sort(8 + index * 4, ascending),
            ),
          ],
        ],
        rows: [
          for (final business in entries)
            if (_matchesFilters([
              business.name,
              business.businessType,
              business.address,
              business.directPhone,
              business.nearestAirport,
              for (var index = 0; index < 4; index++) ...[
                _locationValue(business, index, 'name'),
                _locationValue(business, index, 'address'),
                _locationValue(business, index, 'directPhone'),
                _locationValue(business, index, 'nearestAirport'),
              ],
            ], _filters))
            DataRow(
              selected: identical(business, widget.selectedEntry),
              onSelectChanged: (_) => widget.onRowTap(business),
              cells: [
                DataCell(Text(business.name)),
                DataCell(Text(business.businessType)),
                DataCell(Text(business.address)),
                DataCell(Text(business.directPhone)),
                DataCell(Text(business.nearestAirport)),
                for (var index = 0; index < 4; index++) ...[
                  DataCell(Text(_locationValue(business, index, 'name'))),
                  DataCell(Text(_locationValue(business, index, 'address'))),
                  DataCell(
                    Text(_locationValue(business, index, 'directPhone')),
                  ),
                  DataCell(
                    Text(_locationValue(business, index, 'nearestAirport')),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
    if (widget.entries.isNotEmpty) return table;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        table,
        const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No businesses added yet.')),
        ),
      ],
    );
  }
}

/// Allows wide data tables to scroll horizontally on narrow screens.
Widget _filterableHeader(
  String label,
  int column,
  Map<int, String> filters,
  void Function(int column, String value) onChanged,
) => SizedBox(
  width: 150,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      SizedBox(
        height: 32,
        child: TextField(
          key: ValueKey('table-filter-$column-${filters[column] ?? ''}'),
          onChanged: (value) => onChanged(column, value),
          decoration: const InputDecoration(
            hintText: 'Filter',
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 6),
            border: UnderlineInputBorder(),
          ),
        ),
      ),
    ],
  ),
);

bool _matchesFilters(List<String> values, Map<int, String> filters) =>
    filters.entries.every((filter) {
      if (filter.value.trim().isEmpty) return true;
      final value = filter.key < values.length ? values[filter.key] : '';
      return value.toLowerCase().contains(filter.value.trim().toLowerCase());
    });

class _ScrollableTable extends StatelessWidget {
  const _ScrollableTable({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: child);
}
