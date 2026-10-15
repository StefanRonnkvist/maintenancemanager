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
          colorScheme: ColorScheme.fromSeed(
            seedColor: textCatalog.themeString('seedColor') == 'indigo'
                ? Colors.indigo
                : Colors.blue,
          ),
          useMaterial3: true,
          fontFamily: textCatalog.themeString('fontFamily'),
          textTheme: TextTheme(
            displayLarge: TextStyle(
              fontSize: textCatalog.themeNumber('displayLarge'),
            ),
            displayMedium: TextStyle(
              fontSize: textCatalog.themeNumber('displayMedium'),
            ),
            displaySmall: TextStyle(
              fontSize: textCatalog.themeNumber('displaySmall'),
            ),
            headlineLarge: TextStyle(
              fontSize: textCatalog.themeNumber('headlineLarge'),
            ),
            headlineMedium: TextStyle(
              fontSize: textCatalog.themeNumber('headlineMedium'),
            ),
            headlineSmall: TextStyle(
              fontSize: textCatalog.themeNumber('headlineSmall'),
            ),
            titleLarge: TextStyle(
              fontSize: textCatalog.themeNumber('titleLarge'),
              fontWeight: FontWeight.w500,
            ),
            titleMedium: TextStyle(
              fontSize: textCatalog.themeNumber('titleMedium'),
              fontWeight: FontWeight.w500,
            ),
            titleSmall: TextStyle(
              fontSize: textCatalog.themeNumber('titleSmall'),
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: TextStyle(
              fontSize: textCatalog.themeNumber('bodyLarge'),
            ),
            bodyMedium: TextStyle(
              fontSize: textCatalog.themeNumber('bodyMedium'),
            ),
            bodySmall: TextStyle(
              fontSize: textCatalog.themeNumber('bodySmall'),
            ),
            labelLarge: TextStyle(
              fontSize: textCatalog.themeNumber('labelLarge'),
              fontWeight: FontWeight.w500,
            ),
            labelMedium: TextStyle(
              fontSize: textCatalog.themeNumber('labelMedium'),
              fontWeight: FontWeight.w500,
            ),
            labelSmall: TextStyle(
              fontSize: textCatalog.themeNumber('labelSmall'),
            ),
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

  static List<AppTab> tabs(UiTextCatalog text) => text
      .list('tabs')
      .map(
        (name) => AppTab.values.firstWhere(
          (tab) => tab.name == name,
          orElse: () => throw FormatException('Unknown app tab "$name".'),
        ),
      )
      .toList(growable: false);

  @override
  State<MainTabPage> createState() => _MainTabPageState();
}

class _MainTabPageState extends State<MainTabPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  late final List<AppTab> _tabs = MainTabPage.tabs(widget.textCatalog);
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
        ApplicationDbTab(text: widget.textCatalog),
      ],
    ),
  );
}
