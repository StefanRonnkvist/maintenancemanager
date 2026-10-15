import 'package:flutter/material.dart';

import '../contact/contact_page.dart';
import '../contact/submissions_csv_page.dart';
import '../models/ui_text_catalog.dart';

class InformationTabs extends StatelessWidget {
  const InformationTabs({required this.text, super.key});

  final UiTextCatalog text;

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        Material(
          color: Colors.transparent,
          child: TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.contact_support_outlined),
                text: text.tabText('information', 'contact'),
              ),
              Tab(
                icon: Icon(Icons.receipt_long_outlined),
                text: text.tabText('information', 'submissions'),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              ContactPage(
                serverUri: Uri.https('stefanronnkvist.com', '/contact'),
                showAppBar: false,
                wrapInScaffold: false,
              ),
              SubmissionsCsvCardsView(text: text),
            ],
          ),
        ),
      ],
    ),
  );
}
