import 'package:flutter/material.dart';

import '../models/business_entry.dart';

class PeopleTable extends StatelessWidget {
  const PeopleTable({required this.entries, super.key});
  final List<BusinessEntry> entries;

  @override
  Widget build(BuildContext context) => _ScrollableTable(
    child: DataTable(
      headingRowColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      dataRowMinHeight: 52,
      columns: const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Business Name')),
        DataColumn(label: Text('Location Name')),
        DataColumn(label: Text('Nearest Airport')),
        DataColumn(label: Text('Address')),
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
                DataCell(Text(entry.businessName)),
                DataCell(Text(entry.locationName)),
                DataCell(Text(entry.nearestAirport)),
                DataCell(Text(entry.address)),
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
}

class BusinessTable extends StatelessWidget {
  const BusinessTable({required this.entries, super.key});
  final List<BusinessEntry> entries;

  @override
  Widget build(BuildContext context) => _ScrollableTable(
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
        DataColumn(label: Text('Location Name')),
        DataColumn(label: Text('Location Address')),
        DataColumn(label: Text('Location Direct Phone')),
        DataColumn(label: Text('Location Nearest Airport')),
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
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
              ],
            )
          else
            for (var index = 0; index < business.locations.length; index++)
              DataRow(
                cells: [
                  DataCell(Text(index == 0 ? business.name : '')),
                  DataCell(Text(index == 0 ? business.businessType : '')),
                  DataCell(Text(index == 0 ? business.address : '')),
                  DataCell(Text(index == 0 ? business.directPhone : '')),
                  DataCell(Text(index == 0 ? business.nearestAirport : '')),
                  DataCell(Text(business.locations[index].name)),
                  DataCell(Text(business.locations[index].address)),
                  DataCell(Text(business.locations[index].directPhone)),
                  DataCell(Text(business.locations[index].nearestAirport)),
                ],
              ),
      ],
    ),
  );
}

class _ScrollableTable extends StatelessWidget {
  const _ScrollableTable({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: child);
}
