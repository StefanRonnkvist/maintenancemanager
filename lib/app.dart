import 'package:flutter/material.dart';

import 'models/app_tab.dart';
import 'models/ui_text_catalog.dart';
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
  Widget build(BuildContext context) => FutureBuilder<UiTextCatalog>(
    future: UiTextCatalog.load(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      }
      final textCatalog = snapshot.data!;
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: textCatalog.appTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 57),
            displayMedium: TextStyle(fontSize: 45),
            displaySmall: TextStyle(fontSize: 36),
            headlineLarge: TextStyle(fontSize: 32),
            headlineMedium: TextStyle(fontSize: 28),
            headlineSmall: TextStyle(fontSize: 24),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            bodyLarge: TextStyle(fontSize: 16),
            bodyMedium: TextStyle(fontSize: 14),
            bodySmall: TextStyle(fontSize: 12),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
        home: MainTabPage(textCatalog: textCatalog),
      );
    },
  );
}

class MainTabPage extends StatefulWidget {
  const MainTabPage({required this.textCatalog, super.key});

  final UiTextCatalog textCatalog;

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
      title: Text(widget.textCatalog.text('title')),
      bottom: TabBar(
        controller: _controller,
        tabs: _tabs
            .map((tab) => AppTabItem(tab: tab, text: widget.textCatalog))
            .toList(),
      ),
    ),
    body: TabBarView(
      controller: _controller,
      children: [
        EquipmentTab(businesses: _businesses, text: widget.textCatalog),
        SparePartsTab(text: widget.textCatalog),
        BusinessTab(
          entries: _people,
          onAdd: (entry) => setState(() => _people.add(entry)),
          kind: BusinessTabKind.people,
          text: widget.textCatalog,
          businesses: _businesses,
        ),
        BusinessTab(
          entries: _businesses,
          onAdd: (entry) => setState(() => _businesses.add(entry)),
          kind: BusinessTabKind.business,
          text: widget.textCatalog,
        ),
        InformationTabs(text: widget.textCatalog),
        const ApplicationDbTab(),
      ],
    ),
  );
}
