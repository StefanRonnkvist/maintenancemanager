# Maintenance Manager
Maintenance Manager is a Flutter app for organizing personal maintenance records. The current interface is a starter shell; some tabs are placeholders and the Information tab provides contact and submission views.

## App navigation
- **Home** — home placeholder.
- **Favorites** — favorites placeholder.
- **Profile** — profile placeholder.
- **Information** — contains the Contact and Submissions views. Contact sends an inquiry to the configured support endpoint; Submissions displays available inquiry responses.
- **Application DB** — create, edit and delete locally stored application records.

The Information sub-tabs are **Contact** and **Submissions**.

## Store listing
Google Play copy is maintained in `store_listing/`:

- `google_play_short_description.txt`
- `google_play_full_description.txt`

## Version
The app version is `0.1.9+10` (from `pubspec.yaml`).

## Supported release targets
The configured release tasks build for Android, Web and Windows. The Windows workflow also produces an MSIX package.

## Development
Install Flutter and run `flutter pub get`, then start the app with `flutter run`. To audit the README and store listing against the app, run `pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/audit-docs.ps1`.
