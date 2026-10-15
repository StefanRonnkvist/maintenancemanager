import 'dart:convert';

import 'package:flutter/services.dart';

class UiTextCatalog {
  UiTextCatalog._(this._staticConfig);

  static const assetPath = 'assets/config/static_config.json';
  static Future<UiTextCatalog>? _loading;
  static UiTextCatalog? _instance;

  static UiTextCatalog get current =>
      _instance ?? (throw StateError('UiTextCatalog has not been loaded.'));

  final Map<String, dynamic> _staticConfig;

  String call(String key, {String? tab, String? fallback}) =>
      lookup(key, tab: tab, fallback: fallback);

  static Future<UiTextCatalog> load({AssetBundle? bundle}) =>
      _loading ??= _load(bundle ?? rootBundle);

  static Future<UiTextCatalog> _load(AssetBundle bundle) async {
    final jsonText = await bundle.loadString(assetPath);
    final staticConfig = jsonDecode(jsonText);
    if (staticConfig is! Map<String, dynamic>) {
      throw const FormatException(
        'Configuration asset must contain a JSON object.',
      );
    }
    final catalog = UiTextCatalog._(staticConfig);
    _instance = catalog;
    return catalog;
  }

  String get appTitle => lookup('title', fallback: 'Maintenance Manager');

  String tabTitle(String tab) => lookup('title', tab: tab, fallback: tab);

  String lookup(String key, {String? tab, String? fallback}) {
    final tabs = _staticConfig['tabs'];
    final tabData = tabs is Map<String, dynamic> && tab != null
        ? tabs[tab]
        : null;
    final value = tabData is Map<String, dynamic>
        ? tabData[key]
        : null;
    final appData = _staticConfig['app'];
    final appValue = appData is Map<String, dynamic> ? appData[key] : null;
    final selected = value ?? appValue ?? fallback;
    if (selected is! String) {
      throw FormatException('Missing UI text "$key" for tab "$tab".');
    }
    return selected;
  }

  String text(String key, {String? tab, String? fallback}) =>
      lookup(key, tab: tab, fallback: fallback);

  List<String> list(String key, {String? tab}) {
    final tabs = _staticConfig['tabs'];
    final source = tab == null
        ? _staticConfig['app']
        : tabs is Map<String, dynamic>
        ? tabs[tab]
        : null;
    final value = source is Map<String, dynamic> ? source[key] : null;
    if (value is List<dynamic> && value.every((item) => item is String)) {
      return List<String>.unmodifiable(value.cast<String>());
    }
    throw FormatException('Missing list "$key" for tab "$tab".');
  }

  Map<String, List<String>> stringListMap(String key, {String? tab}) {
    final tabs = _staticConfig['tabs'];
    final source = tab == null
        ? _staticConfig['app']
        : tabs is Map<String, dynamic>
        ? tabs[tab]
        : null;
    final value = source is Map<String, dynamic> ? source[key] : null;
    if (value is Map<String, dynamic> &&
        value.values.every(
          (items) =>
              items is List<dynamic> && items.every((item) => item is String),
        )) {
      return Map<String, List<String>>.unmodifiable({
        for (final entry in value.entries)
          entry.key: List<String>.unmodifiable(entry.value.cast<String>()),
      });
    }
    throw FormatException('Missing list map "$key" for tab "$tab".');
  }

  double number(String key, {String? tab}) {
    final tabs = _staticConfig['tabs'];
    final source = tab == null
        ? _staticConfig['app']
        : tabs is Map<String, dynamic>
        ? tabs[tab]
        : null;
    final value = source is Map<String, dynamic> ? source[key] : null;
    if (value is num) return value.toDouble();
    throw FormatException('Missing number "$key" for tab "$tab".');
  }

  double configNumber(String group, String key) {
    final value = _configGroup(group)[key];
    if (value is num) return value.toDouble();
    throw FormatException('Missing config number "$group.$key".');
  }

  int configInteger(String group, String key) {
    final value = _configGroup(group)[key];
    if (value is int) return value;
    throw FormatException('Missing config integer "$group.$key".');
  }

  List<String> configList(String group, String key) {
    final value = _configGroup(group)[key];
    if (value is List<dynamic> && value.every((item) => item is String)) {
      return List<String>.unmodifiable(value.cast<String>());
    }
    throw FormatException('Missing config list "$group.$key".');
  }

  Map<String, dynamic> _configGroup(String group) {
    final app = _staticConfig['app'];
    final groupValue = app is Map<String, dynamic> ? app[group] : null;
    if (groupValue is Map<String, dynamic>) return groupValue;
    throw FormatException('Missing config group "$group".');
  }

  int integer(String key, {String? tab}) {
    final tabs = _staticConfig['tabs'];
    final source = tab == null
        ? _staticConfig['app']
        : tabs is Map<String, dynamic>
        ? tabs[tab]
        : null;
    final value = source is Map<String, dynamic> ? source[key] : null;
    if (value is int) return value;
    throw FormatException('Missing integer "$key" for tab "$tab".');
  }

  String themeString(String key) {
    final appData = _staticConfig['app'];
    final theme = appData is Map<String, dynamic> ? appData['theme'] : null;
    final value = theme is Map<String, dynamic> ? theme[key] : null;
    if (value is String) return value;
    throw FormatException('Missing theme setting "$key".');
  }

  double themeNumber(String key) {
    final appData = _staticConfig['app'];
    final theme = appData is Map<String, dynamic> ? appData['theme'] : null;
    final sizes = theme is Map<String, dynamic> ? theme['textSizes'] : null;
    final value = sizes is Map<String, dynamic> ? sizes[key] : null;
    if (value is num) return value.toDouble();
    throw FormatException('Missing theme text size "$key".');
  }

  String configText(String group, String key) {
    final value = _configGroup(group)[key];
    if (value is String) return value;
    throw FormatException('Missing config text "$group.$key".');
  }

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
    final value =
        _mapValue(_tab(tab)['actions'], key) ??
        _mapValue(
          (_staticConfig[tab] as Map<String, dynamic>?)?['actions'],
          key,
        ) ??
        _mapValue(
          (_staticConfig['app'] as Map<String, dynamic>?)?['actions'],
          key,
        );
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
    final tabs = _staticConfig['tabs'];
    final value = tabs is Map<String, dynamic> ? tabs[tab] : null;
    if (value is Map<String, dynamic>) return value;
    throw FormatException('Missing UI text for tab "$tab".');
  }

  static Object? _mapValue(Object? source, String key) =>
      source is Map<String, dynamic> ? source[key] : null;
}
