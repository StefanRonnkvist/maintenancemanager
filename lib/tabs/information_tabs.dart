import 'package:flutter/material.dart';

import '../contact/contact_page.dart';
import '../contact/submissions_csv_page.dart';

/// Groups support contact and app-specific submission responses under Information.
class InformationTabs extends StatelessWidget {
  const InformationTabs({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        const Material(
          color: Colors.transparent,
          child: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.contact_support_outlined), text: 'Contact'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Submissions'),
            ],
          ),
        ),
        // The nested views share this controller created by DefaultTabController.
        Expanded(
          child: TabBarView(
            children: [
              ContactPage(
                serverUri: Uri.https('stefanronnkvist.com', '/contact'),
                showAppBar: false,
                wrapInScaffold: false,
              ),
              SubmissionsCsvCardsView(),
            ],
          ),
        ),
      ],
    ),
  );
}
