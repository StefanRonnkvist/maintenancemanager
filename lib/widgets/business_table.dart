import 'package:flutter/material.dart';

import '../models/business_entry.dart';

/// Displays people and their linked businesses, work locations, and contacts.
class PeopleTable extends StatelessWidget {
  const PeopleTable({required this.entries, super.key});
  final List<BusinessEntry> entries;

  @override
  Widget build(BuildContext context) {
    final table = _ScrollableTable(
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 52,
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

/// Displays businesses, expanding one row per location when locations exist.
class BusinessTable extends StatelessWidget {
  const BusinessTable({required this.entries, super.key});
  final List<BusinessEntry> entries;

  @override
  Widget build(BuildContext context) {
    final table = _ScrollableTable(
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 52,
        columns: const [
          DataColumn(label: Text('Business Name')),
          DataColumn(label: Text('Business Type')),
          DataColumn(label: Text('Business Address')),
          DataColumn(label: Text('Business Direct Phone')),
          DataColumn(label: Text('Nearest Airport')),
        ],
        rows: [
          for (final business in entries)
            if (business.locations.isEmpty)
              DataRow(
                cells: [
                  DataCell(Text(business.name)),
                  DataCell(Text(business.businessType)),
                  DataCell(Text(business.address)),
                  DataCell(Text(business.directPhone)),
                  DataCell(Text(business.nearestAirport)),
                ],
              )
            else
              // Keep business-wide values on the first row; subsequent rows show locations.
              for (var index = 0; index < business.locations.length; index++)
                DataRow(
                  cells: [
                    DataCell(Text(index == 0 ? business.name : '')),
                    DataCell(Text(index == 0 ? business.businessType : '')),
                    DataCell(Text(index == 0 ? business.address : '')),
                    DataCell(Text(index == 0 ? business.directPhone : '')),
                    DataCell(Text(index == 0 ? business.nearestAirport : '')),
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
