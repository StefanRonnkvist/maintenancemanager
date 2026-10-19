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
    ('Component Category', 'componentCategory'),
    ('Component', 'component'),
  ];

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
                  DataCell(Text(record[key] as String? ?? '')),
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
