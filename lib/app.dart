import 'package:flutter/material.dart';

import 'models/app_tab.dart';
import 'models/business_entry.dart';
import 'tabs/business_tab.dart';
import 'tabs/information_tabs.dart';
import 'tabs/help_tab.dart';
import 'tabs/equipment_tab.dart';
import 'tabs/spare_parts_tab.dart';
import 'tabs/application_db_tab.dart';
import 'tabs/message_tab.dart';
import 'widgets/app_tab_item.dart';

/// Appearance choices exposed in the Settings bottom sheet.
enum AppThemeMode { system, dark, light }

/// Configures the app themes and owns the selected appearance mode.
class MaintenanceManagerApp extends StatefulWidget {
  const MaintenanceManagerApp({super.key});

  @override
  State<MaintenanceManagerApp> createState() => _MaintenanceManagerAppState();
}

class _MaintenanceManagerAppState extends State<MaintenanceManagerApp> {
  // Start in dark mode; Settings can switch to system or light appearance.
  AppThemeMode _themeMode = AppThemeMode.dark;

  void _setThemeMode(AppThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Maintenance Manager',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    ),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    ),
    themeMode: switch (_themeMode) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.light => ThemeMode.light,
    },
    home: MainTabPage(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
  );
}

/// Hosts the primary navigation and shares the people/business lists between tabs.
class MainTabPage extends StatefulWidget {
  const MainTabPage({
    required this.themeMode,
    required this.onThemeModeChanged,
    super.key,
  });

  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onThemeModeChanged;

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage>
    with SingleTickerProviderStateMixin {
  // Settings updates the app-level theme selection through the parent callback.
  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Settings', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<AppThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: AppThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.settings_brightness_outlined),
                  ),
                  ButtonSegment(
                    value: AppThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                  ButtonSegment(
                    value: AppThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                ],
                selected: {widget.themeMode},
                onSelectionChanged: (selection) =>
                    widget.onThemeModeChanged(selection.first),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Keep tab labels, icons, and page order driven by the same enum sequence.
  static const List<AppTab> _tabs = AppTab.values;

  late final TabController _controller;

  // These shared lists connect records across tabs during this app session.
  // Each management tab is also responsible for saving its records locally.
  final List<BusinessEntry> _people = [];
  final List<BusinessEntry> _businesses = [];

  @override
  void initState() {
    super.initState();
    // The ticker provider drives the animation shared by TabBar and TabBarView.
    _controller = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Maintenance Manager'),
      actions: [
        IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: _openSettings,
        ),
      ],
      bottom: TabBar(
        controller: _controller,
        tabs: _tabs.map((tab) => AppTabItem(tab: tab)).toList(),
      ),
    ),
    body: TabBarView(
      controller: _controller,
      // Keep these pages in the same order as AppTab.values above.
      children: [
        EquipmentTab(businesses: _businesses),
        SparePartsTab(businesses: _businesses),
        BusinessTab(
          entries: _people,
          onAdd: (entry) => setState(() => _people.add(entry)),
          kind: BusinessTabKind.people,
          businesses: _businesses,
        ),
        BusinessTab(
          entries: _businesses,
          onAdd: (entry) => setState(() => _businesses.add(entry)),
          kind: BusinessTabKind.business,
        ),
        const InformationTabs(),
        MessageTab(people: _people, businesses: _businesses),
        const ApplicationDbTab(),
        const HelpTab(),
      ],
    ),
  );
}
