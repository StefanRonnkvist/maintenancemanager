# Maintenance Manager
Maintenance Manager is a Flutter app for keeping maintenance equipment, spare parts, people, business contacts, and related records organized. Add forms collapse so you can focus on the saved record lists. The app starts in Dark appearance; choose System, Dark, or Light in Settings.

## Main tabs
The app entry point in `lib/main.dart` launches `lib/app.dart`, which creates the primary tab navigation and shares People and Business records with dependent tabs.
- **Equipment** — add equipment under built-in or custom categories and types. Record the associated business and location, local name and number, manufacturer, model, serial number, maintenance manual, publisher, and up to four equipment subsections. Tap a row to edit it.
- **Spare Parts** — track OEM and vendor part numbers and descriptions, serial number, stock quantity, vendor, and storage location. Vendors are selected from businesses with type Vendor; tap a row to edit a part and view matching vendor contacts.
- **Work Order** — select a business and location to see its saved address, direct phone, and airport details, then choose equipment at that location, review matching and Principle-business contacts, select a component, and add notes. Save numbered work orders locally; tap a row to edit, print to PDF/printer, or mark complete. Completed work orders can be reopened.
- **People** — keep names, titles, direct and cell phone numbers, email, business and location associations, remote-work status, and nearest airport.
- **Business** — create Customer, Vendor, or Principle entries with contact details, airports, and up to four business locations.
- **Information** — Contact sends a support question; Submissions displays available responses associated with this app.
- **Message** — compose an email using people in your contacts. Filter recipients by business and location, select To and Cc recipients (including Principle contacts), and open an external email app with a `mailto` link. Message history is saved locally. Sender details are for reference and are not included in that link; the app does not itself deliver email. Selecting a person from a spare-part record can prefill a message.
- **Application DB** — opens when the app starts. Create, edit, and delete local key/value records. Choose Equipment, Spare Parts, People, Business, Work Order, or Messages to import/export CSV records, or generate an example or blank template. Imports append valid rows, so check for duplicates.
- **Help** — expandable in-app guidance for using the tabs, work orders, CSV workflows, local data, and settings.

Use **Settings → Tab order** to drag tabs into your preferred order. Your tab order and appearance choice are saved on the device. The app starts on Application DB each time it opens.

## Data and privacy
Equipment, spare parts, people, business, work orders, message history, and Application DB records are stored locally on the device. Clearing app data or uninstalling may remove these records; keep CSV exports as backups. Message hands a `mailto` link to the system share/email app, and delivery depends on the app you choose. Contact submissions send the details you enter, your question, and basic app/device diagnostics to the configured support service. Review the Contact form before sending sensitive information.

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
The app version is `0.1.54+55` (from `pubspec.yaml`). Configured release tasks build for Android, Web, and Windows; the Windows workflow also produces an MSIX package.

## Development
Install Flutter, then run `flutter pub get` and `flutter run`. Run `flutter analyze` to check the code. To audit documentation against the app, run:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/audit-docs.ps1
```
