import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import '../models/ui_text_catalog.dart';
import '../tabs/business_tab.dart';
import 'form_section.dart';

class BusinessForm extends StatefulWidget {
  const BusinessForm({
    required this.kind,
    required this.businesses,
    required this.text,
    required this.onSubmit,
    super.key,
  });

  final BusinessTabKind kind;
  final List<BusinessEntry> businesses;
  final UiTextCatalog text;
  final ValueChanged<BusinessEntry> onSubmit;

  @override
  State<BusinessForm> createState() => _BusinessFormState();
}

class _BusinessFormState extends State<BusinessForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneExtensionController = TextEditingController();
  final _cellPhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _locationAddressController = TextEditingController();
  final _locationPhoneController = TextEditingController();
  final _airportController = TextEditingController();
  final List<String> _airports = [];
  final List<BusinessLocation> _locations = [];
  String? _selectedBusinessName;
  String? _selectedLocationName;
  String? _selectedAirport;
  String? _businessType;
  bool _remoteWork = false;
  bool _businessFormExpanded = false;
  bool _peopleFormExpanded = false;

  bool get _isPeople => widget.kind == BusinessTabKind.people;
  String get _tabKey => _isPeople ? 'people' : 'business';

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _phoneExtensionController.dispose();
    _cellPhoneController.dispose();
    _emailController.dispose();
    _locationNameController.dispose();
    _locationAddressController.dispose();
    _locationPhoneController.dispose();
    _airportController.dispose();
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

  Widget _airportControls() => Wrap(
    spacing: 12,
    runSpacing: 12,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      SizedBox(
        width: 260,
        child: DropdownButtonFormField<String>(
          initialValue: _airports.contains(_selectedAirport)
              ? _selectedAirport
              : null,
          decoration: InputDecoration(
            labelText: widget.text.fieldLabel(_tabKey, 'nearestAirport'),
            border: OutlineInputBorder(),
          ),
          items: _airports
              .map(
                (airport) =>
                    DropdownMenuItem(value: airport, child: Text(airport)),
              )
              .toList(),
          onChanged: (airport) => setState(() => _selectedAirport = airport),
        ),
      ),
      SizedBox(
        width: 220,
        child: TextField(
          controller: _airportController,
          decoration: InputDecoration(
            labelText: widget.text.fieldLabel(_tabKey, 'addAirport'),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _addAirport(),
        ),
      ),
      OutlinedButton.icon(
        onPressed: _addAirport,
        icon: const Icon(Icons.add),
        label: const Text('Add Airport'),
      ),
    ],
  );

  void _addAirport() {
    final airport = _airportController.text.trim();
    if (airport.isEmpty || _airports.contains(airport)) return;
    setState(() {
      _airports.add(airport);
      _selectedAirport = airport;
    });
    _airportController.clear();
  }

  void _addLocation() {
    final name = _locationNameController.text.trim();
    final address = _locationAddressController.text.trim();
    final phone = _locationPhoneController.text.trim();
    if (name.isEmpty || address.isEmpty || phone.isEmpty) return;

    final location = BusinessLocation(
      name: name,
      address: address,
      directPhone: phone,
      nearestAirport: _selectedAirport ?? '',
    );
    setState(() {
      _locations.add(location);
      _selectedAirport = null;
    });
    _locationNameController.clear();
    _locationAddressController.clear();
    _locationPhoneController.clear();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onSubmit(
      BusinessEntry(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        directPhone: _phoneController.text.trim(),
        directPhoneExtension: _phoneExtensionController.text.trim(),
        businessType: _isPeople ? '' : (_businessType ?? ''),
        cellPhone: _cellPhoneController.text.trim(),
        email: _emailController.text.trim(),
        businessName: _selectedBusinessName ?? '',
        locationName: _remoteWork
            ? 'Remote Work'
            : (_selectedLocationName ?? ''),
        nearestAirport: _selectedAirport ?? '',
        locations: List.unmodifiable(_locations),
        airports: List.unmodifiable(_airports),
      ),
    );
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _cellPhoneController.clear();
    _emailController.clear();
    setState(() {
      _selectedBusinessName = null;
      _selectedLocationName = null;
      _selectedAirport = null;
      _businessType = null;
      _remoteWork = false;
      _locations.clear();
    });
  }

  Widget _peopleFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FormSection(
        title: widget.text.section(_tabKey, 'personalDetails'),
        icon: Icons.person_outline,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _field(
              controller: _nameController,
              label: widget.text.fieldLabel(_tabKey, 'name'),
              validator: (value) => _required(value, 'a name'),
            ),
            _field(
              controller: _phoneController,
              label: widget.text.fieldLabel(_tabKey, 'contactPhone'),
              keyboardType: TextInputType.phone,
            ),
            _field(
              controller: _phoneExtensionController,
              label: widget.text.fieldLabel(_tabKey, 'extension'),
              keyboardType: TextInputType.number,
            ),
            _field(
              controller: _cellPhoneController,
              label: widget.text.fieldLabel(_tabKey, 'cellPhone'),
              keyboardType: TextInputType.phone,
            ),
            _field(
              controller: _emailController,
              label: widget.text.fieldLabel(_tabKey, 'email'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FormSection(
        title: widget.text.section(_tabKey, 'workLocation'),
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
                    widget.businesses.any(
                      (business) => business.name == _selectedBusinessName,
                    )
                    ? _selectedBusinessName
                    : null,
                decoration: InputDecoration(
                  labelText: widget.text.fieldLabel(_tabKey, 'businessName'),
                  border: OutlineInputBorder(),
                ),
                items: widget.businesses
                    .map(
                      (business) => DropdownMenuItem(
                        value: business.name,
                        child: Text(business.name),
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
              width: 220,
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(widget.text.fieldLabel(_tabKey, 'remoteWork')),
                value: _remoteWork,
                onChanged: (checked) => setState(() {
                  _remoteWork = checked ?? false;
                  if (_remoteWork) _selectedLocationName = null;
                }),
              ),
            ),
            if (!_remoteWork)
              SizedBox(
                width: 260,
                child: DropdownButtonFormField<String>(
                  initialValue:
                      widget.businesses
                          .where(
                            (business) =>
                                business.name == _selectedBusinessName,
                          )
                          .expand((business) => business.locations)
                          .any(
                            (location) =>
                                location.name == _selectedLocationName,
                          )
                      ? _selectedLocationName
                      : null,
                  decoration: InputDecoration(
                    labelText: widget.text.fieldLabel(_tabKey, 'locationName'),
                    border: OutlineInputBorder(),
                  ),
                  items: widget.businesses
                      .where(
                        (business) => business.name == _selectedBusinessName,
                      )
                      .expand((business) => business.locations)
                      .map(
                        (location) => DropdownMenuItem(
                          value: location.name,
                          child: Text(location.name),
                        ),
                      )
                      .toList(),
                  onChanged: _selectedBusinessName == null
                      ? null
                      : (name) => setState(() => _selectedLocationName = name),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FormSection(
        title: widget.text.section(_tabKey, 'contactDetails'),
        icon: Icons.contact_phone_outlined,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _field(
              controller: _addressController,
              label: widget.text.fieldLabel(_tabKey, 'contactAddress'),
              width: 300,
              validator: (value) => _required(value, 'an address'),
            ),
            _field(
              controller: _phoneController,
              label: widget.text.fieldLabel(_tabKey, 'contactPhone'),
              keyboardType: TextInputType.phone,
              validator: (value) => _required(value, 'a direct phone number'),
            ),
            _airportControls(),
          ],
        ),
      ),
    ],
  );

  Widget _businessFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FormSection(
        title: widget.text.section(_tabKey, 'details'),
        icon: Icons.business_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioGroup<String>(
              groupValue: _businessType,
              onChanged: (value) => setState(() => _businessType = value),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(value: 'Customer'),
                      Text(
                        widget.text.option(
                          'business',
                          'businessType',
                          'Customer',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(value: 'Vendor'),
                      Text(
                        widget.text.option(
                          'business',
                          'businessType',
                          'Vendor',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(value: 'Principle'),
                      Text(
                        widget.text.option(
                          'business',
                          'businessType',
                          'Principle',
                        ),
                      ),
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
                  label: widget.text.fieldLabel(_tabKey, 'businessName'),
                  validator: (value) => _required(value, 'a business name'),
                ),
                _field(
                  controller: _addressController,
                  label: widget.text.fieldLabel(_tabKey, 'businessAddress'),
                  width: 300,
                  validator: (value) => _required(value, 'a business address'),
                ),
                _field(
                  controller: _phoneController,
                  label: widget.text.fieldLabel(_tabKey, 'businessDirectPhone'),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      _required(value, 'a direct phone number'),
                ),
                _airportControls(),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FormSection(
        title: widget.text.section(_tabKey, 'locations'),
        icon: Icons.place_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _field(
                  controller: _locationNameController,
                  label: widget.text.fieldLabel(_tabKey, 'locationName'),
                ),
                _field(
                  controller: _locationAddressController,
                  label: widget.text.fieldLabel(_tabKey, 'locationAddress'),
                  width: 300,
                ),
                _field(
                  controller: _locationPhoneController,
                  label: widget.text.fieldLabel(_tabKey, 'locationDirectPhone'),
                  keyboardType: TextInputType.phone,
                ),
                _airportControls(),
                FilledButton.icon(
                  onPressed: _addLocation,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: Text(widget.text.action(_tabKey, 'addLocation')),
                ),
              ],
            ),
            if (_locations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _locations
                    .map(
                      (location) => Chip(
                        avatar: const Icon(Icons.place_outlined, size: 18),
                        label: Text(location.name),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        ListTile(
          title: Text(
            widget.text('formTitle', tab: _tabKey),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          trailing: Icon(
            (_isPeople ? _peopleFormExpanded : _businessFormExpanded)
                ? Icons.expand_less
                : Icons.expand_more,
          ),
          onTap: () => setState(() {
            if (_isPeople) {
              _peopleFormExpanded = !_peopleFormExpanded;
            } else {
              _businessFormExpanded = !_businessFormExpanded;
            }
          }),
        ),
        if (_isPeople ? _peopleFormExpanded : _businessFormExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: _isPeople ? _peopleFields() : _businessFields(),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.add),
                    label: Text(widget.text.action(_tabKey, 'add')),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
