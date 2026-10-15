import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import '../models/ui_text_catalog.dart';
import 'management_record_table.dart';

class PeopleTable extends StatelessWidget {
  const PeopleTable({required this.entries, required this.text, super.key});
  final List<BusinessEntry> entries;
  final UiTextCatalog text;

  @override
  Widget build(BuildContext context) => ManagementRecordTable(
    columns: text.tableColumns('people'),
    rows: [
      for (final entry in entries)
        [
          entry.name,
          entry.businessName,
          entry.locationName,
          entry.nearestAirport,
          entry.address,
          entry.directPhone,
          entry.directPhoneExtension,
          entry.cellPhone,
          entry.email,
        ],
    ],
    emptyMessage: text.text('emptyMessage', tab: 'people'),
  );
}

class BusinessTable extends StatelessWidget {
  const BusinessTable({required this.entries, required this.text, super.key});
  final List<BusinessEntry> entries;
  final UiTextCatalog text;

  @override
  Widget build(BuildContext context) => ManagementRecordTable(
    columns: text.tableColumns('business'),
    rows: [
      for (final business in entries)
        if (business.locations.isEmpty)
          [
            business.name,
            business.address,
            business.directPhone,
            business.nearestAirport,
            '',
            '',
            '',
            '',
            business.businessType,
          ]
        else
          for (var index = 0; index < business.locations.length; index++)
            [
              if (index == 0) business.name else '',
              if (index == 0) business.address else '',
              if (index == 0) business.directPhone else '',
              if (index == 0) business.nearestAirport else '',
              business.locations[index].name,
              business.locations[index].address,
              business.locations[index].directPhone,
              business.locations[index].nearestAirport,
              if (index == 0) business.businessType else '',
            ],
    ],
    emptyMessage: text.text('emptyMessage', tab: 'business'),
  );
}
