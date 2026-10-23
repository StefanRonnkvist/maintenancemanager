/// Small RFC 4180-style CSV reader shared by bundled-data loaders.
class CsvUtils {
  const CsvUtils._();

  /// Parses commas, escaped quotes, and CR/LF inside quoted fields.
  static List<List<String>> parse(String source) {
    final rows = <List<String>>[];
    var row = <String>[];
    final field = StringBuffer();
    var quoted = false;

    for (var index = 0; index < source.length; index++) {
      final character = source[index];
      if (quoted) {
        if (character == '"') {
          if (index + 1 < source.length && source[index + 1] == '"') {
            field.write('"');
            index++;
          } else {
            quoted = false;
          }
        } else {
          field.write(character);
        }
      } else if (character == '"') {
        quoted = true;
      } else if (character == ',') {
        row.add(field.toString());
        field.clear();
      } else if (character == '\r' || character == '\n') {
        if (character == '\r' &&
            index + 1 < source.length &&
            source[index + 1] == '\n') {
          index++;
        }
        row.add(field.toString());
        field.clear();
        if (row.any((value) => value.isNotEmpty)) rows.add(row);
        row = <String>[];
      } else {
        field.write(character);
      }
    }

    if (quoted) {
      throw const FormatException('CSV has an unclosed quoted field.');
    }
    if (field.length > 0 || row.isNotEmpty) {
      row.add(field.toString());
      if (row.any((value) => value.isNotEmpty)) rows.add(row);
    }
    return rows;
  }
}
