import 'package:flutter/material.dart';

import '../models/business_entry.dart';

/// Work order page with business and location details selected from Business.
class WorkOrderTab extends StatefulWidget {
  const WorkOrderTab({required this.businesses, super.key});

  final List<BusinessEntry> businesses;

  @override
  State<WorkOrderTab> createState() => _WorkOrderTabState();
}

class _WorkOrderTabState extends State<WorkOrderTab> {
  String? _selectedBusinessName;
  String? _selectedLocationName;

  BusinessEntry? get _selectedBusiness => widget.businesses
      .where((business) => business.name == _selectedBusinessName)
      .firstOrNull;

  BusinessLocation? get _selectedLocation => _selectedBusiness?.locations
      .where((location) => location.name == _selectedLocationName)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    final business = _selectedBusiness;
    final location = _selectedLocation;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Work Order', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 280,
              child: DropdownButtonFormField<String>(
                initialValue: widget.businesses.any(
                  (item) => item.name == _selectedBusinessName,
                )
                    ? _selectedBusinessName
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  border: OutlineInputBorder(),
                ),
                items: widget.businesses
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.name,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (name) => setState(() {
                  _selectedBusinessName = name;
                  _selectedLocationName = null;
                }),
              ),
            ),
            SizedBox(
              width: 280,
              child: DropdownButtonFormField<String>(
                initialValue: business?.locations.any(
                  (item) => item.name == _selectedLocationName,
                ) == true
                    ? _selectedLocationName
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  border: OutlineInputBorder(),
                ),
                items: (business?.locations ?? const <BusinessLocation>[])
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.name,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: business == null
                    ? null
                    : (name) => setState(() => _selectedLocationName = name),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _detailField('Location Address', location?.address),
        _detailField('Location Direct Phone Number', location?.directPhone),
        _detailField('Location Airports', location?.nearestAirport),
      ],
    );
  }

  Widget _detailField(String label, String? value) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      key: ValueKey('$label-${value ?? ''}'),
      initialValue: value ?? '',
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}
