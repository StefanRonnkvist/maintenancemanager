import 'package:flutter/material.dart';

import 'ui_text_catalog.dart';

enum AppTab {
  equipment,
  spareParts,
  people,
  business,
  information,
  applicationDb,
}

extension AppTabPresentation on AppTab {
  String label(UiTextCatalog text) => switch (this) {
    AppTab.equipment => text.tabTitle('equipment'),
    AppTab.spareParts => text.tabTitle('spareParts'),
    AppTab.people => text.tabTitle('people'),
    AppTab.business => text.tabTitle('business'),
    AppTab.information => text.tabTitle('information'),
    AppTab.applicationDb => text.tabTitle('applicationDb'),
  };

  IconData get icon => switch (this) {
    AppTab.equipment => Icons.precision_manufacturing_outlined,
    AppTab.spareParts => Icons.build_outlined,
    AppTab.people => Icons.people_outline,
    AppTab.business => Icons.business_outlined,
    AppTab.information => Icons.contact_support_outlined,
    AppTab.applicationDb => Icons.storage_outlined,
  };
}
