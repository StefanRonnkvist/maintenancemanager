import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import '../models/ui_text_catalog.dart';
import '../widgets/business_form.dart';
import '../widgets/business_table.dart';
import '../widgets/management_tab_layout.dart';

class BusinessTab extends StatefulWidget {
  const BusinessTab({
    required this.entries,
    required this.onAdd,
    required this.kind,
    required this.text,
    this.businesses = const [],
    super.key,
  });

  final List<BusinessEntry> entries;
  final ValueChanged<BusinessEntry> onAdd;
  final BusinessTabKind kind;
  final UiTextCatalog text;
  final List<BusinessEntry> businesses;

  @override
  State<BusinessTab> createState() => _BusinessTabState();
}

class _BusinessTabState extends State<BusinessTab> {
  @override
  Widget build(BuildContext context) => ManagementTabLayout(
    title: widget.text.tabTitle(
      widget.kind == BusinessTabKind.people ? 'people' : 'business',
    ),
    form: BusinessForm(
      kind: widget.kind,
      text: widget.text,
      businesses: widget.businesses,
      onSubmit: (entry) => setState(() => widget.onAdd(entry)),
    ),
    recordsTitle: widget.text(
      'recordsTitle',
      tab: widget.kind == BusinessTabKind.people ? 'people' : 'business',
    ),
    records: widget.kind == BusinessTabKind.people
        ? PeopleTable(entries: widget.entries, text: widget.text)
        : BusinessTable(entries: widget.entries, text: widget.text),
  );
}

enum BusinessTabKind { people, business }
