import 'dart:convert';

import 'package:flutter/material.dart';

/// Displays saved work orders using the same scrollable DataTable style as
/// the other record tables.
class WorkOrderTable extends StatelessWidget {
  const WorkOrderTable({required this.records, super.key});

  final List<Map<String, dynamic>> records;

  static const _columns = [
    ('Business Name', 'businessName'),
    ('Location Name', 'locationName'),
    ('Location Address', 'locationAddress'),
    ('Location Direct Phone Number', 'locationDirectPhone'),
    ('Location Airports', 'locationAirport'),
    ('Notes', 'notes'),
    ('Principle People', 'principlePeople'),
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
            final business = person['businessName']?.toString() ?? '';
            final location = person['locationName']?.toString() ?? '';
            final details = [
              business,
              location,
            ].where((part) => part.isNotEmpty).join(' — ');
            return details.isEmpty ? name : '$name ($details)';
          })
          .join('; ');
    }
    return decodedValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    final table = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 52,
        columns: [
          for (final (header, _) in _columns) DataColumn(label: Text(header)),
        ],
        rows: [
          for (final record in records)
            DataRow(
              cells: [
                for (final (_, key) in _columns)
                  DataCell(Text(_formatCell(record[key]))),
              ],
            ),
        ],
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
