# Maintenance Manager
Maintenance Manager is a Flutter app for organizing equipment, spare parts, people, business contacts, and application records. Management forms and record tables are available in the main tab bar. The default appearance is Dark; change it from Settings.

## Main tabs
- **Equipment** — add equipment by category and type, associate it with a business and location, and record identifiers, manufacturer, model, serial number, maintenance manual, and publisher.
- **Spare Parts** — keep OEM/vendor part details, stock quantity, and location. The vendor dropdown uses businesses marked as Vendor.
- **People** — store contact information, business and work-location association, remote-work status, and nearest airport.
- **Business** — store business type and contact information, business locations, and airports.
- **Information** — use Contact to send a support question and Submissions to view available responses.
- **Application DB** — create, edit, and delete key/value records. Select Equipment, Spare Parts, People, or Business to import/export that category's CSV data or download an example/blank CSV template.
- **Help** — in-app guidance about forms, records, local data, CSV import/export, appearance, and support.

## Data and privacy
Management records and Application DB records are stored locally on the device using local preferences. CSV export is available for backup, and CSV imports add records to the selected category. Contact submissions send the entered contact information, question, and basic app/device diagnostics to the configured support endpoint. Review the contact form before submitting sensitive information.

## Store listing
Google Play copy is maintained in `store_listing/`:

- `google_play_short_description.txt`
- `google_play_full_description.txt`

## Version and platforms
The app version is `0.1.15+16` (from `pubspec.yaml`). Configured release tasks build for Android, Web, and Windows; the Windows workflow also produces an MSIX package.

## Development
Install Flutter, then run `flutter pub get` and `flutter run`. Run `flutter analyze` to check the code. To audit the README and store listing against the app, run:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/audit-docs.ps1
```
