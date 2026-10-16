import 'package:flutter/material.dart';

enum AppTab {
  equipment,
  spareParts,
  people,
  business,
  information,
  applicationDb,
  help,
}

extension AppTabPresentation on AppTab {
  String get label => switch (this) {
    AppTab.equipment => 'Equipment',
    AppTab.spareParts => 'Spare Parts',
    AppTab.people => 'People',
    AppTab.business => 'Business',
    AppTab.information => 'Information',
    AppTab.applicationDb => 'Application DB',
    AppTab.help => 'Help',
  };

  IconData get icon => switch (this) {
    AppTab.equipment => Icons.precision_manufacturing_outlined,
    AppTab.spareParts => Icons.build_outlined,
    AppTab.people => Icons.people_outline,
    AppTab.business => Icons.business_outlined,
    AppTab.information => Icons.contact_support_outlined,
    AppTab.applicationDb => Icons.storage_outlined,
    AppTab.help => Icons.help_outline,
  };
}
