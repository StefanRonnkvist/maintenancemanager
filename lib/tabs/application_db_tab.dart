import 'package:flutter/material.dart';

import '../db/application_db_page.dart';
import '../models/ui_text_catalog.dart';

class ApplicationDbTab extends StatelessWidget {
  const ApplicationDbTab({required this.text, super.key});

  final UiTextCatalog text;

  @override
  Widget build(BuildContext context) => ApplicationDbPage(text: text);
}
