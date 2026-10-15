import 'dart:convert';

import 'package:flutter/services.dart';

class UiTextCatalog {
  UiTextCatalog._(this._data);

  static const assetPath = 'assets/text/ui_text.json';
  static Future<UiTextCatalog>? _loading;

  final Map<String, dynamic> _data;

  static Future<UiTextCatalog> load({AssetBundle? bundle}) =>
      _loading ??= _load(bundle ?? rootBundle);

  static Future<UiTextCatalog> _load(AssetBundle bundle) async {
    final jsonText = await bundle.loadString(assetPath);
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('UI text asset must contain a JSON object.');
    }
    return UiTextCatalog._(decoded);
  }

  String get appTitle => lookup('title');

  String tabTitle(String tab) => lookup('title', tab: tab);

  String lookup(String key, {String? tab, String? fallback}) {
    final tabData = tab == null ? null : _data['tabs']?[tab];
    final value = tabData is Map<String, dynamic> ? tabData[key] : null;
    final appData = _data['app'];
    final appValue = appData is Map<String, dynamic> ? appData[key] : null;
    final selected = value ?? appValue ?? fallback;
    if (selected is! String) {
      throw FormatException('Missing UI text "$key" for tab "$tab".');
    }
    return selected;
  }

  String text(String key, {String? tab, String? fallback}) =>
      lookup(key, tab: tab, fallback: fallback);

  String option(String tab, String key, String value) {
    final values = _mapValue(_tab(tab)['options'], key);
    if (values is List<dynamic> && values.contains(value)) return value;
    throw FormatException('Missing option "$tab.$key.$value".');
  }

  String tabText(String tab, String key) {
    final value = _mapValue(_tab(tab)['tabs'], key);
    if (value is String) return value;
    throw FormatException('Missing nested tab text "$tab.$key".');
  }

  String action(String tab, String key) {
    final value = _mapValue(_tab(tab)['actions'], key);
    if (value is String) return value;
    throw FormatException('Missing action "$tab.$key".');
  }

  String section(String tab, String key) {
    final value = _mapValue(_tab(tab)['sections'], key);
    if (value is String) return value;
    throw FormatException('Missing section "$tab.$key".');
  }

  List<String> tableColumns(String tab) {
    final columns = _tab(tab)['tableColumns'];
    if (columns is List<dynamic> && columns.every((value) => value is String)) {
      return List<String>.unmodifiable(columns.cast<String>());
    }
    throw FormatException('Missing table columns for "$tab".');
  }

  String fieldLabel(String tab, String field) {
    final label = _field(tab, field)['label'];
    if (label is String) return label;
    throw FormatException('Missing label for "$tab.$field".');
  }

  String fieldType(String tab, String field) {
    final type = _field(tab, field)['type'];
    if (type is String) return type;
    throw FormatException('Missing data type for "$tab.$field".');
  }

  Map<String, dynamic> _field(String tab, String field) {
    final tabData = _tab(tab);
    final value = _mapValue(tabData['fields'], field);
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Missing field "$tab.$field".');
  }

  Map<String, dynamic> _tab(String tab) {
    final tabs = _data['tabs'];
    final value = tabs is Map<String, dynamic> ? tabs[tab] : null;
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Missing UI text for tab "$tab".');
  }

  static Object? _mapValue(Object? source, String key) =>
      source is Map<String, dynamic> ? source[key] : null;
}
