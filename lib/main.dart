import 'package:flutter/material.dart';

import 'contact/contact_page.dart';
import 'contact/submissions_csv_page.dart';
import 'db/application_db_page.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Maintenance Manager',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    ),
    home: const TabBarViewPage(),
  );
}

class TabBarViewPage extends StatefulWidget {
  const TabBarViewPage({super.key});

  @override
  State<TabBarViewPage> createState() => _TabBarViewPageState();
}

class _TabBarViewPageState extends State<TabBarViewPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<_BusinessEntry> _peopleEntries = [];
  final List<_BusinessEntry> _businessEntries = [];
  final List<_TabItem> _tabs = const [
    _TabItem(label: 'Machine', icon: Icons.precision_manufacturing_outlined),
    _TabItem(label: 'People', icon: Icons.people_outline),
    _TabItem(label: 'Business', icon: Icons.business_outlined),
    _TabItem(label: 'Information', icon: Icons.contact_support_outlined),
    _TabItem(label: 'Application DB', icon: Icons.storage_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Maintenance Manager'),
      bottom: TabBar(
        controller: _tabController,
        tabs: _tabs
            .map((tab) => Tab(icon: Icon(tab.icon), text: tab.label))
            .toList(),
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _tabs[0].icon,
                size: 56,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                _tabs[0].label,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        _BusinessTab(
          entries: _peopleEntries,
          onAdd: (entry) => setState(() => _peopleEntries.add(entry)),
          isPeopleTab: true,
          businesses: _businessEntries,
        ),
        _BusinessTab(
          entries: _businessEntries,
          onAdd: (entry) => setState(() => _businessEntries.add(entry)),
          isPeopleTab: false,
        ),
        const _InformationTabs(),
        const ApplicationDbPage(),
      ],
    ),
  );
}

class _InformationTabs extends StatelessWidget {
  const _InformationTabs();

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        const Material(
          color: Colors.transparent,
          child: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.contact_support_outlined), text: 'Contact'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Submissions'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            children: [
              ContactPage(
                serverUri: Uri.https('stefanronnkvist.com', '/contact'),
                showAppBar: false,
                wrapInScaffold: false,
              ),
              SubmissionsCsvCardsView(),
            ],
          ),
        ),
      ],
    ),
  );
}

class _TabItem {
  const _TabItem({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class _BusinessLocation {
  const _BusinessLocation({
    required this.name,
    required this.address,
    required this.directPhone,
    this.nearestAirport = '',
  });
  final String name;
  final String address;
  final String directPhone;
  final String nearestAirport;
}

class _BusinessEntry {
  const _BusinessEntry({
    required this.name,
    required this.address,
    required this.directPhone,
    this.cellPhone = '',
    this.email = '',
    this.businessName = '',
    this.locationName = '',
    this.nearestAirport = '',
    this.locations = const [],
    this.airports = const [],
  });
  final String name;
  final String address;
  final String directPhone;
  final String cellPhone;
  final String email;
  final String businessName;
  final String locationName;
  final String nearestAirport;
  final List<_BusinessLocation> locations;
  final List<String> airports;
}

class _BusinessTab extends StatefulWidget {
  const _BusinessTab({
    required this.entries,
    required this.onAdd,
    required this.isPeopleTab,
    this.businesses = const [],
  });
  final List<_BusinessEntry> entries;
  final ValueChanged<_BusinessEntry> onAdd;
  final bool isPeopleTab;
  final List<_BusinessEntry> businesses;

  @override
  State<_BusinessTab> createState() => _BusinessTabState();
}

class _BusinessTabState extends State<_BusinessTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cellPhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _locationAddressController = TextEditingController();
  final _locationPhoneController = TextEditingController();
  final _airportController = TextEditingController();
  final List<String> _airports = [];
  final List<_BusinessLocation> _locations = [];

  String? _selectedBusinessName;
  String? _selectedLocationName;
  String? _selectedAirport;
  bool _remoteWork = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _cellPhoneController.dispose();
    _emailController.dispose();
    _locationNameController.dispose();
    _locationAddressController.dispose();
    _locationPhoneController.dispose();
    _airportController.dispose();
    super.dispose();
  }

  void _addEntry() {
    if (!_formKey.currentState!.validate()) return;
    widget.onAdd(
      _BusinessEntry(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        directPhone: _phoneController.text.trim(),
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
    _selectedBusinessName = null;
    _selectedLocationName = null;
    _selectedAirport = null;
    _remoteWork = false;
    _locations.clear();
    setState(() {});
  }

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
    setState(() {
      _locations.add(
        _BusinessLocation(
          name: name,
          address: address,
          directPhone: phone,
          nearestAirport: _selectedAirport ?? '',
        ),
      );
    });
    _locationNameController.clear();
    _locationAddressController.clear();
    _locationPhoneController.clear();
  }

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
          decoration: const InputDecoration(
            labelText: 'Nearest Airport',
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
          decoration: const InputDecoration(
            labelText: 'Add airport',
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

  Widget _peopleForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _FormSection(
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
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter a name' : null,
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
      _FormSection(
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
                    widget.businesses.any(
                      (b) => b.name == _selectedBusinessName,
                    )
                    ? _selectedBusinessName
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Business Name',
                  border: OutlineInputBorder(),
                ),
                items: widget.businesses
                    .map(
                      (b) =>
                          DropdownMenuItem(value: b.name, child: Text(b.name)),
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
                title: const Text('Remote Work'),
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
                          .where((b) => b.name == _selectedBusinessName)
                          .expand((b) => b.locations)
                          .any((l) => l.name == _selectedLocationName)
                      ? _selectedLocationName
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Location Name',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.businesses
                      .where((b) => b.name == _selectedBusinessName)
                      .expand((b) => b.locations)
                      .map(
                        (l) => DropdownMenuItem(
                          value: l.name,
                          child: Text(l.name),
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
      _FormSection(
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
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter an address'
                  : null,
            ),
            _field(
              controller: _phoneController,
              label: 'Direct phone',
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a direct phone number'
                  : null,
            ),
            _airportControls(),
          ],
        ),
      ),
    ],
  );

  Widget _businessForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _FormSection(
        title: 'Business details',
        icon: Icons.business_outlined,
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _field(
              controller: _nameController,
              label: 'Business name',
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a business name'
                  : null,
            ),
            _field(
              controller: _addressController,
              label: 'Business Address',
              width: 300,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a business address'
                  : null,
            ),
            _field(
              controller: _phoneController,
              label: 'Business Direct Phone',
              keyboardType: TextInputType.phone,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a direct phone number'
                  : null,
            ),
            _airportControls(),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _FormSection(
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
                _airportControls(),
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isPeopleTab ? 'Add person' : 'Add business',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Form(
                          key: _formKey,
                          child: widget.isPeopleTab
                              ? _peopleForm()
                              : _businessForm(),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _addEntry,
                            icon: const Icon(Icons.add),
                            label: Text(
                              widget.isPeopleTab
                                  ? 'Add Person'
                                  : 'Add Business',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.isPeopleTab ? 'People' : 'Businesses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Center(
                  child: widget.isPeopleTab
                      ? _PeopleList(entries: widget.entries)
                      : _BusinessList(entries: widget.entries),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PeopleList extends StatelessWidget {
  const _PeopleList({required this.entries});
  final List<_BusinessEntry> entries;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      headingRowColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      dataRowMinHeight: 52,
      columns: const [
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Business Name')),
        DataColumn(label: Text('Location Name')),
        DataColumn(label: Text('Nearest Airport')),
        DataColumn(label: Text('Address')),
        DataColumn(label: Text('Direct Phone')),
        DataColumn(label: Text('Cell Phone')),
        DataColumn(label: Text('eMail')),
      ],
      rows: entries
          .map(
            (entry) => DataRow(
              cells: [
                DataCell(Text(entry.name)),
                DataCell(Text(entry.businessName)),
                DataCell(Text(entry.locationName)),
                DataCell(Text(entry.nearestAirport)),
                DataCell(Text(entry.address)),
                DataCell(Text(entry.directPhone)),
                DataCell(Text(entry.cellPhone)),
                DataCell(Text(entry.email)),
              ],
            ),
          )
          .toList(),
    ),
  );
}

class _BusinessList extends StatelessWidget {
  const _BusinessList({required this.entries});
  final List<_BusinessEntry> entries;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      headingRowColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      dataRowMinHeight: 52,
      columns: const [
        DataColumn(label: Text('Business Name')),
        DataColumn(label: Text('Business Address')),
        DataColumn(label: Text('Business Direct Phone')),
        DataColumn(label: Text('Nearest Airport')),
        DataColumn(label: Text('Location Name')),
        DataColumn(label: Text('Location Address')),
        DataColumn(label: Text('Location Direct Phone')),
        DataColumn(label: Text('Location Nearest Airport')),
      ],
      rows: [
        for (final business in entries)
          if (business.locations.isEmpty)
            DataRow(
              cells: [
                DataCell(Text(business.name)),
                DataCell(Text(business.address)),
                DataCell(Text(business.directPhone)),
                DataCell(Text(business.nearestAirport)),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
                const DataCell(Text('')),
              ],
            )
          else
            for (var index = 0; index < business.locations.length; index++)
              DataRow(
                cells: [
                  DataCell(Text(index == 0 ? business.name : '')),
                  DataCell(Text(index == 0 ? business.address : '')),
                  DataCell(Text(index == 0 ? business.directPhone : '')),
                  DataCell(Text(index == 0 ? business.nearestAirport : '')),
                  DataCell(Text(business.locations[index].name)),
                  DataCell(Text(business.locations[index].address)),
                  DataCell(Text(business.locations[index].directPhone)),
                  DataCell(Text(business.locations[index].nearestAirport)),
                ],
              ),
      ],
    ),
  );
}
