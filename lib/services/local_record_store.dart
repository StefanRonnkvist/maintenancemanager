import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalRecordStore {
  const LocalRecordStore._();

  static Future<List<Map<String, dynamic>>> read(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(key);
    if (stored == null || stored.isEmpty) return [];
    final decoded = jsonDecode(stored);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .toList(growable: false);
  }

  static Future<void> write(
    String key,
    List<Map<String, Object?>> values,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(key, jsonEncode(values));
    if (!saved) throw StateError('Local records could not be saved.');
  }
}
