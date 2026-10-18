import 'package:flutter/material.dart';

/// Ordered top-level app pages; AppTab.values must match MainTabPage's children.
enum AppTab {
  equipment,
  spareParts,
  people,
  business,
  message,
  information,
  applicationDb,
  help,
}

/// Presentation metadata used to render a tab's title and icon consistently.
extension AppTabPresentation on AppTab {
  String get label => switch (this) {
    AppTab.equipment => 'Equipment',
    AppTab.spareParts => 'Spare Parts',
    AppTab.people => 'People',
    AppTab.business => 'Business',
    AppTab.message => 'Message',
    AppTab.information => 'Information',
    AppTab.applicationDb => 'Application DB',
    AppTab.help => 'Help',
  };

  IconData get icon => switch (this) {
    AppTab.equipment => Icons.precision_manufacturing_outlined,
    AppTab.spareParts => Icons.build_outlined,
    AppTab.people => Icons.people_outline,
    AppTab.business => Icons.business_outlined,
    AppTab.message => Icons.message_outlined,
    AppTab.information => Icons.contact_support_outlined,
    AppTab.applicationDb => Icons.storage_outlined,
    AppTab.help => Icons.help_outline,
  };
}
