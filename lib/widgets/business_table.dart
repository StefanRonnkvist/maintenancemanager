import 'package:flutter/material.dart';

import '../models/business_entry.dart';

/// Displays people and their linked businesses, work locations, and contacts.
class PeopleTable extends StatelessWidget {
  const PeopleTable({
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
    final table = _ScrollableTable(
      child: DataTable(
        showCheckboxColumn: false,
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 48,
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
        rows: entries
            .map(
              (entry) => DataRow(
                selected: identical(entry, selectedEntry),
                onSelectChanged: (_) => onRowTap(entry),
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
        const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No people added yet.')),
        ),
      ],
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
    final table = _ScrollableTable(
      child: DataTable(
        showCheckboxColumn: false,
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 48,
        columns: const [
          DataColumn(label: Text('Business Name')),
          DataColumn(label: Text('Business Type')),
          DataColumn(label: Text('Business Address')),
          DataColumn(label: Text('Business Direct Phone')),
          DataColumn(label: Text('Business Nearest Airport')),
          DataColumn(label: Text('Location 1 Name')),
          DataColumn(label: Text('Location 1 Address')),
          DataColumn(label: Text('Location 1 Direct Phone')),
          DataColumn(label: Text('Location 1 Nearest Airport')),
          DataColumn(label: Text('Location 2 Name')),
          DataColumn(label: Text('Location 2 Address')),
          DataColumn(label: Text('Location 2 Direct Phone')),
          DataColumn(label: Text('Location 2 Nearest Airport')),
          DataColumn(label: Text('Location 3 Name')),
          DataColumn(label: Text('Location 3 Address')),
          DataColumn(label: Text('Location 3 Direct Phone')),
          DataColumn(label: Text('Location 3 Nearest Airport')),
          DataColumn(label: Text('Location 4 Name')),
          DataColumn(label: Text('Location 4 Address')),
          DataColumn(label: Text('Location 4 Direct Phone')),
          DataColumn(label: Text('Location 4 Nearest Airport')),
        ],
        rows: [
          for (final business in entries)
            DataRow(
              selected: identical(business, selectedEntry),
              onSelectChanged: (_) => onRowTap(business),
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
    if (entries.isNotEmpty) return table;
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
class _ScrollableTable extends StatelessWidget {
  const _ScrollableTable({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: child);
}
