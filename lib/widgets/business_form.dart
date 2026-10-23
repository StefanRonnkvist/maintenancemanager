import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/business_entry.dart';
import '../services/csv_utils.dart';
import '../services/local_record_store.dart';
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
  static const _customAirportsStorageKey = 'custom_airports_v1';
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

  Widget _airportDropdown({
    required TextEditingController controller,
    required String label,
  }) {
    final options = [
      ..._airportOptions,
      if (controller.text.isNotEmpty &&
          !_airportOptions.contains(controller.text))
        controller.text,
    ];
    return SizedBox(
      width: _airportFieldWidth(controller) + 140,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              key: ValueKey(
                '$label-${controller.text}-${_airportOptions.length}',
              ),
              initialValue: options.contains(controller.text)
                  ? controller.text
                  : null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              selectedItemBuilder: (context) => [
                for (final airport in options)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(_airportCode(airport)),
                  ),
              ],
              items: [
                for (final airport in options)
                  DropdownMenuItem(value: airport, child: Text(airport)),
              ],
              onChanged: (airport) {
                controller.text = airport ?? '';
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => _addAirport(controller),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Add Airport'),
          ),
        ],
      ),
    );
  }

  String _airportCode(String airport) {
    final match = RegExp(r'\(([^()]*)\)\s*$').firstMatch(airport);
    return match?.group(1) ?? airport;
  }

  Future<void> _addAirport(TextEditingController targetController) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final airport = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Airport'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                autofocus: true,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter an airport name'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Airport Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter an airport code'
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Airport Code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              final name = nameController.text.trim();
              final code = codeController.text.trim().toUpperCase();
              Navigator.of(dialogContext).pop('$name ($code)');
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    nameController.dispose();
    codeController.dispose();
    if (airport == null || !mounted) return;

    final exists = _airportOptions.any(
      (option) => option.toLowerCase() == airport.toLowerCase(),
    );
    if (exists) {
      final existingAirport = _airportOptions.firstWhere(
        (option) => option.toLowerCase() == airport.toLowerCase(),
      );
      setState(() => targetController.text = existingAirport);
      return;
    }

    final updatedOptions = [..._airportOptions, airport]..sort();
    try {
      final customAirports = await LocalRecordStore.read(
        _customAirportsStorageKey,
      );
      final records = <Map<String, Object?>>[
        for (final record in customAirports)
          if (record['airport']?.toString().toLowerCase() !=
              airport.toLowerCase())
            record,
        {'airport': airport},
      ];
      await LocalRecordStore.write(_customAirportsStorageKey, records);
      if (!mounted) return;
      setState(() {
        _airportOptions = updatedOptions;
        targetController.text = airport;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save airport: $error')),
        );
      }
    }
  }

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
    try {
      final csv = await rootBundle.loadString('assets/airports.csv');
      final rows = CsvUtils.parse(csv);
      final airports = rows
          .skip(1)
          .where((row) => row.length >= 3)
          .map((row) {
            final name = row[0].trim();
            final code = row[2].trim();
            return name.isEmpty || code.isEmpty ? null : '$name ($code)';
          })
          .whereType<String>()
          .toSet();
      final customAirports = await LocalRecordStore.read(
        _customAirportsStorageKey,
      );
      airports.addAll(
        customAirports
            .map((record) => record['airport']?.toString() ?? '')
            .where((airport) => airport.isNotEmpty),
      );
      final options = airports.toList()..sort();
      if (mounted) setState(() => _airportOptions = options);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load airports: $error')),
        );
      }
    }
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
    if (!_isPeople && _businessType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a business type.')),
      );
      return;
    }
    widget.onSubmit(
      BusinessEntry(
        name: _nameController.text.trim(),
        title: _isPeople ? _titleController.text.trim() : '',
        address: _addressController.text.trim(),
        directPhone: _phoneController.text.trim(),
        directPhoneExtension: _phoneExtensionController.text.trim(),
        businessType: _isPeople ? '' : _businessType!,
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
            _airportDropdown(
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
                _airportDropdown(
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
                            _airportDropdown(
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
