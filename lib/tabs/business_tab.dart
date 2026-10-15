import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import '../widgets/business_form.dart';
import '../widgets/business_table.dart';
import '../widgets/management_tab_layout.dart';

class BusinessTab extends StatefulWidget {
  const BusinessTab({
    required this.entries,
    required this.onAdd,
    required this.kind,
    this.businesses = const [],
    super.key,
  });

  final List<BusinessEntry> entries;
  final ValueChanged<BusinessEntry> onAdd;
  final BusinessTabKind kind;
  final List<BusinessEntry> businesses;

  @override
  State<BusinessTab> createState() => _BusinessTabState();
}

class _BusinessTabState extends State<BusinessTab> {
  @override
  Widget build(BuildContext context) => ManagementTabLayout(
    form: BusinessForm(
      kind: widget.kind,
      businesses: widget.businesses,
      onSubmit: (entry) => setState(() => widget.onAdd(entry)),
    ),
    recordsTitle: widget.kind == BusinessTabKind.people
        ? 'People'
        : 'Businesses',
    records: widget.kind == BusinessTabKind.people
        ? PeopleTable(entries: widget.entries)
        : BusinessTable(entries: widget.entries),
  );
}

enum BusinessTabKind { people, business }
