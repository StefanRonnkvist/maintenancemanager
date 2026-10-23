import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import 'sortable_data_table.dart';

/// Displays people and their linked businesses, work locations, and contacts.
class PeopleTable extends StatelessWidget {
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
  Widget build(BuildContext context) {
    const columns = [
      'Name',
      'Title',
      'Business Name',
      'Location Name',
      'Direct Phone',
      'Extension',
      'Cell Phone',
      'eMail',
    ];
    return _SortableBusinessTable<BusinessEntry>(
      entries: entries,
      selectedEntry: selectedEntry,
      onRowTap: onRowTap,
      columns: columns,
      values: (entry) => [
        entry.name,
        entry.title,
        entry.businessName,
        entry.locationName,
        entry.directPhone,
        entry.directPhoneExtension,
        entry.cellPhone,
        entry.email,
      ],
      emptyMessage: emptyMessage,
    );
  }
}

/// Displays businesses with their company-wide and four location fields.
class BusinessTable extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final columns = <String>[
      'Business Name',
      'Business Type',
      'Business Address',
      'Business Direct Phone',
      'Business Nearest Airport',
      for (var index = 1; index <= 4; index++) ...[
        'Location $index Name',
        'Location $index Address',
        'Location $index Direct Phone',
        'Location $index Nearest Airport',
      ],
    ];
    return _SortableBusinessTable<BusinessEntry>(
      entries: entries,
      selectedEntry: selectedEntry,
      onRowTap: onRowTap,
      columns: columns,
      values: (business) => [
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
      ],
      emptyMessage: 'No businesses added yet.',
    );
  }
}

/// Shared sortable, filterable, horizontally scrolling, selectable table.
class _SortableBusinessTable<T> extends StatelessWidget {
  const _SortableBusinessTable({
    required this.entries,
    required this.selectedEntry,
    required this.onRowTap,
    required this.columns,
    required this.values,
    required this.emptyMessage,
  });

  final List<T> entries;
  final T? selectedEntry;
  final ValueChanged<T> onRowTap;
  final List<String> columns;
  final List<String> Function(T entry) values;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final rows = [for (final entry in entries) values(entry)];
    final table = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SortableDataTable(
        showCheckboxColumn: false,
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 48,
        columns: columns,
        rows: rows,
        sortValues: rows,
        onRowSelected: (index) => onRowTap(entries[index]),
        rowColors: [
          for (final entry in entries)
            identical(entry, selectedEntry)
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
        ],
      ),
    );
    if (entries.isNotEmpty) return table;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        table,
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text(emptyMessage)),
        ),
      ],
    );
  }
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
