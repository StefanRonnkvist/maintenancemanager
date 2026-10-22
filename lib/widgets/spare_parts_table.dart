import 'package:flutter/material.dart';

import 'sortable_data_table.dart';

/// Displays spare-part field headers and rows submitted from the entry form.
class SparePartsTable extends StatelessWidget {
  const SparePartsTable({
    required this.records,
    required this.onRowTap,
    this.showEmptyMessage = true,
    this.leadingColumnLabel,
    super.key,
  });

  final List<List<String>> records;
  final ValueChanged<int> onRowTap;
  final bool showEmptyMessage;
  final String? leadingColumnLabel;

  static const _columns = [
    'OEM Part Number',
    'OEM Description',
    'Vendor Part Number',
    'Vendor Description',
    'Serial Number',
    'Vendor Name',
    'Location Name',
    'Quantity in Stock',
    'Storage Location',
  ];

  @override
  Widget build(BuildContext context) {
    final columns = [?leadingColumnLabel, ..._columns];
    final table = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SortableDataTable(
        showCheckboxColumn: false,
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        dataRowMinHeight: 52,
        dataRowMaxHeight: 80,
        columns: columns,
        rows: records,
        onRowSelected: onRowTap,
      ),
    );
    if (records.isNotEmpty || !showEmptyMessage) return table;
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
