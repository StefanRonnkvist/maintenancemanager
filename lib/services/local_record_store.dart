import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// JSON list storage shared by the app's management tabs.
class LocalRecordStore {
  const LocalRecordStore._();

  /// Loads a stored list; absent or non-list values are treated as empty.
  static Future<List<Map<String, dynamic>>> read(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(key);
    if (stored == null || stored.isEmpty) return [];
    final dynamic decoded;
    try {
      decoded = jsonDecode(stored);
    } catch (_) {
      // Treat corrupt stored JSON as an empty collection, not a startup failure.
      return [];
    }
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .toList(growable: false);
  }

  /// Replaces the value at [key] with the JSON-encoded records.
  static Future<void> write(
    String key,
    List<Map<String, Object?>> values,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(key, jsonEncode(values));
    if (!saved) throw StateError('Local records could not be saved.');
  }
}
