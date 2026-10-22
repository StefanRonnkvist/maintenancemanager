import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_tab.dart';
import '../models/business_entry.dart';
import '../widgets/management_tab_layout.dart';
import '../widgets/sortable_data_table.dart';

/// Builds a message composer with business-based recipient selection.
class MessageTab extends StatefulWidget {
  const MessageTab({
    required this.people,
    required this.businesses,
    this.prefillRequest,
    this.onPrefillHandled,
    super.key,
  });

  final List<BusinessEntry> people;
  final List<BusinessEntry> businesses;
  final MessagePrefillRequest? prefillRequest;
  final VoidCallback? onPrefillHandled;

  @override
  State<MessageTab> createState() => _MessageTabState();
}

class MessagePrefillRequest {
  const MessagePrefillRequest({
    required this.business,
    required this.location,
    required this.person,
    required this.subject,
    required this.message,
  });

  final String business;
  final String location;
  final BusinessEntry person;
  final String subject;
  final String message;
}

class _MessageTabState extends State<MessageTab> {
  final _toController = TextEditingController();
  final _ccController = TextEditingController();
  String? _selectedBusiness;
  String? _selectedLocation;
  final Set<String> _selectedTo = {};
  final Set<String> _selectedCc = {};

  List<String> get _businessOptions =>
      widget.businesses
          .map((business) => business.name.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

  List<String> get _locationOptions {
    final business = widget.businesses
        .where((entry) => entry.name.trim() == _selectedBusiness)
        .firstOrNull;
    if (business == null) return const [];
    return business.locations
        .map((location) => location.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<BusinessEntry> get _toPeopleOptions =>
      widget.people
          .where(
            (person) =>
                person.businessName.trim() == _selectedBusiness &&
                (_selectedLocation == null ||
                    person.locationName.trim() == _selectedLocation) &&
                person.name.trim().isNotEmpty &&
                person.email.trim().isNotEmpty,
          )
          .toList()
        ..sort((first, second) => first.name.compareTo(second.name));

  List<BusinessEntry> get _ccPeopleOptions {
    final selectedBusiness = _selectedBusiness;
    if (selectedBusiness == null) return const [];
    final principleBusinessNames = widget.businesses
        .where((business) => business.businessType.trim() == 'Principle')
        .map((business) => business.name.trim())
        .toSet();
    return widget.people
        .where(
          (person) =>
              person.name.trim().isNotEmpty &&
              person.email.trim().isNotEmpty &&
              !_selectedTo.contains(person.email) &&
              ((person.businessName.trim() == selectedBusiness &&
                      (_selectedLocation == null ||
                          person.locationName.trim() == _selectedLocation)) ||
                  principleBusinessNames.contains(person.businessName.trim())),
        )
        .toList()
      ..sort((first, second) => first.name.compareTo(second.name));
  }

  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final List<_MessageRow> _messageRows = [];
  Object? _lastHandledPrefill;
  String? _prefilledToName;

  @override
  void didUpdateWidget(covariant MessageTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    final request = widget.prefillRequest;
    if (request != null && !identical(request, _lastHandledPrefill)) {
      _lastHandledPrefill = request;
      _applyPrefill(request);
    }
  }

  @override
  void initState() {
    super.initState();
    final request = widget.prefillRequest;
    if (request != null) {
      _lastHandledPrefill = request;
      _applyPrefill(request);
    }
  }

  void _applyPrefill(MessagePrefillRequest request) {
    final matchingBusiness = widget.businesses
        .where((business) => business.name.trim() == request.business.trim())
        .firstOrNull;
    final businessName = matchingBusiness?.name.trim() ?? request.business.trim();
    final locationName = matchingBusiness?.locations
            .where((location) => location.name.trim() == request.location.trim())
            .firstOrNull
            ?.name
            .trim() ??
        request.location.trim();
    final recipient = widget.people
        .where((person) => identical(person, request.person))
        .firstOrNull;
    final personName = recipient?.name.trim() ?? request.person.name.trim();
    final email = recipient?.email.trim() ?? request.person.email.trim();

    setState(() {
      _selectedBusiness = _businessOptions.contains(businessName)
          ? businessName
          : null;
      _selectedLocation = _locationOptions.contains(locationName)
          ? locationName
          : null;
      _selectedTo
        ..clear()
        ..add(email);
      _prefilledToName = personName;
      _selectedCc.clear();
      _syncRecipientControllers();
      _subjectController.text = request.subject;
      _messageController.text = request.message;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onPrefillHandled?.call();
    });
  }

  void _syncRecipientControllers() {
    _toController.text = _selectedTo.join('; ');
    _ccController.text = _selectedCc.join('; ');
  }

  Future<void> _deleteMessageRow(_MessageRow row) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text('Delete this message row?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && mounted) {
      setState(() => _messageRows.remove(row));
    }
  }

  /// Records the composed message locally in this tab and opens a mailto target.
  Future<void> _sendMessage() async {
    final to = _selectedTo.join(',');
    final cc = _selectedCc.join(',');
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (to.isEmpty && cc.isEmpty && subject.isEmpty && message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add message details before sending.')),
      );
      return;
    }

    final mailtoUri = Uri(
      scheme: 'mailto',
      path: to,
      query: [
        if (cc.isNotEmpty) 'cc=${Uri.encodeComponent(cc)}',
        if (subject.isNotEmpty) 'subject=${Uri.encodeComponent(subject)}',
        if (message.isNotEmpty) 'body=${Uri.encodeComponent(message)}',
      ].join('&'),
    );

    setState(() {
      _messageRows.add(
        _MessageRow(
          business: _selectedBusiness ?? '',
          location: _selectedLocation ?? '',
          to: to,
          cc: cc,
          subject: subject,
          message: message,
        ),
      );
    });

    try {
      final launched = await launchUrl(
        mailtoUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No email client is available.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the email app: $error')),
        );
      }
    }
  }

  @override
  void dispose() {
    _toController.dispose();
    _ccController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Widget _emailFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Compose email message',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 16),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recipients', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 320,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('business-$_selectedBusiness'),
                    initialValue: _selectedBusiness,
                    onChanged: (business) => setState(() {
                      _selectedBusiness = business;
                      _selectedLocation = null;
                      _selectedTo.clear();
                      _selectedCc.clear();
                      _syncRecipientControllers();
                    }),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Business',
                      border: OutlineInputBorder(),
                    ),
                    items: _businessOptions
                        .map(
                          (business) => DropdownMenuItem(
                            value: business,
                            child: Text(business),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(
                      'location-$_selectedBusiness-$_selectedLocation',
                    ),
                    initialValue: _selectedLocation,
                    onChanged: _selectedBusiness == null
                        ? null
                        : (location) => setState(() {
                            _selectedLocation = location;
                            _selectedTo.clear();
                            _selectedCc.clear();
                            _syncRecipientControllers();
                          }),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    items: _locationOptions
                        .map(
                          (location) => DropdownMenuItem(
                            value: location,
                            child: Text(location),
                          ),
                        )
                        .toList(),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: DropdownButtonHideUnderline(
                    child: PopupMenuButton<String>(
                      enabled: _selectedBusiness != null,
                      tooltip: 'Select To recipients',
                      onSelected: (email) => setState(() {
                        if (email == '__select_all__') {
                          _selectedTo
                            ..clear()
                            ..addAll(
                              _toPeopleOptions.map((person) => person.email),
                            );
                        } else if (email == '__clear__') {
                          _selectedTo.clear();
                          _prefilledToName = null;
                        } else if (!_selectedTo.add(email)) {
                          _selectedTo.remove(email);
                          _prefilledToName = null;
                        } else {
                          _prefilledToName = null;
                        }
                        _syncRecipientControllers();
                      }),
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: '__select_all__',
                          child: Text('Select All'),
                        ),
                        PopupMenuItem<String>(
                          value: '__clear__',
                          child: Text('Clear'),
                        ),
                        for (final person in _toPeopleOptions)
                          CheckedPopupMenuItem<String>(
                            value: person.email,
                            checked: _selectedTo.contains(person.email),
                            child: Text(person.name),
                          ),
                      ],
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'To',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          _selectedTo.isEmpty
                              ? 'Select recipients'
                              : _selectedTo.length == 1 && _prefilledToName != null
                              ? _prefilledToName!
                              : _selectedTo
                                    .map((email) => widget.people
                                        .where((person) => person.email.trim() == email)
                                        .firstOrNull?.name ?? email)
                                    .join(', '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: DropdownButtonHideUnderline(
                    child: PopupMenuButton<String>(
                      enabled: _selectedBusiness != null,
                      tooltip: 'Select Cc recipients',
                      onSelected: (email) => setState(() {
                        if (email == '__select_all__') {
                          _selectedCc
                            ..clear()
                            ..addAll(
                              _ccPeopleOptions.map((person) => person.email),
                            );
                        } else if (email == '__clear__') {
                          _selectedCc.clear();
                        } else if (!_selectedCc.add(email)) {
                          _selectedCc.remove(email);
                        }
                        _syncRecipientControllers();
                      }),
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: '__select_all__',
                          child: Text('Select All'),
                        ),
                        PopupMenuItem<String>(
                          value: '__clear__',
                          child: Text('Clear'),
                        ),
                        for (final person in _ccPeopleOptions)
                          CheckedPopupMenuItem<String>(
                            value: person.email,
                            checked: _selectedCc.contains(person.email),
                            child: Text(person.name),
                          ),
                      ],
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Cc',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          _selectedCc.isEmpty
                              ? 'Select recipients'
                              : _ccPeopleOptions
                                    .where(
                                      (person) =>
                                          _selectedCc.contains(person.email),
                                    )
                                    .map((person) => person.name)
                                    .join(', '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _subjectController,
        decoration: const InputDecoration(
          labelText: 'Subject',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _messageController,
        minLines: 5,
        maxLines: 10,
        decoration: const InputDecoration(
          labelText: 'Message',
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 16),
      Align(
        alignment: Alignment.centerRight,
        child: FilledButton.icon(
          onPressed: _sendMessage,
          icon: const Icon(Icons.send_outlined),
          label: const Text('Send'),
        ),
      ),
    ],
  );

  Widget _messageTable(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SortableDataTable(
      showCheckboxColumn: false,
      headingRowColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      columns: const ['Business', 'Location', 'To', 'Cc', 'Subject', 'Message'],
      rows: [
        for (final row in _messageRows)
          [
            row.business,
            row.location,
            row.to,
            row.cc,
            row.subject,
            row.message,
          ],
      ],
      onRowSelected: (index) => _deleteMessageRow(_messageRows[index]),
    ),
  );

  @override
  Widget build(BuildContext context) => ManagementTabLayout(
    title: AppTab.message.label,
    icon: AppTab.message.icon,
    form: Card(
      child: Padding(padding: const EdgeInsets.all(20), child: _emailFields()),
    ),
    recordsTitle: 'Messages',
    records: _messageTable(context),
  );
}

class _MessageRow {
  const _MessageRow({
    required this.business,
    required this.location,
    required this.to,
    required this.cc,
    required this.subject,
    required this.message,
  });

  final String business;
  final String location;
  final String to;
  final String cc;
  final String subject;
  final String message;
}
