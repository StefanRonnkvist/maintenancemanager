import 'package:flutter/material.dart';

class ManagementRecordTable extends StatelessWidget {
  const ManagementRecordTable({
    required this.columns,
    required this.rows,
    required this.emptyMessage,
    super.key,
  });

  final List<String> columns;
  final List<List<String>> rows;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(child: Text(emptyMessage)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 52,
        columns: [
          for (final column in columns) DataColumn(label: Text(column)),
        ],
        rows: [
          for (final row in rows)
            DataRow(cells: [for (final value in row) DataCell(Text(value))]),
        ],
      ),
    );
  }
}
