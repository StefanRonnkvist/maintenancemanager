import 'package:flutter/material.dart';

import '../models/business_entry.dart';
import '../tabs/business_tab.dart';
import 'form_section.dart';

/// Collects either a person/contact or business, depending on [kind].
class BusinessForm extends StatefulWidget {
  const BusinessForm({required this.kind, required this.onSubmit, super.key});

  final BusinessTabKind kind;
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
  final _nearestAirportController = TextEditingController();
  final _locationAirportController = TextEditingController();
  final _businessAssociationController = TextEditingController();
  final _personLocationController = TextEditingController();
  final List<BusinessLocation> _locations = [];
  String? _businessType;
  bool _remoteWork = false;

  // Both form variants reuse these controllers; kind determines which fields show.
  bool get _isPeople => widget.kind == BusinessTabKind.people;

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
    _nearestAirportController.dispose();
    _locationAirportController.dispose();
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

  /// Adds a business location only after its required details are present.
  void _addLocation() {
    final name = _locationNameController.text.trim();
    final address = _locationAddressController.text.trim();
    final phone = _locationPhoneController.text.trim();
    if (name.isEmpty || address.isEmpty || phone.isEmpty) return;

    final location = BusinessLocation(
      name: name,
      address: address,
      directPhone: phone,
      nearestAirport: _locationAirportController.text.trim(),
    );
    setState(() {
      _locations.add(location);
      _locationAirportController.clear();
    });
    _locationNameController.clear();
    _locationAddressController.clear();
    _locationPhoneController.clear();
  }

  /// Validates fields, emits the model, then resets the form for another entry.
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
        businessName: _isPeople
            ? _businessAssociationController.text.trim()
            : '',
        locationName: _isPeople
            ? (_remoteWork
                  ? 'Remote Work'
                  : _personLocationController.text.trim())
            : '',
        nearestAirport: _nearestAirportController.text.trim(),
        locations: List.unmodifiable(_locations),
        airports: _isPeople || _nearestAirportController.text.trim().isEmpty
            ? const []
            : [_nearestAirportController.text.trim()],
      ),
    );
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _cellPhoneController.clear();
    _emailController.clear();
    _nearestAirportController.clear();
    _businessAssociationController.clear();
    _personLocationController.clear();
    setState(() {
      _businessType = null;
      _remoteWork = false;
      _locations.clear();
    });
  }

  /// Person-specific details, work association, and contact information.
  Widget _peopleFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FormSection(
        title: 'Personal details',
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
            _field(
              controller: _businessAssociationController,
              label: 'Business Name',
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
              _field(
                controller: _personLocationController,
                label: 'Location Name',
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      FormSection(
        title: 'Contact details',
        icon: Icons.contact_phone_outlined,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _field(
              controller: _addressController,
              label: 'Address',
              width: 300,
              validator: (value) => _required(value, 'an address'),
            ),
            _field(
              controller: _phoneController,
              label: 'Direct phone',
              keyboardType: TextInputType.phone,
              validator: (value) => _required(value, 'a direct phone number'),
            ),
            _field(
              controller: _nearestAirportController,
              label: 'Nearest Airport',
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
            RadioGroup<String>(
              groupValue: _businessType,
              onChanged: (value) => setState(() => _businessType = value),
              child: const Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(value: 'Customer'),
                      Text('Customer'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(value: 'Vendor'),
                      Text('Vendor'),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(value: 'Principle'),
                      Text('Principle'),
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
                _field(
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
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _field(
                  controller: _locationNameController,
                  label: 'Location Name',
                ),
                _field(
                  controller: _locationAddressController,
                  label: 'Location Address',
                  width: 300,
                ),
                _field(
                  controller: _locationPhoneController,
                  label: 'Location Direct Phone',
                  keyboardType: TextInputType.phone,
                ),
                _field(
                  controller: _locationAirportController,
                  label: 'Nearest Airport',
                ),
                FilledButton.icon(
                  onPressed: _addLocation,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add Location'),
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
              icon: const Icon(Icons.add),
              label: Text(_isPeople ? 'Add Person' : 'Add Business'),
            ),
          ),
        ],
      ),
    ),
  );
}
