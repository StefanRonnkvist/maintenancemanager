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
  bool _formExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isPeople = widget.kind == BusinessTabKind.people;
    final title = isPeople ? 'People' : 'Business';
    return ManagementTabLayout(
      title: title,
      icon: isPeople ? Icons.people_outline : Icons.business_outlined,
      form: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              title: Text(isPeople ? 'Add person' : 'Add business'),
              trailing: Icon(
                _formExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onTap: () => setState(() => _formExpanded = !_formExpanded),
            ),
            if (_formExpanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: BusinessForm(
                  kind: widget.kind,
                  businesses: widget.businesses,
                  onSubmit: (entry) => setState(() => widget.onAdd(entry)),
                ),
              ),
          ],
        ),
      ),
      recordsTitle: isPeople ? 'People' : 'Businesses',
      records: Center(
        child: isPeople
            ? PeopleTable(entries: widget.entries)
            : BusinessTable(entries: widget.entries),
      ),
    );
  }
}

enum BusinessTabKind { people, business }
