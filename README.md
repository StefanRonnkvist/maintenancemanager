# Maintenance Manager
Maintenance Manager is a Flutter app for keeping maintenance equipment, spare parts, people, business contacts, and related records organized. Add forms collapse so you can focus on the saved record lists. The app starts in Dark appearance; choose System, Dark, or Light in Settings.

## Main tabs
The app entry point in `lib/main.dart` launches `lib/app.dart`, which creates the primary tab navigation and shares People and Business records with dependent tabs.
- **Equipment** — add equipment under built-in or custom categories and types. Record the associated business and location, local name and number, manufacturer, model, serial number, maintenance manual, and publisher.
- **Spare Parts** — track OEM and vendor part numbers and descriptions, serial number, quantity in stock, and location. The vendor selector lists businesses with type Vendor.
- **Work Order** — select a business and its location to view the location name, address, direct phone number, and nearest airport. This tab currently provides location selection and details; it does not create or save work order records.
- **People** — keep names, direct and cell phone numbers, email, business and location associations, remote-work status, and nearest airport.
- **Business** — create Customer, Vendor, or Principle entries with contact details, airports, and one or more business locations.
- **Information** — Contact sends a support question; Submissions displays available responses associated with this app.
- **Message** — compose an email from your people and business lists. Set sender details, filter contacts by business, select To and Cc recipients, and open the system share/email app with a `mailto` link. Sender fields are for reference and are not included in that link; the app does not itself deliver email.
- **Application DB** — create, edit, and delete local key/value records. Choose Equipment, Spare Parts, People, or Business to import or export that category's CSV records, or save an example or blank CSV template. Imports append records to the selected category.
- **Help** — in-app guidance for using the tabs, managing records, CSV workflows, and appearance settings.

Use **Settings → Tab order** to drag tabs into your preferred order. Your tab order is saved on the device and restored when you reopen the app or rotate the device.

## Data and privacy
Equipment, spare parts, people, business, and Application DB records are stored locally on the device. Clearing app data or uninstalling may remove these records; keep CSV exports as backups. Message hands a `mailto` link to the system share/email app, and delivery depends on the app you choose. Contact submissions send the details you enter, your question, and basic app/device diagnostics to the configured support service. Review the Contact form before sending sensitive information.

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
The app version is `0.1.22+23` (from `pubspec.yaml`). Configured release tasks build for Android, Web, and Windows; the Windows workflow also produces an MSIX package.

## Development
Install Flutter, then run `flutter pub get` and `flutter run`. Run `flutter analyze` to check the code. To audit documentation against the app, run:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/audit-docs.ps1
```
