import 'package:flutter/material.dart';

import '../models/spare_part_record.dart';

class SparePartsTable extends StatelessWidget {
  const SparePartsTable({required this.records, super.key});

  final List<SparePartRecord> records;

  static const _columns = [
    'OEM Part Number',
    'OEM Description',
    'Vendor Part Number',
    'Vendor Description',
    'Serial Number',
    'Vendor Name',
    'Quantity in Stock',
    'Storage Location',
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
          for (final column in _columns) DataColumn(label: Text(column)),
        ],
        rows: [
          for (final record in records)
            DataRow(
              cells: [for (final value in record.values) DataCell(Text(value))],
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
          child: Center(child: Text('No spare parts added yet.')),
        ),
      ],
    );
  }
}
