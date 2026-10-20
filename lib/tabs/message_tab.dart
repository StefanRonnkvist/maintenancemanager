import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_tab.dart';
import '../models/business_entry.dart';
import '../services/local_record_store.dart';
import '../widgets/management_tab_layout.dart';

/// Builds a message composer with free-entry recipients.
class MessageTab extends StatefulWidget {
  const MessageTab({required this.people, super.key});

  final List<BusinessEntry> people;

  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  static const _storageKey = 'message_records_v1';

  final _toController = TextEditingController();
  final _ccController = TextEditingController();
  String? _selectedTo;
  String? _selectedCc;

  List<BusinessEntry> get _peopleOptions => widget.people
      .where((person) => person.name.trim().isNotEmpty && person.email.trim().isNotEmpty)
      .toList()
    ..sort((first, second) => first.name.compareTo(second.name));
  final _senderNameController = TextEditingController();
  final _senderEmailController = TextEditingController();
  final _senderReplyEmailController = TextEditingController();
  final _subjectController = TextEditingController();
  bool _senderDetailsSet = false;
  String _storedSenderName = '';
  String _storedSenderEmail = '';
  String _storedSenderReplyEmail = '';
  final _messageController = TextEditingController();
  final List<_EmailMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final records = await LocalRecordStore.read(_storageKey);
      if (!mounted) return;
      setState(() => _messages.addAll(records.map(_EmailMessage.fromJson)));
    } catch (_) {
      // Message composition remains available when the history cannot be read.
    }
  }

  Future<void> _persistMessages() async {
    await LocalRecordStore.write(
      _storageKey,
      _messages.map((item) => item.toJson()).toList(),
    );
  }

  /// Records the composed message locally in this tab and opens a mailto target.
  Future<void> _sendMessage() async {
    final to = _toController.text.trim();
    final cc = _ccController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (to.isEmpty && cc.isEmpty && subject.isEmpty && message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add message details before sending.')),
      );
      return;
    }

    setState(() {
      _messages.add(
        _EmailMessage(to: to, cc: cc, subject: subject, message: message),
      );
    });
    try {
      await _persistMessages();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save message history: $error')),
        );
      }
    }

    final mailUri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        if (cc.isNotEmpty) 'cc': cc,
        if (subject.isNotEmpty) 'subject': subject,
        if (message.isNotEmpty) 'body': message,
      },
    );

    try {
      await SharePlus.instance.share(ShareParams(uri: mailUri));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the email app: $error')),
        );
      }
    }
  }

  /// Locks the sender fields, or restores the values captured when they were set.
  void _toggleSenderDetails() {
    setState(() {
      if (_senderDetailsSet) {
        _senderNameController.text = _storedSenderName;
        _senderEmailController.text = _storedSenderEmail;
        _senderReplyEmailController.text = _storedSenderReplyEmail;
        _senderDetailsSet = false;
      } else {
        _storedSenderName = _senderNameController.text;
        _storedSenderEmail = _senderEmailController.text;
        _storedSenderReplyEmail = _senderReplyEmailController.text;
        _senderDetailsSet = true;
      }
    });
  }

  @override
  void dispose() {
    _toController.dispose();
    _ccController.dispose();
    _senderNameController.dispose();
    _senderEmailController.dispose();
    _senderReplyEmailController.dispose();
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
            Text(
              'Sender details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _senderNameController,
                    readOnly: _senderDetailsSet,
                    decoration: const InputDecoration(
                      labelText: 'Sender Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _senderEmailController,
                    readOnly: _senderDetailsSet,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Sender Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _senderReplyEmailController,
                    readOnly: _senderDetailsSet,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Sender Reply Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: FilledButton(
                    onPressed: _toggleSenderDetails,
                    child: Text(_senderDetailsSet ? 'Reset' : 'Set'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
                    key: ValueKey('to-$_selectedTo'),
                    initialValue: _selectedTo,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'To',
                      border: OutlineInputBorder(),
                    ),
                    items: _peopleOptions
                        .map((person) => DropdownMenuItem(
                              value: person.email,
                              child: Text(person.name),
                            ))
                        .toList(),
                    onChanged: (email) => setState(() {
                      _selectedTo = email;
                      _toController.text = email ?? '';
                    }),
                  ),
                ),
                SizedBox(
                  width: 320,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('cc-$_selectedCc'),
                    initialValue: _selectedCc,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Cc',
                      border: OutlineInputBorder(),
                    ),
                    items: _peopleOptions
                        .map((person) => DropdownMenuItem(
                              value: person.email,
                              child: Text(person.name),
                            ))
                        .toList(),
                    onChanged: (email) => setState(() {
                      _selectedCc = email;
                      _ccController.text = email ?? '';
                    }),
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

  /// Shows messages composed during this screen's current lifetime.
  Widget _messageTable(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
      headingRowColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      dataRowMinHeight: 52,
      columns: const [
        DataColumn(label: Text('To')),
        DataColumn(label: Text('Cc')),
        DataColumn(label: Text('Subject')),
        DataColumn(label: Text('Message')),
      ],
      rows: _messages
          .map(
            (message) => DataRow(
              cells: [
                DataCell(Text(message.to)),
                DataCell(Text(message.cc)),
                DataCell(Text(message.subject)),
                DataCell(Text(message.message)),
              ],
            ),
          )
          .toList(),
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

class _EmailMessage {
  const _EmailMessage({
    required this.to,
    required this.cc,
    required this.subject,
    required this.message,
  });

  final String to;
  final String cc;
  final String subject;
  final String message;

  Map<String, String> toJson() => {
    'to': to,
    'cc': cc,
    'subject': subject,
    'message': message,
  };

  factory _EmailMessage.fromJson(Map<String, dynamic> json) => _EmailMessage(
    to: json['to'] as String? ?? '',
    cc: json['cc'] as String? ?? '',
    subject: json['subject'] as String? ?? '',
    message: json['message'] as String? ?? '',
  );
}
