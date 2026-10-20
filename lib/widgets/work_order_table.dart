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
    ('Assigned 1 Name', 'assigned1Name'),
    ('Assigned 1 Email', 'assigned1Email'),
    ('Assigned 1 Phone', 'assigned1Phone'),
    ('Assigned 2 Name', 'assigned2Name'),
    ('Assigned 2 Email', 'assigned2Email'),
    ('Assigned 2 Phone', 'assigned2Phone'),
    ('Assigned 3 Name', 'assigned3Name'),
    ('Assigned 3 Email', 'assigned3Email'),
    ('Assigned 3 Phone', 'assigned3Phone'),
    ('Assigned 4 Name', 'assigned4Name'),
    ('Assigned 4 Email', 'assigned4Email'),
    ('Assigned 4 Phone', 'assigned4Phone'),
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
