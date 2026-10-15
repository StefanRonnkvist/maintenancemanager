import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../models/ui_text_catalog.dart';

/// Downloads submissions and displays those belonging to the current package.
class SubmissionsCsvCardsView extends StatefulWidget {
  const SubmissionsCsvCardsView({super.key, required this.text});

  final UiTextCatalog text;

  @override
  State<SubmissionsCsvCardsView> createState() =>
      _SubmissionsCsvCardsViewState();
}

/// Downloads submissions, keeps the rows whose App column matches this app's
/// package name, and shows each as a card.
class _SubmissionsCsvCardsViewState extends State<SubmissionsCsvCardsView> {
  late Future<_CsvTableData> _tableFuture;

  @override
  void initState() {
    super.initState();
    _tableFuture = _loadCsv();
  }

  /// Fetches, normalizes, and package-filters the remote CSV rows.
  Future<_CsvTableData> _loadCsv() async {
    final Uri uri = Uri.parse(widget.text.configText('submissions', 'csvUrl'));
    final http.Response response = await http
        .get(uri)
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Server returned status ${response.statusCode}.');
    }

    final String csvText = utf8.decode(response.bodyBytes);
    final List<List<String>> rows = _parseCsv(csvText);

    if (rows.isEmpty) {
      return const _CsvTableData(headers: <String>[], rows: <List<String>>[]);
    }

    final List<String> headers = widget.text.configList(
      'submissions',
      'headers',
    );
    final int maxColumnCount = headers.length;

    // Padding guarantees that package filtering and card rendering are indexed safely.
    final List<List<String>> normalizedRows = rows
        .map(
          (List<String> row) => <String>[
            ...row,
            ...List<String>.filled(maxColumnCount - row.length, ''),
          ],
        )
        .toList(growable: false);

    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentApp = packageInfo.packageName.trim().toLowerCase();

    final List<List<String>> filteredRows = normalizedRows
        .where((List<String> row) {
          final String appValue =
              row[widget.text.configInteger('submissions', 'appColumnIndex')]
                  .trim()
                  .toLowerCase();
          return appValue == currentApp;
        })
        .toList(growable: false);

    return _CsvTableData(headers: headers, rows: filteredRows);
  }

  /// Parses comma-separated rows, including quoted fields and escaped quotes.
  ///
  /// Both Unix and Windows line endings are accepted, and blank rows are ignored.
  List<List<String>> _parseCsv(String input) {
    final List<List<String>> rows = <List<String>>[];
    final List<String> currentRow = <String>[];
    final StringBuffer currentField = StringBuffer();
    bool inQuotes = false;

    int i = 0;
    while (i < input.length) {
      final String char = input[i];

      if (char == '"') {
        if (inQuotes && i + 1 < input.length && input[i + 1] == '"') {
          currentField.write('"');
          i += 2;
          continue;
        }

        inQuotes = !inQuotes;
        i += 1;
        continue;
      }

      if (!inQuotes && char == ',') {
        currentRow.add(currentField.toString());
        currentField.clear();
        i += 1;
        continue;
      }

      if (!inQuotes && (char == '\n' || char == '\r')) {
        currentRow.add(currentField.toString());
        currentField.clear();

        if (currentRow.any((String value) => value.isNotEmpty)) {
          rows.add(List<String>.from(currentRow));
        }
        currentRow.clear();

        if (char == '\r' && i + 1 < input.length && input[i + 1] == '\n') {
          i += 2;
        } else {
          i += 1;
        }
        continue;
      }

      currentField.write(char);
      i += 1;
    }

    currentRow.add(currentField.toString());
    if (currentRow.any((String value) => value.isNotEmpty)) {
      rows.add(List<String>.from(currentRow));
    }

    return rows;
  }

  /// Builds the shared empty/error state without exposing transport details.
  Widget _buildNoInformationMessage() {
    return Center(
      child: Text(widget.text.configText('submissions', 'emptyMessage')),
    );
  }

  /// Builds one response card while hiding the submitter identity columns.
  Widget _buildSubmissionCard({
    required int index,
    required List<String> headers,
    required List<String> row,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Submission #$index',
              style: TextStyle(
                fontSize: widget.text.configNumber(
                  'submissions',
                  'titleFontSize',
                ),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            ...List<Widget>.generate(
              headers.length -
                  widget.text.configInteger(
                    'submissions',
                    'visibleFieldStartIndex',
                  ),
              (int offset) {
                final int fieldIndex =
                    widget.text.configInteger(
                      'submissions',
                      'visibleFieldStartIndex',
                    ) +
                    offset;
                final String value = fieldIndex < row.length
                    ? row[fieldIndex]
                    : '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildFieldRow(headers[fieldIndex], value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Renders a labeled CSV field, substituting a dash for missing values.
  Widget _buildFieldRow(String label, String value) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: widget.text.configNumber('submissions', 'fieldFontSize'),
          color: colorScheme.onSurface,
        ),
        children: <InlineSpan>[
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              fontSize: widget.text.configNumber(
                'submissions',
                'fieldFontSize',
              ),
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          TextSpan(text: value.isEmpty ? '-' : value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CsvTableData>(
      future: _tableFuture,
      builder: (BuildContext context, AsyncSnapshot<_CsvTableData> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildNoInformationMessage();
        }

        final _CsvTableData tableData =
            snapshot.data ??
            const _CsvTableData(headers: <String>[], rows: <List<String>>[]);

        if (tableData.rows.isEmpty) {
          return _buildNoInformationMessage();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List<Widget>.generate(tableData.rows.length, (int index) {
              final List<String> row = tableData.rows[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == tableData.rows.length - 1 ? 0 : 10,
                ),
                child: _buildSubmissionCard(
                  index: index + 1,
                  headers: tableData.headers,
                  row: row,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Immutable normalized table data consumed by the response list.
class _CsvTableData {
  const _CsvTableData({required this.headers, required this.rows});

  final List<String> headers;
  final List<List<String>> rows;
}
