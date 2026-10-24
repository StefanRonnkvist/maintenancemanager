import 'package:flutter/material.dart';

/// In-app reference guide; each topic is expandable to keep the page compact.
class HelpTab extends StatelessWidget {
  const HelpTab({super.key});

  // Keep guidance aligned with the current tab features and data flow.
  static const _sections = <_HelpSection>[
    _HelpSection(
      title: 'Getting started',
      icon: Icons.start_outlined,
      content: 'Use the tabs along the top to move between Equipment, Spare Parts, Work Order, People, Business, Information, Message, Application DB, and Help. Add forms are collapsed by default; tap a form heading to expand it. Open Settings and drag items in Tab order to customize navigation; your order is saved on this device. The app opens on Application DB each time it starts.',
    ),
    _HelpSection(
      title: 'Equipment',
      icon: Icons.precision_manufacturing_outlined,
      content: 'Choose or enter an equipment category and name, then select a saved business and one of its locations. Add local name and number, manufacturer, model, serial number, maintenance manual, and publisher as needed. Expand any of the four optional subsections to enter additional equipment details. Add Equipment saves a row; tap a row in the sortable list to edit it.',
    ),
    _HelpSection(
      title: 'Spare Parts',
      icon: Icons.build_outlined,
      content: 'Enter OEM and vendor part numbers and descriptions, serial number, stock quantity, storage location, and vendor. Vendors are selected from businesses marked Vendor. Tap a saved part to edit it; matching vendor contacts are shown while editing, and selecting a contact can prefill a Message with the contact and part details.',
    ),
    _HelpSection(
      title: 'Work Order',
      icon: Icons.assignment_outlined,
      content: 'Choose a saved business and one of its locations to populate its address, direct phone number, and airport details. Select equipment associated with that business and location, review matching people and people associated with Principle businesses, then choose a component category and component and add notes. Save Work Order creates a numbered local record. Tap a row under Saved Work Orders or Completed Work Orders to edit it, print it, or complete/reopen it. Import and export work orders through Application DB → Work Order.',
    ),
    _HelpSection(
      title: 'People and Business',
      icon: Icons.people_outline,
      content: 'Add people with their name, title, phone numbers, email, business and work location, remote-work status, and airport information. Add businesses by choosing Customer, Vendor, or Principle, then enter business contact details and up to four locations with address, direct phone, and nearest airport. Saved people and businesses are available to the equipment, spare-part, work-order, and message features.',
    ),
    _HelpSection(
      title: 'Message',
      icon: Icons.message_outlined,
      content: 'Choose a business and optional location to find people with email addresses. Select To and Cc contacts; use Principle to choose people associated with Principle businesses. Add a subject and message, then tap Send. The app saves the composed message in the Messages list and opens an external email app using a mailto link; it does not deliver the email itself. Message history is saved locally and is available for CSV import/export in Application DB → Messages. A Message opened from a matching vendor contact on a spare-part record may have the recipient and part details prefilled.',
    ),
    _HelpSection(
      title: 'Saved data',
      icon: Icons.save_outlined,
      content: 'Equipment, spare parts, people, businesses, saved work orders, message history, and Application DB records are stored locally on this device. Clearing app data or uninstalling may remove local records. Keep CSV exports as backups.',
    ),
    _HelpSection(
      title: 'Application DB and CSV',
      icon: Icons.table_view_outlined,
      content: 'Application DB opens first when the app starts. Use it to create, edit, and delete local key/value records. Choose Equipment, Spare Parts, People, Business, Work Order, or Messages for CSV actions. Imports require the matching template headers and append valid rows to the selected table, so check for duplicates before importing. Use an example or blank template to see the expected columns. Exports and templates can be saved or shared depending on your platform. The selected table also has an option to delete all of its records; this cannot be undone.',
    ),
    _HelpSection(
      title: 'Settings and Information',
      icon: Icons.settings_outlined,
      content: 'Open Settings in the upper-right corner to choose System, Dark, or Light appearance, or drag items in Tab order to rearrange navigation. Tab order is saved on this device; the app appearance choice applies while the app is running. Information contains Contact for support questions and Submissions for available responses. Contact sends the name, return email, question, app version/package details, and basic platform/layout diagnostics you provide to the configured support service. Review the form and avoid including sensitive information.'
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
