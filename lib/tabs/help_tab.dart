import 'package:flutter/material.dart';

/// In-app reference guide; each topic is expandable to keep the page compact.
class HelpTab extends StatelessWidget {
  const HelpTab({super.key});

  // Keep guidance aligned with the current tab features and data flow.
  static const _sections = <_HelpSection>[
    _HelpSection(
      title: 'Getting started',
      icon: Icons.start_outlined,
      content: 'Use the tabs along the top to move between Equipment, Spare Parts, Work Order, People, Business, Information, Message, Application DB, and Help. Add forms are collapsed by default; tap the form heading to expand it. Open Settings and drag items in Tab order to customize navigation; your order is saved on this device and restored after restart or rotation.',
    ),
    _HelpSection(
      title: 'Equipment',
      icon: Icons.precision_manufacturing_outlined,
      content: 'Enter equipment category, equipment name, business, location, and equipment details: local name and number, manufacturer, model, serial number, maintenance manual, and publisher. Add Equipment saves a row in the equipment list.',
    ),
    _HelpSection(
      title: 'Spare Parts',
      icon: Icons.build_outlined,
      content: 'Enter OEM and vendor part numbers and descriptions, vendor name, serial number, stock quantity, and location. Add Spare Part adds the record to the list.',
    ),
    _HelpSection(
      title: 'Work Order',
      icon: Icons.assignment_outlined,
      content: 'Choose a business and one of its locations to fill in the saved address, direct phone number, and airport details. Review equipment at that location and select any equipment to include. Check the matching people and Principle-business contact lists, then choose a component category and component and add notes. Save Work Order creates a numbered local record. Tap a row to edit it, print it to PDF or a printer, or mark it complete; completed orders appear in their own list and can be reopened. Import and export work orders through Application DB → Work Order.',
    ),
    _HelpSection(
      title: 'People and Business',
      icon: Icons.people_outline,
      content: 'Add people with their name, phone and email, business and work location, remote-work status, and nearest airport. Add businesses by choosing Customer, Vendor, or Principle, then enter contact details, airports, and business locations. Tables show saved records and their associated locations.',
    ),
    _HelpSection(
      title: 'Message',
      icon: Icons.message_outlined,
      content: 'Choose a business and optional location to find people with email addresses. Select To and Cc contacts, add a subject and message, and tap Send. The app saves the composed message in the Messages list, then opens an external email app using a mailto link; it does not send the email itself. Message history is saved locally and is available for CSV import/export in Application DB → Messages. If you opened Message from a person or spare-part contact, the recipient and relevant details may already be filled in.',
    ),
    _HelpSection(
      title: 'Saved data',
      icon: Icons.save_outlined,
      content: 'Equipment, spare parts, people, businesses, saved work orders, message history, and Application DB records are stored locally on this device. Clearing app data or uninstalling may remove local records. Keep CSV exports as backups.',
    ),
    _HelpSection(
      title: 'Application DB and CSV',
      icon: Icons.table_view_outlined,
      content: 'Application DB opens first when the app starts. Use it to create, edit, and delete local key/value records, and choose Equipment, Spare Parts, People, Business, Work Order, or Messages for CSV actions. Import appends valid rows to the selected category, so check for duplicates before importing. Use an example or blank template to get the expected column headers. Exported CSV files can be saved or shared, depending on your device.',
    ),
    _HelpSection(
      title: 'Settings and Information',
      icon: Icons.settings_outlined,
      content: 'Open Settings in the upper-right corner to choose System, Dark, or Light appearance, or drag items in Tab order to rearrange navigation. Your appearance choice and tab order are kept on this device. Information contains Contact for support questions and Submissions for available responses. Contact sends the details you enter, your question, and basic app/device diagnostics to the support service; review your message before sending sensitive information.'
    ),
  ];

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('Help', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(
        'Guidance for using Maintenance Manager.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 16),
      for (final section in _sections)
        Card(
          child: ExpansionTile(
            leading: Icon(section.icon),
            title: Text(section.title),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(section.content)],
          ),
        ),
      const SizedBox(height: 8),
      const Text(
        'If you need more help, open Information → Contact to send a question.',
      ),
    ],
  );
}

class _HelpSection {
  const _HelpSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  final String title;
  final IconData icon;
  final String content;
}
