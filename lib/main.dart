import 'package:flutter/material.dart';

import 'contact/contact_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tabbed App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TabBarViewPage(),
    );
  }
}

class TabBarViewPage extends StatefulWidget {
  const TabBarViewPage({super.key});

  @override
  State<TabBarViewPage> createState() => _TabBarViewPageState();
}

class _TabBarViewPageState extends State<TabBarViewPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<_TabItem> _tabs = const [
    _TabItem(label: 'Home', icon: Icons.home_outlined),
    _TabItem(label: 'Favorites', icon: Icons.favorite_outline),
    _TabItem(label: 'Profile', icon: Icons.person_outline),
    _TabItem(label: 'Information', icon: Icons.info_outline),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs
              .map((tab) => Tab(icon: Icon(tab.icon), text: tab.label))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ..._tabs.take(_tabs.length - 1).map(
                (tab) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.icon,
                        size: 56,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tab.label,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
          ContactPage(
            serverUri: Uri.https('stefanronnkvist.com', '/contact'),
            showAppBar: false,
            wrapInScaffold: false,
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
