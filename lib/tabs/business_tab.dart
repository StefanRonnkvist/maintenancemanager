import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import '../widgets/business_form.dart';
import '../widgets/business_table.dart';

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
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth < 1100 ? constraints.maxWidth : 1100.0;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BusinessForm(
                  kind: widget.kind,
                  businesses: widget.businesses,
                  onSubmit: (entry) => setState(() => widget.onAdd(entry)),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.kind == BusinessTabKind.people
                      ? 'People'
                      : 'Businesses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Center(
                  child: widget.kind == BusinessTabKind.people
                      ? PeopleTable(entries: widget.entries)
                      : BusinessTable(entries: widget.entries),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

enum BusinessTabKind { people, business }
