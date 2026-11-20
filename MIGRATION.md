# Migration to 1.0.0

Version 1.0.0 replaces per-method process termination flags with a centralized report and policy. This is a deliberate API change: the package must not terminate or uninstall an application as a side effect of a detector call.

## Before

```dart
final hooked = await FlutterTamperDetector.isHooked(exitProcessIfTrue: true);
final rooted = await FlutterTamperDetector.isRooted(uninstallIfTrue: true);
```

## After

```dart
final report = await FlutterTamperDetector.initialize(
  options: const SecurityOptions(
    checkHooks: true,
    checkRoot: true,
    blockOnHooks: true,
    blockOnRoot: false,
  ),
);

if (!report.shouldLaunch) {
  runApp(const SecurityBlockedApp());
} else {
  runApp(const MyApp());
}
```

## API changes

- `isRooted()`, `isHooked()`, and `isEmulator()` remain as report-only convenience methods; they no longer accept `exitProcessIfTrue` or `uninstallIfTrue`.
- Use `isDebugBuild` to inspect Flutter build mode and `isDebuggerAttached()` for a runtime debugger.
- `isDebug()` remains temporarily available but is deprecated because it previously mixed build mode and debugger semantics.
- `isInstalledFromStore()` remains a convenience check; configure `checkInstaller` in `SecurityOptions` when you need the installer finding in the aggregate report.
- Use `AppPrivacy.configure(obscureAppSwitcherPreview: ...)`; the old `hideInMenu` parameter and `appSecuritySettings()` method are deprecated aliases.
- Implement `SecurityLogger` to connect your telemetry provider.
- Subscribe to `FlutterTamperDetector.reports` to observe startup, manual, and monitoring reports from any screen or service. The broadcast stream does not replay prior events; use `FlutterTamperDetector.instance.lastReport` for the latest completed report.
- Cancel a screen's own `StreamSubscription` in `dispose()`. Do not call `stopMonitoring()` from a dashboard or route's `dispose()` because monitoring is application-wide.

## Signing fingerprint

Set `checkSigningCertificate: true` and provide `expectedSigningCertificateSha256`. Use the SHA-256 of the certificate that signs the installed APK. Debug/Profile and Release variants may use different signing certificates; provide the matching fingerprint for each build configuration. `hasValidExpectedSigningCertificateSha256` validates its format, not the signer identity. For Play App Signing, use the Play app-signing certificate rather than the upload certificate. A mismatch is a local signal, not a server-verifiable integrity proof.

## Policy defaults

Hooks are blocking by default. A debugger is blocking only in Release mode. Root, modified-system, emulator, and developer-options signals are report-only by default to avoid breaking development and legitimate test environments. Review these settings for your application's risk tolerance.
