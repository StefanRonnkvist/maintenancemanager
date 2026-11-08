# Maintenance Manager
Maintenance Manager is a Flutter app for organizing equipment, spare parts, people, businesses, work orders, and email compositions. Its Application DB tab provides editable local key/value records and CSV tools for managed lists. The app opens on Application DB in Dark appearance; choose System, Dark, or Light in Settings. Appearance resets to Dark after restart, while your selected tab order is saved on the device.

## Main tabs
The app entry point in `lib/main.dart` launches `lib/app.dart`, which creates the primary tab navigation and shares People and Business records with dependent tabs.
- **Equipment** — choose an equipment category and name, associate the record with a saved business and location, and record a local name and number, manufacturer, model, serial number, maintenance manual, publisher, and up to four optional subsections. Equipment names and categories can be chosen from bundled lists or entered. Expand the form to add a record; tap a row to edit it.
- **Spare Parts** — track OEM and vendor part numbers and descriptions, serial numbers, stock quantity, vendor, vendor location, and storage location. Choose vendors and their locations from businesses marked Vendor; tap a row to edit a part and view matching people at that vendor location. Selecting a contact opens Message with the recipient, subject, and part details prefilled.
- **Work Order** — select a saved business and location to display its address, direct phone, and nearest airport; select equipment at that location, review people at that location and people associated with Principle businesses, choose a component category and component, and add notes. Save numbered work orders locally; tap a row in Saved Work Orders or Completed Work Orders to edit or print it, mark it complete, or reopen it.
- **People** — keep a name, title, address, direct phone and extension, cell phone, email, nearest airport, and business/location association. Mark a person as Remote Work when applicable.
- **Business** — create Customer, Vendor, or Principle entries with a name, address, direct phone, nearest airport, and up to four locations, each with its own address, direct phone, and nearest airport. Add airports to the selectable list when needed.
- **Information** — Contact sends a support question; Submissions displays available responses associated with this app.
- **Message** — compose an email using people with email addresses in your contacts. Filter regular To and Cc recipients by business and location, and select people associated with Principle businesses separately (they are added to Cc). Send saves the composition locally and opens an external email app with a `mailto` link; Maintenance Manager does not send or confirm delivery. Tap a saved message row to delete it. Selecting a matching vendor contact from an edited spare-part record can prefill the recipient, subject, and part details.
- **Application DB** — opens when the app starts. Create, edit, and delete local key/value records, or choose Equipment, Spare Parts, People, Business, Work Order, or Messages for CSV import and export. Generate a blank or example CSV template for the selected table. Imports require the selected table’s expected headers and append valid rows, so check for duplicates. You can delete all records from the selected table or all local key/value records.
- **Help** — expandable in-app guidance for records, work orders, messages, CSV workflows, local data, settings, and support contact.

Use **Settings → Tab order** to drag tabs into your preferred order; your tab order is saved on the device. Choose System, Dark, or Light appearance in Settings; appearance is held only for the running app and resets to Dark after restart. The app starts on Application DB each time it opens.

## Data and privacy
Equipment, spare parts, people, businesses, work orders, message history, and Application DB records are stored locally on the device. Clearing app data or uninstalling may remove these records; keep CSV exports as backups. Message hands a `mailto` link to an external email app, and delivery depends on the app you choose. Contact submissions send the name, return email, question, app/package version and build details, and platform and screen-layout diagnostics to the configured support service. Review the Contact form before sending sensitive information.

## Source layout
- `lib/app.dart` and `lib/main.dart` — app startup, theme selection, primary tabs, and shared in-memory collections.
- `lib/tabs/` — page-level features for equipment, parts, people/business, information, messages, database tools, and help.
- `lib/widgets/` — reusable forms, tables, tab framing, and grouped form sections.
- `lib/models/` — record models and navigation metadata, including JSON conversions.
- `lib/services/` — shared local record persistence.
- `lib/db/` — editable Application DB records and CSV import/export/templates.
- `lib/contact/` — support contact submission and submissions response viewing.
- `assets/` — image and other bundled resources; platform folders contain generated or platform-specific app configuration.
- `scripts/` — PowerShell helpers for release builds, version updates, cleanup, and documentation audits.
- `store_listing/` — Google Play description text.

## Store listing
Google Play descriptions are maintained in `store_listing/`:

- `google_play_short_description.txt` (80-character field limit)
- `google_play_full_description.txt` (4,000-character field limit)

## Version and platforms
The app version is `0.1.69+70` (from `pubspec.yaml`). Configured release tasks build Android APK and app bundle, Web, and Windows; the Windows workflow also produces an MSIX package.

## Development
Install Flutter, then run `flutter pub get` and `flutter run`. Run `flutter analyze` to check the code. To audit documentation against the app, run:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/audit-docs.ps1
```
