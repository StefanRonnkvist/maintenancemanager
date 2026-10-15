import 'package:flutter/material.dart';

import 'models/app_tab.dart';
import 'models/business_entry.dart';
import 'tabs/business_tab.dart';
import 'tabs/information_tabs.dart';
import 'tabs/equipment_tab.dart';
import 'tabs/spare_parts_tab.dart';
import 'tabs/application_db_tab.dart';
import 'widgets/app_tab_item.dart';

class MaintenanceManagerApp extends StatelessWidget {
  const MaintenanceManagerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Maintenance Manager',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    ),
    home: const MainTabPage(),
  );
}

class MainTabPage extends StatefulWidget {
  const MainTabPage({super.key});

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage>
    with SingleTickerProviderStateMixin {
  static const List<AppTab> _tabs = AppTab.values;

  late final TabController _controller;
  final List<BusinessEntry> _people = [];
  final List<BusinessEntry> _businesses = [];

  @override
  void initState() {
    super.initState();
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
      bottom: TabBar(
        controller: _controller,
        tabs: _tabs.map((tab) => AppTabItem(tab: tab)).toList(),
      ),
    ),
    body: TabBarView(
      controller: _controller,
      children: [
        EquipmentTab(businesses: _businesses),
        const SparePartsTab(),
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
        const ApplicationDbTab(),
      ],
    ),
  );
}
