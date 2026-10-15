import 'package:flutter/material.dart';

import '../models/app_tab.dart';
import '../models/ui_text_catalog.dart';

class AppTabItem extends StatelessWidget {
  const AppTabItem({required this.tab, required this.text, super.key});

  final AppTab tab;
  final UiTextCatalog text;

  @override
  Widget build(BuildContext context) =>
      Tab(icon: Icon(tab.icon), text: tab.label(text));
}
