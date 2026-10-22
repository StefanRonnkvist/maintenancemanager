import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/app_tab.dart';
import 'models/business_entry.dart';
import 'models/spare_part_record.dart';
import 'services/local_record_store.dart';
import 'tabs/business_tab.dart';
import 'tabs/information_tabs.dart';
import 'tabs/help_tab.dart';
import 'tabs/equipment_tab.dart';
import 'tabs/spare_parts_tab.dart';
import 'tabs/application_db_tab.dart';
import 'tabs/message_tab.dart';
import 'tabs/work_order_tab.dart';
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

/// Hosts the app's primary tab navigation.
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
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
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
                const SizedBox(height: 24),
                Text(
                  'Tab order',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Drag tabs to change their order.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  buildDefaultDragHandles: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tabs.length,
                  onReorderItem: _reorderTabs,
                  itemBuilder: (context, index) {
                    final tab = _tabs[index];
                    return ListTile(
                      key: ValueKey(tab),
                      leading: Icon(tab.icon),
                      title: Text(tab.label),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Page construction is keyed by tab so changing order keeps each page paired
  // with its label and icon. The same order is stored in shared preferences.
  static const String _tabOrderStorageKey = 'main_tab_order';
  final List<AppTab> _tabs = List.of(AppTab.values);

  late final TabController _controller;
  bool _tabOrderLoaded = false;

  Future<void> _loadTabOrder() async {
    final preferences = await SharedPreferences.getInstance();
    final storedOrder = preferences.getStringList(_tabOrderStorageKey);
    if (!mounted) return;

    if (storedOrder != null) {
      final byName = {for (final tab in AppTab.values) tab.name: tab};
      final restored = <AppTab>[];
      for (final name in storedOrder) {
        final tab = byName[name];
        if (tab != null && !restored.contains(tab)) restored.add(tab);
      }
      for (final tab in AppTab.values) {
        if (!restored.contains(tab)) restored.add(tab);
      }
      _tabs
        ..clear()
        ..addAll(restored);
    }

    setState(() => _tabOrderLoaded = true);
  }

  void _reorderTabs(int oldIndex, int newIndex) {
    final selectedTab = _tabs[_controller.index];
    setState(() {
      final tab = _tabs.removeAt(oldIndex);
      _tabs.insert(newIndex, tab);
      _controller.index = _tabs.indexOf(selectedTab);
    });
    _saveTabOrder();
  }

  Future<void> _saveTabOrder() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _tabOrderStorageKey,
      _tabs.map((tab) => tab.name).toList(),
    );
  }

  // Each list is shared with its tab's records table and persistence handler.
  static const _peopleStorageKey = 'people_records_v1';
  static const _businessStorageKey = 'business_records_v1';
  final List<BusinessEntry> _people = [];
  final List<BusinessEntry> _businesses = [];
  MessagePrefillRequest? _messagePrefillRequest;

  void _prefillMessageFromSparePart({
    required BusinessEntry person,
    required SparePartRecord record,
  }) {
    _messagePrefillRequest = MessagePrefillRequest(
      business: record.vendorName,
      location: record.locationName,
      person: person,
      subject: [record.vendorDescription, record.vendorPartNumber]
          .where((part) => part.trim().isNotEmpty)
          .join(' — '),
      message: [
        ('OEM Part Number', record.oemPartNumber),
        ('OEM Description', record.oemDescription),
        ('Vendor Part Number', record.vendorPartNumber),
        ('Vendor Description', record.vendorDescription),
        ('Serial Number', record.serialNumber),
        ('Vendor Name', record.vendorName),
        ('Location Name', record.locationName),
        ('Quantity in Stock', record.quantityInStock),
        ('Storage Location', record.location),
      ].map((field) => '${field.$1}: ${field.$2}').join('\n'),
    );
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messageTabIndex = _tabs.indexOf(AppTab.message);
      if (messageTabIndex >= 0) _controller.animateTo(messageTabIndex);
    });
  }

  void _clearMessagePrefill() {
    if (_messagePrefillRequest != null) {
      setState(() => _messagePrefillRequest = null);
    }
  }

  Future<void> _loadSharedEntries() async {
    try {
      final rows = await Future.wait([
        LocalRecordStore.read(_peopleStorageKey),
        LocalRecordStore.read(_businessStorageKey),
      ]);
      if (!mounted) return;
      _people
        ..clear()
        ..addAll(rows[0].map(BusinessEntry.fromJson));
      _businesses
        ..clear()
        ..addAll(rows[1].map(BusinessEntry.fromJson));
    } catch (_) {
      // The management tabs report storage errors when they load their records.
    }
    if (mounted) setState(() {});
  }

  Widget _pageForTab(AppTab tab) => switch (tab) {
    AppTab.equipment => EquipmentTab(businessEntries: _businesses),
    AppTab.spareParts => SparePartsTab(
      businessEntries: _businesses,
      peopleEntries: _people,
      onMessagePersonSelected: _prefillMessageFromSparePart,
    ),
    AppTab.workOrder => WorkOrderTab(
      businessEntries: _businesses,
      peopleEntries: _people,
    ),
    AppTab.people => BusinessTab(
      entries: _people,
      businessEntries: _businesses,
      onAdd: (entry) => setState(() => _people.add(entry)),
      kind: BusinessTabKind.people,
    ),
    AppTab.business => BusinessTab(
      entries: _businesses,
      businessEntries: _businesses,
      onAdd: (entry) => setState(() => _businesses.add(entry)),
      kind: BusinessTabKind.business,
    ),
    AppTab.information => const InformationTabs(),
    AppTab.message => MessageTab(
      people: _people,
      businesses: _businesses,
      prefillRequest: _messagePrefillRequest,
      onPrefillHandled: _clearMessagePrefill,
    ),
    AppTab.applicationDb => const ApplicationDbTab(),
    AppTab.help => const HelpTab(),
  };

  @override
  void initState() {
    super.initState();
    // The ticker provider drives the animation shared by TabBar and TabBarView.
    _controller = TabController(length: _tabs.length, vsync: this);
    // Restore the shell immediately; load user-controlled preferences after first paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadTabOrder();
      _loadSharedEntries();
    });
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
    body: _tabOrderLoaded
        ? TabBarView(
            controller: _controller,
            children: _tabs.map(_pageForTab).toList(),
          )
        : const Center(child: CircularProgressIndicator()),
  );
}
