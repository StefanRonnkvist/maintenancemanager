import 'package:flutter_test/flutter_test.dart';
import 'package:maintenancemanager/services/csv_utils.dart';

void main() {
  group('CsvUtils.parse', () {
    test('preserves commas and escaped quotes inside quoted fields', () {
      expect(
        CsvUtils.parse('''name,code
"Bergen Airport, Flesland",BGO
"He said ""go"",XYZ"'''),
        [
          ['name', 'code'],
          ['Bergen Airport, Flesland', 'BGO'],
          ['He said "go",XYZ'],
        ],
      );
    });

    test('preserves line breaks inside quoted fields and accepts LF', () {
      expect(
        CsvUtils.parse('header,notes\nvalue,"first line\nsecond line"\n'),
        [
          ['header', 'notes'],
          ['value', 'first line\nsecond line'],
        ],
      );
    });

    test('rejects an unclosed quoted field', () {
      expect(
        () => CsvUtils.parse('header\n"unfinished'),
        throwsFormatException,
      );
    });
  });
}
