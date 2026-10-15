import 'dart:convert';
import 'dart:io';

void main() {
  final configuration = jsonDecode(
    File('assets/config/static_config.json').readAsStringSync(),
  );
  if (configuration is! Map<String, dynamic>) {
    throw const FormatException('Static config must be a JSON object.');
  }
  stdout.writeln('Static config JSON is valid.');
}
