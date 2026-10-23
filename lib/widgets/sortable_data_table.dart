import 'package:flutter/material.dart';

/// DataTable with sortable columns and independent per-column filters.
class SortableDataTable extends StatefulWidget {
  const SortableDataTable({
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.sortValues,
    this.showCheckboxColumn = false,
    this.headingRowColor,
    this.dataRowMinHeight,
    this.dataRowMaxHeight,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onRowSelected,
    this.onColumnSort,
    this.rowColors,
    this.enableFiltering = true,
    this.selectedRows = const {},
    super.key,
  });

  final List<String> columns;
  final List<List<String>> rows;
  final ValueChanged<int>? onRowTap;
  final List<List<String>>? sortValues;
  final bool showCheckboxColumn;
  final WidgetStateProperty<Color?>? headingRowColor;
  final double? dataRowMinHeight;
  final double? dataRowMaxHeight;
  final int? sortColumnIndex;
  final bool sortAscending;
  final ValueChanged<int>? onRowSelected;
  final void Function(int columnIndex, bool ascending)? onColumnSort;
  final List<Color?>? rowColors;
  final bool enableFiltering;
  final Set<int> selectedRows;

  @override
  State<SortableDataTable> createState() => _SortableDataTableState();
}

class _SortableDataTableState extends State<SortableDataTable> {
  late List<int> _order;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  late List<TextEditingController> _filterControllers;

  @override
  void initState() {
    super.initState();
    _order = List.generate(widget.rows.length, (index) => index);
    _filterControllers = _createFilterControllers(widget.columns.length);
  }

  List<TextEditingController> _createFilterControllers(int count) =>
      List.generate(count, (_) => TextEditingController()..addListener(_applyFilters));

  void _applyFilters() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final controller in _filterControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SortableDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.columns.length != widget.columns.length) {
      for (final controller in _filterControllers) {
        controller.removeListener(_applyFilters);
        controller.dispose();
      }
      _filterControllers = _createFilterControllers(widget.columns.length);
    }
    if (oldWidget.rows != widget.rows ||
        oldWidget.sortValues != widget.sortValues) {
      _order = List.generate(widget.rows.length, (index) => index);
    }
  }

  void _sort(int columnIndex, bool ascending) {
    final values = widget.sortValues ?? widget.rows;
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _order.sort((left, right) {
        final leftValue = columnIndex < values[left].length
            ? values[left][columnIndex]
            : '';
        final rightValue = columnIndex < values[right].length
            ? values[right][columnIndex]
            : '';
        final leftNumber = num.tryParse(leftValue);
        final rightNumber = num.tryParse(rightValue);
        final comparison = leftNumber != null && rightNumber != null
            ? leftNumber.compareTo(rightNumber)
            : leftValue.toLowerCase().compareTo(rightValue.toLowerCase());
        return ascending ? comparison : -comparison;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      for (var column = 0; column < widget.columns.length; column++)
        _filterControllers[column].text.trim().toLowerCase(),
    ];
    final visibleOrder = _order.where((rowIndex) {
      final values = widget.rows[rowIndex];
      return filters.indexed.every((entry) {
        final (column, filter) = entry;
        if (filter.isEmpty) return true;
        final value = column < values.length ? values[column] : '';
        return value.toLowerCase().contains(filter);
      });
    }).toList();
    final columns = [
      for (var index = 0; index < widget.columns.length; index++)
        DataColumn(
          label: widget.enableFiltering
              ? SizedBox(
                  width: 150,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.columns[index]),
                      SizedBox(
                        height: 32,
                        child: TextField(
                          enabled: widget.enableFiltering,
                          controller: _filterControllers[index],
                          decoration: const InputDecoration(
                            hintText: 'Filter',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Text(widget.columns[index]),
          onSort: (column, ascending) {
            _sort(column, ascending);
            widget.onColumnSort?.call(column, ascending);
          },
        ),
    ];
    return DataTable(
      showCheckboxColumn: widget.showCheckboxColumn,
      headingRowColor: widget.headingRowColor,
      dataRowMinHeight: widget.dataRowMinHeight,
      dataRowMaxHeight: widget.dataRowMaxHeight,
      sortColumnIndex: widget.sortColumnIndex ?? _sortColumnIndex,
      sortAscending: widget.sortColumnIndex == null
          ? _sortAscending
          : widget.sortAscending,
      columns: columns,
      rows: [
        for (var sortedIndex = 0; sortedIndex < visibleOrder.length; sortedIndex++)
          DataRow(
          selected: widget.selectedRows.contains(visibleOrder[sortedIndex]),
          color: widget.rowColors == null
              ? null
              : WidgetStatePropertyAll(
                  visibleOrder[sortedIndex] < widget.rowColors!.length
                      ? widget.rowColors![visibleOrder[sortedIndex]]
                      : null,
                ),
          onSelectChanged: widget.onRowSelected != null
              ? (_) => widget.onRowSelected!(visibleOrder[sortedIndex])
              : widget.onRowTap != null
              ? (_) => widget.onRowTap!(visibleOrder[sortedIndex])
              : null,
          cells: [
            for (var column = 0; column < widget.columns.length; column++)
              DataCell(
                Text(
                  column < widget.rows[visibleOrder[sortedIndex]].length
                                         ? widget.rows[visibleOrder[sortedIndex]][column]
                      : '',
                ),
              ),
          ],
        ),
      ],
    );
  }
}
