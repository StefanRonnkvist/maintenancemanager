import 'package:flutter/material.dart';

import '../models/app_tab.dart';

class AppTabItem extends StatelessWidget {
  const AppTabItem({required this.tab, super.key});

  final AppTab tab;

  @override
  Widget build(BuildContext context) =>
      Tab(icon: Icon(tab.icon), text: tab.label);
}
