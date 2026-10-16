import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_tab.dart';
import '../models/business_entry.dart';
import '../widgets/management_tab_layout.dart';

class MessageTab extends StatefulWidget {
  const MessageTab({required this.people, required this.businesses, super.key});

  final List<BusinessEntry> people;
  final List<BusinessEntry> businesses;

  @override
  State<MessageTab> createState() => _MessageTabState();
}

class _MessageTabState extends State<MessageTab> {
  final Set<String> _selectedBusinessNames = {};
  final Set<String> _selectedToEmails = {};
  final Set<String> _selectedCcEmails = {};
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

  Future<void> _sendMessage() async {
    final to = _selectedToEmails.map(_emailFromRecipient).join(', ');
    final cc = _selectedCcEmails.map(_emailFromRecipient).join(', ');
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

  String _emailFromRecipient(String recipient) {
    final openingBracket = recipient.lastIndexOf('<');
    final closingBracket = recipient.lastIndexOf('>');
    if (openingBracket >= 0 && closingBracket > openingBracket) {
      return recipient.substring(openingBracket + 1, closingBracket).trim();
    }
    return recipient.trim();
  }

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
    _senderNameController.dispose();
    _senderEmailController.dispose();
    _senderReplyEmailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  List<BusinessEntry> get _filteredPeople {
    if (_selectedBusinessNames.isEmpty) return widget.people;
    return widget.people
        .where((person) => _selectedBusinessNames.contains(person.businessName))
        .toList();
  }

  Widget _emailFields() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Compose email message',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 16),
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
          SizedBox(
            width: 320,
            child: _MultiSelectField(
              label: 'Business',
              options: widget.businesses
                  .map((business) => business.name)
                  .where((name) => name.trim().isNotEmpty)
                  .toSet(),
              selectedValues: _selectedBusinessNames,
              onChanged: (values) => setState(() {
                _selectedBusinessNames
                  ..clear()
                  ..addAll(values);
              }),
            ),
          ),
          SizedBox(
            width: 320,
            child: _MultiSelectField(
              label: 'To',
              options: _filteredPeople
                  .where((person) => person.email.trim().isNotEmpty)
                  .map((person) => '${person.name} <${person.email}>')
                  .toSet(),
              selectedValues: _selectedToEmails,
              onChanged: (values) => setState(() {
                _selectedToEmails
                  ..clear()
                  ..addAll(values);
              }),
            ),
          ),
          SizedBox(
            width: 320,
            child: _MultiSelectField(
              label: 'Cc',
              options: _filteredPeople
                  .where((person) => person.email.trim().isNotEmpty)
                  .map((person) => '${person.name} <${person.email}>')
                  .toSet(),
              selectedValues: _selectedCcEmails,
              onChanged: (values) => setState(() {
                _selectedCcEmails
                  ..clear()
                  ..addAll(values);
              }),
            ),
          ),
          SizedBox(
            width: 320,
            child: TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
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
}

class _MultiSelectField extends StatelessWidget {
  const _MultiSelectField({
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
  });

  final String label;
  final Set<String> options;
  final Set<String> selectedValues;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Select $label',
    onSelected: (value) {
      final updatedValues = Set<String>.from(selectedValues);
      if (updatedValues.contains(value)) {
        updatedValues.remove(value);
      } else {
        updatedValues.add(value);
      }
      onChanged(updatedValues);
    },
    itemBuilder: (context) => options
        .map(
          (option) => CheckedPopupMenuItem<String>(
            value: option,
            checked: selectedValues.contains(option),
            child: Text(option),
          ),
        )
        .toList(),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      child: Text(
        selectedValues.isEmpty ? 'Select $label' : selectedValues.join(', '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
