import 'package:flutter/material.dart';

/// In-app reference guide; each topic is expandable to keep the page compact.
class HelpTab extends StatelessWidget {
  const HelpTab({super.key});

  // Keep guidance aligned with the current tab features and data flow.
  static const _sections = <_HelpSection>[
    _HelpSection(
      title: 'Getting started',
      icon: Icons.start_outlined,
      content: 'Use the tabs along the top to move between Equipment, Spare Parts, People, Business, Information, Message, Application DB, and Help. Add forms are collapsed by default; tap the form heading to expand it.',
    ),
    _HelpSection(
      title: 'Equipment',
      icon: Icons.precision_manufacturing_outlined,
      content: 'Choose or add an equipment category and equipment type, select a business and location, then enter the equipment details: local name and number, manufacturer, model, serial number, maintenance manual, and publisher. Add Equipment saves a row in the equipment list.',
    ),
    _HelpSection(
      title: 'Spare Parts',
      icon: Icons.build_outlined,
      content: 'Enter OEM and vendor part numbers and descriptions, serial number, stock quantity, and location. Vendor Name is selected from businesses whose type is Vendor. Add Spare Part adds the record to the list.',
    ),
    _HelpSection(
      title: 'People and Business',
      icon: Icons.people_outline,
      content: 'Add people with their name, phone and email, business and work location, remote-work status, and nearest airport. Add businesses by choosing Customer, Vendor, or Principle, then enter contact details, airports, and business locations. Tables show saved records and their associated locations.',
    ),
    _HelpSection(
      title: 'Message',
      icon: Icons.message_outlined,
      content: 'Set sender name, sender email, and reply email, then select a business to filter contacts. Choose recipients for To and Cc, add a subject and message, and tap Send to add a row to the in-app Messages list and open the system share/email app with a mailto link. The sender fields are for reference and are not included in the mailto link; message delivery depends on the app you choose.',
    ),
    _HelpSection(
      title: 'Saved data',
      icon: Icons.save_outlined,
      content: 'Equipment, spare parts, people, businesses, and Application DB records are stored locally on this device. Clearing app data or uninstalling may remove local records. Keep CSV exports as backups.',
    ),
    _HelpSection(
      title: 'Application DB and CSV',
      icon: Icons.table_view_outlined,
      content: 'In Application DB, select a record category before using the menu. Import CSV adds rows to that category; the file must use the matching template headers. Export CSV saves the selected category. Example and blank templates help prepare compatible files.',
    ),
    _HelpSection(
      title: 'Appearance and Information',
      icon: Icons.settings_outlined,
      content: 'Open Settings in the upper-right corner to choose System, Dark, or Light appearance. Information contains Contact for support questions and Submissions for viewing available responses. Contact sends the details you enter, your question, and basic app/device diagnostics to the support service.',
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
