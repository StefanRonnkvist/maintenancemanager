import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/business_entry.dart';
import '../tabs/business_tab.dart';
import 'form_section.dart';

/// Collects either a person/contact or business, depending on [kind].
class BusinessForm extends StatefulWidget {
  const BusinessForm({
    required this.kind,
    required this.onSubmit,
    this.initialEntry,
    this.businessNames = const [],
    this.businessLocations = const [],
    super.key,
  });

  final BusinessTabKind kind;
  final ValueChanged<BusinessEntry> onSubmit;
  final BusinessEntry? initialEntry;
  final List<String> businessNames;
  final List<String> businessLocations;

  @override
  State<BusinessForm> createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneExtensionController = TextEditingController();
  final _cellPhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nearestAirportController = TextEditingController();
  final List<TextEditingController> _locationNameControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _locationAddressControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _locationPhoneControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _locationAirportControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final _businessAssociationController = TextEditingController();
  final _personLocationController = TextEditingController();
  final List<BusinessLocation> _locations = [];
  final List<bool> _locationExpanded = List.filled(4, false);
  static const _businessTypes = ['Customer', 'Vendor', 'Principle'];
  String? _businessType;
  bool _remoteWork = false;
  List<String> _airportOptions = const [];

  double _airportFieldWidth(TextEditingController controller) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: controller.text.isEmpty ? 'Nearest Airport' : controller.text,
        style: const TextStyle(fontSize: 16),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    // Allow long airport names to expand instead of clipping at a fixed max width.
    return (textPainter.width + 80).clamp(260.0, double.infinity);
  }

  Widget _airportAutocomplete({
    required TextEditingController controller,
    required String label,
  }) => SizedBox(
    width: _airportFieldWidth(controller),
    child: Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable<String>.empty();
        return _airportOptions.where(
          (airport) => airport.toLowerCase().contains(query),
        );
      },
      onSelected: (airport) => controller.text = airport,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            textEditingController.addListener(() {
              controller.text = textEditingController.text;
            });
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            );
          },
    ),
  );

  // Both form variants reuse these controllers; kind determines which fields show.
  bool get _isPeople => widget.kind == BusinessTabKind.people;

  @override
  void initState() {
    super.initState();
    _populateFromEntry(widget.initialEntry);
    _loadAirports();
  }

  void _populateFromEntry(BusinessEntry? entry) {
    if (entry == null) return;
    _nameController.text = entry.name;
    _titleController.text = entry.title;
    _addressController.text = entry.address;
    _phoneController.text = entry.directPhone;
    _phoneExtensionController.text = entry.directPhoneExtension;
    _cellPhoneController.text = entry.cellPhone;
    _emailController.text = entry.email;
    _nearestAirportController.text = entry.nearestAirport;
    _businessAssociationController.text = entry.businessName;
    _personLocationController.text = entry.locationName;
    final businessType = entry.businessType.trim();
    _businessType = _businessTypes.contains(businessType) ? businessType : null;
    _remoteWork = entry.locationName == 'Remote Work';
    for (var index = 0; index < entry.locations.length && index < 4; index++) {
      final location = entry.locations[index];
      _locationNameControllers[index].text = location.name;
      _locationAddressControllers[index].text = location.address;
      _locationPhoneControllers[index].text = location.directPhone;
      _locationAirportControllers[index].text = location.nearestAirport;
      _locationExpanded[index] = true;
    }
  }

  Future<void> _loadAirports() async {
    final csv = await rootBundle.loadString('assets/airports.csv');
    final airports =
        csv
            .split(RegExp(r'\r?\n'))
            .skip(1)
            .map((row) {
              final columns = row.split(',');
              if (columns.length < 3) return null;
              final name = columns[0].trim();
              final code = columns[2].trim();
              return name.isEmpty || code.isEmpty ? null : '$name ($code)';
            })
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    if (mounted) setState(() => _airportOptions = airports);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _phoneExtensionController.dispose();
    _cellPhoneController.dispose();
    _emailController.dispose();
    _nearestAirportController.dispose();
    for (final controller in [
      ..._locationNameControllers,
      ..._locationAddressControllers,
      ..._locationPhoneControllers,
      ..._locationAirportControllers,
    ]) {
      controller.dispose();
    }
    _businessAssociationController.dispose();
    _personLocationController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? 'Enter $label' : null;

  Widget _field({
    required TextEditingController controller,
    required String label,
    double width = 260,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => SizedBox(
    width: width,
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    ),
  );

  /// Validates fields, emits the model, then resets the form for another entry.
  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onSubmit(
      BusinessEntry(
        name: _nameController.text.trim(),
        title: _isPeople ? _titleController.text.trim() : '',
        address: _addressController.text.trim(),
        directPhone: _phoneController.text.trim(),
        directPhoneExtension: _phoneExtensionController.text.trim(),
        businessType: _isPeople ? '' : 'Customer',
        cellPhone: _cellPhoneController.text.trim(),
        email: _emailController.text.trim(),
        businessName: _isPeople
            ? _businessAssociationController.text.trim()
            : '',
        locationName: _isPeople
            ? (_remoteWork
                  ? 'Remote Work'
                  : _personLocationController.text.trim())
            : '',
        nearestAirport: _nearestAirportController.text.trim(),
        locations: List.unmodifiable([
          ..._locations,
          for (var index = 0; index < 4; index++)
            if (_locationNameControllers[index].text.trim().isNotEmpty ||
                _locationAddressControllers[index].text.trim().isNotEmpty ||
                _locationPhoneControllers[index].text.trim().isNotEmpty ||
                _locationAirportControllers[index].text.trim().isNotEmpty)
              BusinessLocation(
                name: _locationNameControllers[index].text.trim(),
                address: _locationAddressControllers[index].text.trim(),
                directPhone: _locationPhoneControllers[index].text.trim(),
                nearestAirport: _locationAirportControllers[index].text.trim(),
              ),
        ]),
        airports: _isPeople || _nearestAirportController.text.trim().isEmpty
            ? const []
            : [_nearestAirportController.text.trim()],
      ),
    );
    _nameController.clear();
    _titleController.clear();
    _addressController.clear();
    _phoneController.clear();
    _cellPhoneController.clear();
    _emailController.clear();
    _nearestAirportController.clear();
    for (final controller in [
      ..._locationNameControllers,
      ..._locationAddressControllers,
      ..._locationPhoneControllers,
      ..._locationAirportControllers,
    ]) {
      controller.clear();
    }
    _businessAssociationController.clear();
    _personLocationController.clear();
    setState(() {
      _businessType = null;
      _remoteWork = false;
      _locations.clear();
    });
  }

  /// Person details and contact information, followed by work location.
  Widget _peopleFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FormSection(
        title: 'Personal and contact details',
        icon: Icons.person_outline,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _field(
              controller: _nameController,
              label: 'Name',
              validator: (value) => _required(value, 'a name'),
            ),
            _field(controller: _titleController, label: 'Title'),
            _field(
              controller: _phoneController,
              label: 'Direct Phone',
              keyboardType: TextInputType.phone,
            ),
            _field(
              controller: _phoneExtensionController,
              label: 'Extension',
              keyboardType: TextInputType.number,
            ),
            _field(
              controller: _cellPhoneController,
              label: 'Cell Phone',
              keyboardType: TextInputType.phone,
            ),
            _field(
              controller: _emailController,
              label: 'eMail',
              keyboardType: TextInputType.emailAddress,
            ),
            _field(
              controller: _addressController,
              label: 'Address',
              width: 300,
              validator: (value) => _required(value, 'an address'),
            ),
            _airportAutocomplete(
              controller: _nearestAirportController,
              label: 'Nearest Airport',
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FormSection(
        title: 'Work location',
        icon: Icons.location_on_outlined,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<String>(
                initialValue:
                    widget.businessNames.contains(
                      _businessAssociationController.text,
                    )
                    ? _businessAssociationController.text
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                items: [
                  for (final businessName in widget.businessNames)
                    DropdownMenuItem(
                      value: businessName,
                      child: Text(businessName),
                    ),
                ],
                onChanged: (businessName) {
                  _businessAssociationController.text = businessName ?? '';
                },
              ),
            ),
            SizedBox(
              width: 220,
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Remote Work'),
                value: _remoteWork,
                onChanged: (checked) => setState(() {
                  _remoteWork = checked ?? false;
                }),
              ),
            ),
            if (!_remoteWork)
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<String>(
                  initialValue:
                      widget.businessLocations.contains(
                        _personLocationController.text,
                      )
                      ? _personLocationController.text
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Location Name',
                    border: OutlineInputBorder(),
                  ),
                  isExpanded: true,
                  items: [
                    for (final locationName in widget.businessLocations)
                      DropdownMenuItem(
                        value: locationName,
                        child: Text(locationName),
                      ),
                  ],
                  onChanged: (locationName) {
                    _personLocationController.text = locationName ?? '';
                  },
                ),
              ),
          ],
        ),
      ),
    ],
  );

  /// Business classification, main contact, and location editor.
  Widget _businessFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FormSection(
        title: 'Business details',
        icon: Icons.business_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Business Type'),
            RadioGroup<String>(
              groupValue: _businessType,
              onChanged: (value) => setState(() => _businessType = value),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final businessType in _businessTypes)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<String>(value: businessType),
                        Text(businessType),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _field(
                  controller: _nameController,
                  label: 'Business name',
                  validator: (value) => _required(value, 'a business name'),
                ),
                _field(
                  controller: _addressController,
                  label: 'Business Address',
                  width: 300,
                  validator: (value) => _required(value, 'a business address'),
                ),
                _field(
                  controller: _phoneController,
                  label: 'Business Direct Phone',
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      _required(value, 'a direct phone number'),
                ),
                _airportAutocomplete(
                  controller: _nearestAirportController,
                  label: 'Nearest Airport',
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FormSection(
        title: 'Business locations',
        icon: Icons.place_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < 4; index++) ...[
              const SizedBox(height: 12),
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Location ${index + 1}'),
                      trailing: Icon(
                        _locationExpanded[index]
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                      onTap: () => setState(() {
                        _locationExpanded[index] = !_locationExpanded[index];
                      }),
                    ),
                    if (_locationExpanded[index])
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _field(
                              controller: _locationNameControllers[index],
                              label: 'Location ${index + 1} Name',
                            ),
                            _field(
                              controller: _locationAddressControllers[index],
                              label: 'Location ${index + 1} Address',
                              width: 300,
                            ),
                            _field(
                              controller: _locationPhoneControllers[index],
                              label: 'Location ${index + 1} Direct Phone',
                              keyboardType: TextInputType.phone,
                            ),
                            _airportAutocomplete(
                              controller: _locationAirportControllers[index],
                              label: 'Location ${index + 1} Nearest Airport',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isPeople ? 'Add person' : 'Add business',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: _isPeople ? _peopleFields() : _businessFields(),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: Icon(widget.initialEntry == null ? Icons.add : Icons.save),
              label: Text(
                widget.initialEntry == null
                    ? (_isPeople ? 'Add Person' : 'Add Business')
                    : (_isPeople ? 'Update Person' : 'Update Business'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
