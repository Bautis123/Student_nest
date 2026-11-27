# Flutter source archive

Flutter is paused while Student Nest launches as a web app. The active client is `../web-app`.

## Verified snapshot

- File: `flutter-source-2026-10-19.zip`
- Files: 320
- Size: 4,062,199 bytes
- SHA-256: `80ADE6DD52F42873A5AD392511869B5DD1E04991FC6D9679D942B9910C030248`

Every entry was compared byte-for-byte using SHA-256 against the working source after compression. The snapshot contains the tracked Flutter source, all six platform folders, assets, tests, package manifest/lockfile, Flutter configuration, original documentation, and shared admin branding referenced by Flutter. No untracked source files were found in the Flutter source directories.

Generated builds, dependency caches, IDE state, environment secrets, signing credentials and backend runtime are excluded. The Node backend continues separately in `StudentNest/`. The old `lib.zip` is not this backup: it does not replace a complete project archive.

The Flutter source has since been removed from the working tree; this archive and the Git history are the record of it.

## Restore later

From the repository root, extract into a new directory (not over the active web app):

```powershell
Get-FileHash archives/flutter-source-2026-10-19.zip -Algorithm SHA256
Expand-Archive -LiteralPath archives/flutter-source-2026-10-19.zip -DestinationPath flutter-restored
Set-Location flutter-restored
flutter pub get
flutter analyze
flutter test
```

Use a Flutter SDK compatible with the archived `pubspec.yaml`. Reconfigure signing and platform service credentials separately. The archived frontend still requires the existing backend API.
