import 'package:flutter/material.dart';

/// In-app reference guide; each topic is expandable to keep the page compact.
class HelpTab extends StatelessWidget {
  const HelpTab({super.key});

  // Keep guidance aligned with the current tab features and data flow.
  static const _sections = <_HelpSection>[
    _HelpSection(
      title: 'Getting started',
      icon: Icons.start_outlined,
      content: 'Use the tabs along the top to move between Equipment, Spare Parts, Work Order, People, Business, Information, Message, Application DB, and Help. Forms in the management tabs start collapsed; tap a form heading to expand it. Tap a saved row to open its record for editing where supported. Open Settings to choose System, Dark, or Light appearance, or drag items in Tab order to customize navigation. Tab order is saved on this device; appearance is not saved and resets to Dark when the app restarts. The app opens on Application DB each time it starts.',
    ),
    _HelpSection(
      title: 'Equipment',
      icon: Icons.precision_manufacturing_outlined,
      content: 'Expand Add equipment, choose or enter an equipment category and name, then select a saved business and one of its locations. Add the local name and number, manufacturer, model, serial number, maintenance manual, and publisher as needed. Expand any of the four optional subsections for additional equipment details. Save the form to add the equipment; tap its row in the sortable list to edit it.',
    ),
    _HelpSection(
      title: 'Spare Parts',
      icon: Icons.build_outlined,
      content: 'Expand Add spare parts and enter OEM and vendor part numbers and descriptions, serial number, stock quantity, storage location, and vendor details. Choose vendors from businesses marked Vendor. Tap a saved part to edit it; matching people at that vendor location are shown while editing. Selecting a contact opens Message with that person and the part details prefilled.',
    ),
    _HelpSection(
      title: 'Work Order',
      icon: Icons.assignment_outlined,
      content: 'Expand Work order details, then choose a saved business and one of its locations to fill in the address, direct phone, and airport details; these details can be reviewed or edited. Select equipment associated with that business and location, review people at the selected location and people associated with Principle businesses, choose a component category and component, and add notes. Save Work Order creates a numbered local record. Open a row in Saved Work Orders or Completed Work Orders to edit and print it, or mark it complete/reopen it. Work orders can also be imported or exported in Application DB → Work Order.',
    ),
    _HelpSection(
      title: 'People and Business',
      icon: Icons.people_outline,
      content: 'People records include name, title, direct and cell phone numbers, email, business and work location, remote-work status, and airport information. Business records are classified as Customer, Vendor, or Principle and can include contact details and up to four locations, each with an address, direct phone, and nearest airport. Saved people and businesses are used by the equipment, spare-part, work-order, and message features.',
    ),
    _HelpSection(
      title: 'Message',
      icon: Icons.message_outlined,
      content: 'Choose a business and optional location to find people who have email addresses. Select To and Cc contacts; Principle contacts are chosen separately from people associated with Principle businesses. Add a subject and message, then tap Send. The app saves the composition in its local Messages history and opens an external email app with a mailto link; the app itself does not send or confirm delivery. Message history can be imported or exported as CSV in Application DB → Messages. Opening Message from a matching vendor contact on an edited spare-part record can prefill the recipient, subject, and part details.',
    ),
    _HelpSection(
      title: 'Saved data',
      icon: Icons.save_outlined,
      content: 'Equipment, spare parts, people, businesses, work orders, message history, and Application DB records are stored locally on this device. Tab order is also saved locally. The appearance choice applies only while the app is running. Clearing app data or uninstalling may remove local records; keep CSV exports as backups.',
    ),
    _HelpSection(
      title: 'Application DB and CSV',
      icon: Icons.table_view_outlined,
      content: 'Application DB opens first when the app starts. Use its first table to create, edit, and delete local key/value records. Choose Equipment, Spare Parts, People, Business, Work Order, or Messages to work with CSV files. Imports require the selected table’s expected headers and append valid rows, so check for duplicates before importing. Use an example or blank template to see the expected columns. Exports and templates can be saved or shared depending on your platform. You can delete every record in the selected table or all Application DB records; deletions cannot be undone.',
    ),
    _HelpSection(
      title: 'Settings and Information',
      icon: Icons.settings_outlined,
      content: 'Open Settings in the upper-right corner to choose System, Dark, or Light appearance, or drag items in Tab order to rearrange navigation. Tab order is saved on this device, while appearance resets to Dark when the app restarts. Information contains Contact and Submissions. Contact sends the name, return email, question, app/package version and build details, and platform and screen-layout diagnostics to the configured support service. Submissions loads available responses associated with this app. Review the Contact form and avoid including sensitive information.'
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
