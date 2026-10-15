import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import 'management_record_table.dart';

class PeopleTable extends StatelessWidget {
  const PeopleTable({required this.entries, super.key});
  final List<BusinessEntry> entries;

  @override
  Widget build(BuildContext context) => ManagementRecordTable(
    columns: const [
      'Name',
      'Business Name',
      'Location Name',
      'Nearest Airport',
      'Address',
      'Direct Phone',
      'Extension',
      'Cell Phone',
      'eMail',
    ],
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
    emptyMessage: 'No people added yet.',
  );
}

class BusinessTable extends StatelessWidget {
  const BusinessTable({required this.entries, super.key});
  final List<BusinessEntry> entries;

  @override
  Widget build(BuildContext context) => ManagementRecordTable(
    columns: const [
      'Business name',
      'Business Address',
      'Business Direct Phone',
      'Nearest Airport',
      'Location Name',
      'Location Address',
      'Location Direct Phone',
      'Location Nearest Airport',
      'Business Type',
    ],
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
    emptyMessage: 'No businesses added yet.',
  );
}
