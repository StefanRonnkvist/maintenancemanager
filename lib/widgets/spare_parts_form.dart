import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import '../models/spare_part_record.dart';
import 'business_table.dart';

/// Form for entering a spare part and emitting a complete record on submit.
class SparePartsForm extends StatefulWidget {
  const SparePartsForm({
    required this.vendorEntries,
    required this.oemPartNumber,
    required this.oemDescription,
    required this.vendorPartNumber,
    required this.vendorDescription,
    required this.serialNumber,
    required this.vendorName,
    required this.locationName,
    required this.quantityInStock,
    required this.location,
    required this.onAdd,
    this.isEditing = false,
    this.peopleAboveSubmit,
    this.onPersonTap,
    super.key,
  });

  final List<BusinessEntry> vendorEntries;
  final TextEditingController oemPartNumber;
  final TextEditingController oemDescription;
  final TextEditingController vendorPartNumber;
  final TextEditingController vendorDescription;
  final TextEditingController serialNumber;
  final TextEditingController vendorName;
  final TextEditingController locationName;
  final TextEditingController quantityInStock;
  final TextEditingController location;
  final ValueChanged<SparePartRecord> onAdd;
  final bool isEditing;
  final List<BusinessEntry>? peopleAboveSubmit;
  final ValueChanged<BusinessEntry>? onPersonTap;

  @override
  State<SparePartsForm> createState() => _SparePartsFormState();
}

class _SparePartsFormState extends State<SparePartsForm> {
  List<BusinessLocation> get _selectedBusinessLocations => widget.vendorEntries
      .where((entry) => entry.name.trim() == widget.vendorName.text.trim())
      .expand((entry) => entry.locations)
      .toList(growable: false);

  /// Builds a record from the controllers and ignores a completely blank form.
  void _submit() {
    final record = SparePartRecord(
      oemPartNumber: widget.oemPartNumber.text.trim(),
      oemDescription: widget.oemDescription.text.trim(),
      vendorPartNumber: widget.vendorPartNumber.text.trim(),
      vendorDescription: widget.vendorDescription.text.trim(),
      serialNumber: widget.serialNumber.text.trim(),
      vendorName: widget.vendorName.text.trim(),
      locationName: widget.locationName.text.trim(),
      quantityInStock: widget.quantityInStock.text.trim(),
      location: widget.location.text.trim(),
    );
    if (record.values.every((value) => value.isEmpty)) return;
    widget.onAdd(record);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _field(widget.oemPartNumber, 'OEM Part Number'),
      const SizedBox(height: 16),
      _field(widget.oemDescription, 'OEM Description'),
      const SizedBox(height: 16),
      _field(widget.vendorPartNumber, 'Vendor Part Number'),
      const SizedBox(height: 16),
      _field(widget.vendorDescription, 'Vendor Description'),
      const SizedBox(height: 16),
      _field(
        widget.serialNumber,
        'Serial Numbers',
        helperText: 'Enter multiple serial numbers separated by commas or new lines.',
        minLines: 1,
        maxLines: 3,
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        key: ValueKey('vendor-${widget.vendorName.text}'),
        initialValue:
            widget.vendorEntries.any(
              (entry) => entry.name.trim() == widget.vendorName.text.trim(),
            )
            ? widget.vendorName.text.trim()
            : null,
        decoration: const InputDecoration(
          labelText: 'Vendor Name',
          border: OutlineInputBorder(),
        ),
        isExpanded: true,
        items: [
          for (final vendor in widget.vendorEntries)
            DropdownMenuItem(
              value: vendor.name.trim(),
              child: Text(vendor.name.trim()),
            ),
        ],
        onChanged: (name) => setState(() {
          widget.vendorName.text = name ?? '';
          widget.locationName.clear();
        }),
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        key: ValueKey(
          'location-${widget.vendorName.text}-${widget.locationName.text}',
        ),
        initialValue:
            _selectedBusinessLocations.any(
              (location) =>
                  location.name.trim() == widget.locationName.text.trim(),
            )
            ? widget.locationName.text.trim()
            : null,
        decoration: const InputDecoration(
          labelText: 'Location Name',
          border: OutlineInputBorder(),
        ),
        isExpanded: true,
        items: [
          for (final location in _selectedBusinessLocations)
            if (location.name.trim().isNotEmpty)
              DropdownMenuItem(
                value: location.name.trim(),
                child: Text(location.name.trim()),
              ),
        ],
        onChanged: (name) => setState(() {
          widget.locationName.text = name ?? '';
        }),
      ),
      const SizedBox(height: 16),
      _field(
        widget.quantityInStock,
        'Quantity in Stock',
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      _field(widget.location, 'Storage Location'),
      if (widget.peopleAboveSubmit != null) ...[
        const SizedBox(height: 20),
        Text(
          'People for ${widget.vendorName.text} — ${widget.locationName.text}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        PeopleTable(
          entries: widget.peopleAboveSubmit!,
          onRowTap: (person) => widget.onPersonTap?.call(person),
          selectedEntry: null,
          emptyMessage: 'No people match this vendor and location.',
        ),
      ],
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.add),
          label: Text(
            widget.isEditing ? 'Update Spare Parts' : 'Add Spare Part',
          ),
        ),
      ),
    ],
  );

  /// Consistent labelled text field used for the free-entry part attributes.
  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    String? helperText,
    int minLines = 1,
    int maxLines = 1,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    minLines: minLines,
    maxLines: maxLines,
    decoration: InputDecoration(
      labelText: label,
      helperText: helperText,
      border: const OutlineInputBorder(),
    ),
  );
}
