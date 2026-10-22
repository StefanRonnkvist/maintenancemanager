import 'dart:convert';

import 'package:flutter/material.dart';

import 'sortable_data_table.dart';

/// Displays saved work orders using the same scrollable DataTable style as
/// the other record tables.
class WorkOrderTable extends StatelessWidget {
  const WorkOrderTable({
    required this.records,
    required this.onRowTap,
    super.key,
  });

  final List<Map<String, dynamic>> records;
  final ValueChanged<Map<String, dynamic>> onRowTap;

  static const _columns = [
    ('Work Order Number', 'workOrderNumber'),
    ('Business Name', 'businessName'),
    ('Location Name', 'locationName'),
    ('Location Address', 'locationAddress'),
    ('Location Direct Phone Number', 'locationDirectPhone'),
    ('Location Airports', 'locationAirport'),
    ('Matching Contacts', 'matchingPeople'),
    ('Notes', 'notes'),
    ('Principle Contacts', 'principlePeople'),
    ('Component Category', 'componentCategory'),
    ('Component', 'component'),
  ];

  String _formatCell(Object? value) {
    if (value == null) return '';
    Object? decodedValue = value;
    if (value is String) {
      try {
        decodedValue = jsonDecode(value);
      } on FormatException {
        return value;
      }
    }
    if (decodedValue is List) {
      return decodedValue
          .whereType<Map>()
          .map((person) {
            final name = person['name']?.toString() ?? '';
            final title = person['title']?.toString() ?? '';
            final business = person['businessName']?.toString() ?? '';
            final location = person['locationName']?.toString() ?? '';
            final directPhone = person['directPhone']?.toString() ?? '';
            final extension = person['directPhoneExtension']?.toString() ?? '';
            final cellPhone = person['cellPhone']?.toString() ?? '';
            final email = person['email']?.toString() ?? '';
            final contactDetails = [
              if (title.isNotEmpty) title,
              if (business.isNotEmpty) business,
              if (location.isNotEmpty) location,
              if (directPhone.isNotEmpty)
                'Direct: $directPhone${extension.isEmpty ? '' : ' ext. $extension'}',
              if (cellPhone.isNotEmpty) 'Cell: $cellPhone',
              if (email.isNotEmpty) email,
            ];
            return contactDetails.isEmpty
                ? name
                : '$name (${contactDetails.join(' — ')})';
          })
          .join('; ');
    }
    return decodedValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    final tableRows = [
      for (final record in records)
        [for (final (_, key) in _columns) _formatCell(record[key])],
    ];
    final table = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SortableDataTable(
        columns: [for (final (header, _) in _columns) header],
        rows: tableRows,
        onRowTap: (index) => onRowTap(records[index]),
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 52,
        dataRowMaxHeight: 64,
      ),
    );

    if (records.isNotEmpty) return table;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        table,
        const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No saved work orders yet.')),
        ),
      ],
    );
  }
}
