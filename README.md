# Flutter Tamper Detector

[![pub package](https://img.shields.io/pub/v/flutter_tamper_detector.svg)](https://pub.dev/packages/flutter_tamper_detector)
[![likes](https://img.shields.io/pub/likes/flutter_tamper_detector)](https://pub.dev/packages/flutter_tamper_detector)
[![popularity](https://img.shields.io/pub/popularity/flutter_tamper_detector)](https://pub.dev/packages/flutter_tamper_detector)
[![license](https://img.shields.io/github/license/kauemurakami/flutter_tamper_detector)](LICENSE)

Native Android and iOS runtime security signals for Flutter applications. The package collects root/jailbreak, modified-system, emulator, instrumentation, debugger, installer, and Android signing-certificate indicators and returns a structured report for your application to evaluate.

> **Security boundary:** local checks are heuristics. They increase attack cost and provide useful telemetry, but they cannot prove that a device or process is uncompromised. For sensitive operations, validate platform attestation on your backend.

## Requirements

- Flutter 3.50.0 or newer.
- Dart 3.14.0 or newer.
- Android API 24+.
- iOS 13.0+.

## Install

```bash
flutter pub add flutter_tamper_detector
```

## Quick start

Run initialization after Flutter binding initialization and before `runApp`. The package never terminates the process: your application owns the user experience and the final startup decision. A runtime plugin cannot prevent Android/iOS from installing a package; it can only report risk and let your app withhold protected UI or sensitive functionality after launch.

```dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tamper_detector/flutter_tamper_detector.dart';

// These values are optional. Debug/Profile can run without a fingerprint.
const debugSigningFingerprint = String.fromEnvironment(
  'ANDROID_DEBUG_SIGNING_CERT_SHA256',
);
const releaseSigningFingerprint = String.fromEnvironment(
  'ANDROID_RELEASE_SIGNING_CERT_SHA256',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This example uses the Debug fingerprint in Debug/Profile and the Release
  // fingerprint in Release. If no value is supplied, signing validation stays
  // disabled instead of preventing a local Debug run.
  final signingFingerprint =
      kReleaseMode ? releaseSigningFingerprint : debugSigningFingerprint;

  final report = await FlutterTamperDetector.initialize(
    options: SecurityOptions(
      // Checks to execute.
      checkRoot: true,
      checkModifiedSystem: Platform.isAndroid,
      checkEmulator: true,
      checkHooks: true,
      checkDebugger: true,
      checkDeveloperOptions: Platform.isAndroid,
      checkInstaller: false,
      checkSigningCertificate:
          Platform.isAndroid && signingFingerprint.isNotEmpty,
      expectedSigningCertificateSha256:
          signingFingerprint.isEmpty ? null : signingFingerprint,

      // Decide which detected findings should block startup.
      blockOnRoot: false,
      blockOnModifiedSystem: false,
      blockOnEmulator: false,
      blockOnHooks: true,
      blockOnDebuggerInRelease: true,
      blockOnDeveloperOptions: false,
      blockOnUntrustedInstaller: false,
      blockOnInvalidSignature: true,
      blockOnInconclusive: false,

      // Runtime monitoring configuration.
      monitoringInterval: const Duration(seconds: 15),
      monitorHooks: true,
      monitorDebugger: true,
    ),
  );

  runApp(report.shouldLaunch ? const ProtectedApp() : const SecurityBlockedApp());
}
```

The signing fingerprint is optional. With the configuration above, Debug and
Profile builds run normally when `ANDROID_DEBUG_SIGNING_CERT_SHA256` is not
provided: `checkSigningCertificate` becomes `false`. Release builds also skip
this local check if `ANDROID_RELEASE_SIGNING_CERT_SHA256` is missing, so provide
the Release fingerprint in your production build pipeline if you want this
check enforced. The package does not silently treat a missing fingerprint as a
valid signature; it simply does not run the check when you disable it this way.

The full runnable sample is in [`example/`](example/README.md). The previous sample is preserved in [`example_old/`](example_old/); it is not part of the new API documentation.

## Result model

Each inspection returns a `SecurityReport` with one of three aggregate states:

| Status | Meaning | Typical response |
|---|---|---|
| `clear` | At least one check completed, and no supported check detected configured risk indicators. If no checks ran, the result is inconclusive. | Continue normally. |
| `riskDetected` | One or more checks observed a risk indicator. | Apply the policy; show a warning, require additional verification, or block a sensitive action. |
| `inconclusive` | A check failed or is unsupported on the current platform. | Retry, report telemetry, or block if `blockOnInconclusive` is enabled. |

`shouldLaunch` is calculated from the configured blocking policy. A detected signal does not necessarily block startup. Root and emulator signals are report-only by default; Android-only modified-system and developer-options checks are opt-in and report-only by default; instrumentation and a debugger in a Release build are blocking by default. Adjust these defaults to your application's threat model.

A `SecurityFinding` includes a stable `code`, `category`, `detected`, `severity`, `description`, and `supported` flag. Do not treat severity as a calibrated probability.

## Configuration

`SecurityOptions` exposes all checks, blocking policies, and runtime-monitoring
settings. The Quick start above shows every constructor option; the reference
below explains what each group controls.

### Checks

- `checkRoot`: root on Android and jailbreak heuristics on iOS.
- `checkModifiedSystem`: Android build tags and verified-boot indicators. Disabled by default because it has no generic iOS equivalent; explicitly enabling it on iOS produces an unsupported finding.
- `checkEmulator`: emulator/simulator heuristics.
- `checkHooks`: loaded-process maps, thread indicators, and known instrumentation signals.
- `checkDebugger`: native debugger attachment. This is distinct from the Flutter build mode (`Debug`, `Profile`, or `Release`).
- `checkDeveloperOptions`: Android developer-options and ADB settings. Disabled by default because iOS has no public equivalent API; explicitly enabling it on iOS produces an unsupported finding.
- `checkInstaller`: Google Play installer metadata on Android and receipt-file presence on iOS. Receipt presence is not receipt validation.
- `checkSigningCertificate`: compares the Android package signing certificate SHA-256 fingerprint to `expectedSigningCertificateSha256`. iOS reports this local check as unsupported; use App Attest.
- `expectedSigningCertificateSha256`: expected public signing-certificate fingerprint. It must contain 64 hexadecimal characters; colons and whitespace are accepted. It is not a private key.

### Blocking policy

A check can report a finding without blocking startup. These options determine
whether the corresponding finding makes `report.shouldLaunch` false:

- `blockOnRoot`: block when root/jailbreak heuristics detect a signal.
- `blockOnModifiedSystem`: block when modified-system indicators are detected.
- `blockOnEmulator`: block when an emulator/simulator is detected.
- `blockOnHooks`: block when instrumentation indicators are detected.
- `blockOnDebuggerInRelease`: block for an attached debugger in a Release build; Debug/Profile behavior is not implied by this option.
- `blockOnDeveloperOptions`: block when Android developer options or USB debugging are enabled.
- `blockOnUntrustedInstaller`: block when the installer does not match the expected Google Play source on Android.
- `blockOnInvalidSignature`: block when the configured signing-certificate fingerprint does not match.
- `blockOnInconclusive`: block when a check cannot complete or is unsupported. This is the optional fail-closed policy.

### Runtime monitoring

- `monitoringInterval`: interval between periodic runtime inspections (15 seconds by default). Monitoring is best-effort; operating systems can suspend background applications.
- `monitorHooks`: enables periodic instrumentation checks after initialization.
- `monitorDebugger`: enables periodic debugger checks after initialization.

### Optional signing check in Debug/Profile

You do not need a fingerprint just to run the app in Debug. Keep
`checkSigningCertificate` false when the selected fingerprint is empty, as in
the Quick start example. If you want to test the check locally, provide the
Debug certificate fingerprint with `--dart-define`; for production, configure
the certificate that actually signs the installed Release artifact. Remember
that this example also leaves the check disabled in Release if its fingerprint
is missing, so configure that value in your release pipeline when enforcement
is required.

See [`SecurityOptions`](lib/src/models/security_options.dart) for the complete DartDoc.

## Flutter 3.50 native integration

The iOS plugin includes a Swift Package Manager manifest and continues to ship a CocoaPods specification for projects that still use the legacy integration. Flutter 3.50 also stabilizes direct native interop tooling (FFIgen for Objective-C/C and JNIgen for Java/Kotlin). This package intentionally retains `MethodChannel` for its low-frequency, asynchronous inspection calls: the payloads are small, and the channel keeps native lifecycle and threading behavior behind Flutter's plugin API. Direct JNI/FFI would add manual thread/lifetime responsibilities without a meaningful benefit for these checks.

See the [Flutter native interop guide](https://docs.flutter.dev/interop), [JNIgen](https://docs.flutter.dev/interop/jnigen), and [Swift Package Manager plugin author guide](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors).

## Runtime monitoring

When `monitorHooks` or `monitorDebugger` is enabled, the package repeats those checks periodically and when the app returns to the foreground. It does **not** create a permanent background service and cannot guarantee continuous execution while the OS suspends the app.

```dart
FlutterTamperDetector.startMonitoring();
// When monitoring is no longer required by the application:
FlutterTamperDetector.stopMonitoring();
```

Subscribe to completed reports from any screen or application service with the
broadcast stream. It emits startup, manual, and periodic reports. It does not
replay old events, so use `FlutterTamperDetector.instance.lastReport` to obtain the latest known
result when subscribing after initialization. Cancel only the listener owned by the screen;
do not stop the singleton monitor from a screen's `dispose()` method.

```dart
import 'dart:async';

late final StreamSubscription<SecurityReport> subscription;

void observeSecurity() {
  subscription = FlutterTamperDetector.reports.listen((report) {
    if (!report.shouldLaunch) {
      // Lock protected features or route to your own restricted screen.
    }
  });
}

void stopObserving() {
  subscription.cancel();
}
```

`FlutterTamperDetector.isMonitoring` reports whether periodic or foreground-
lifecycle monitoring is active. The application owns its global start/stop
policy; individual screens own only their stream subscriptions.


## Detailed documentation

- [Anti-REA roadmap and threat model](doc/ANTI_REA_PLAN.md)
- [Play Integrity and App Attest integration guide](doc/ATTESTATION.md)
- [Security test matrix](doc/TESTING.md)
- [Migration guide](MIGRATION.md)
- [Security policy](SECURITY.md)

## Security policy

Please report vulnerabilities privately where possible. See [SECURITY.md](SECURITY.md) for the threat model and reporting guidance.

## Android signing certificate SHA-256

The fingerprint is a hash of the public signing certificate. It is not a
private key and does not reveal signing credentials. It identifies the signer;
it does not prove runtime memory integrity or that code has not been modified
after launch. The option is Android-only; iOS reports this local check as
unsupported and should use App Attest for server-validated app integrity.

Obtain the fingerprint for the key that actually signs the installed APK. For
an Android project, run the Gradle signing report (PowerShell shown):

```powershell
cd android
.\gradlew.bat signingReport
```

Find the `SHA-256` value under the relevant variant. If you use a custom release
keystore, confirm the report reflects that signing configuration. With Google
Play App Signing, use the **app signing certificate**, not the upload
certificate, for builds installed from Google Play.

You can configure your own signing identity separately for Debug/Profile and
Release builds. The example uses two build-time values and selects the Release
fingerprint only for a Release build:

```bash
# Local Debug/Profile run, signed with the Android debug key.
flutter run \
  --dart-define=ANDROID_DEBUG_SIGNING_CERT_SHA256=YOUR_DEBUG_SHA256

# Production Release, signed with your configured release key.
flutter build appbundle --release \
  --dart-define=ANDROID_RELEASE_SIGNING_CERT_SHA256=YOUR_RELEASE_SHA256
```

Pass the selected value to `SecurityOptions.expectedSigningCertificateSha256`
and set `checkSigningCertificate: true`. The value must contain 64 hexadecimal
characters; colon separators and whitespace are accepted. The package exposes
`hasValidExpectedSigningCertificateSha256` to validate the configured format
before making a native request. This checks formatting only, not signer identity.

For a controlled negative test, use a deliberately incorrect but correctly
formatted value, such as 64 zeroes, in a local test build. With
`blockOnInvalidSignature: true`, the native check should report
`signing_certificate_mismatch` and the policy should set `shouldLaunch` to
`false`. Use the actual Debug certificate fingerprint for the positive test.
Do not ship the deliberately incorrect value. An invalidly formatted or missing
fingerprint is reported as unsupported/inconclusive rather than as a proven
signature mismatch; `blockOnInconclusive` controls that separate case.

Do not embed private keys, keystore passwords, or credentials in Dart defines.
A local fingerprint check can be patched by an attacker who controls the
client; use server-side attestation for high-value actions.

## App privacy

```dart
await AppPrivacy.configure(
  preventScreenshot: true,
  obscureAppSwitcherPreview: true,
);
```

- **Android:** `FLAG_SECURE` blocks screenshots and screen recording and obscures the recent-apps preview. Android does not provide a supported general API to remove an app from the Recents list.
- **iOS:** third-party apps cannot reliably prevent screenshots. The package obscures the app-switcher snapshot and reacts to active screen capture. A screenshot notification is delivered after the screenshot and cannot undo it.

The legacy `hideInMenu` parameter and `AppPrivacy.appSecuritySettings` method remain temporarily available as deprecated aliases.

## Logging and Sentry/Crashlytics

Implement `SecurityLogger` to forward sanitized events to your telemetry provider. The package does not add a Sentry or Firebase dependency.

```dart
class AppSecurityLogger implements SecurityLogger {
  @override
  void logSecurityEvent(String event, Map<String, Object?> data) {
    // Forward to Sentry/Crashlytics using your application's adapter.
    // Never attach credentials, personal data, or stable device identifiers.
  }
}
```

Pass it to `FlutterTamperDetector.initialize(logger: AppSecurityLogger())`. The optional `onReport` callback and `FlutterTamperDetector.reports` broadcast stream receive startup and runtime-monitoring reports, allowing your app to lock sensitive screens or update its UI without forcing the package to terminate the process.

## Platform coverage and limitations

| Signal | Android | iOS |
|---|---|---|
| Root / jailbreak | File and executable heuristics | Filesystem and sandbox heuristics |
| Modified OS / boot state | Build tags and verified-boot properties | Generic check unsupported |
| Emulator / simulator | Build-property heuristics | Compile-time simulator detection |
| Runtime instrumentation | `/proc/self/maps`, thread names, known paths, common Frida TCP ports | dyld loaded-image names |
| Debugger | `Debug.isDebuggerConnected` / waiting state | `sysctl` process traced flag |
| Developer options / ADB | Android global settings | No public equivalent |
| Installer | `getInstallSourceInfo` on API 30+ | Receipt-file presence only |
| Signing identity | SHA-256 signing certificate comparison | Local certificate fingerprint check unsupported |
| Remote attestation | Integrate Play Integrity on the backend | Integrate App Attest on the backend |

The Frida TCP ports 27042/27043 and known library names are weak indicators, not universal signatures. Renaming a server, changing ports, embedding a custom Gadget, using inline hooks, or patching the detector can evade local heuristics. The plugin deliberately does not scan the entire Android filesystem: ordinary apps are sandboxed and cannot reliably inspect every directory, and unrestricted recursive scans would be expensive and noisy. Root and modified-system findings are separate: `su`/root-manager evidence suggests root access, while `test-keys`, `ro.debuggable`, verified-boot state, or an unlocked bootloader can indicate a development/custom system without proving that root is available. A custom ROM is not automatically malicious; choose the policy that matches your distribution requirements.

## Remote attestation (recommended for sensitive operations)

- **Android:** [Play Integrity API](https://developer.android.com/google/play/integrity). Build a canonical representation of the operation (for example, method + resource ID + amount + transaction nonce), hash it with SHA-256, and pass that digest as `requestHash`. Your backend independently rebuilds the same canonical request, validates the decoded integrity token, compares the request hash, checks package/certificate/device verdicts, enforces freshness/replay protection, and makes the authorization decision. Do not send raw credentials or private data as the request hash. The request hash binds the token to a request; it is not itself a secret or a signature.
- **iOS:** [App Attest](https://developer.apple.com/documentation/devicecheck/establishing-your-app-s-integrity). Generate and attest a key, issue a unique server challenge, include a hash of the canonical request in the assertion client data, validate the assertion and counter on your backend, and associate the assertion with the exact operation.

Never trust a client-side boolean as authorization. Local results are useful risk signals; remote attestation provides a platform-backed signal that your server can validate.

## Obfuscation and release hardening

This package does not rewrite your application's Dart symbols or Android DEX code. Follow the official guides for your app:

- [Flutter obfuscating Dart code](https://docs.flutter.dev/deployment/obfuscate)
- [Android R8 optimization and code shrinking](https://developer.android.com/build/shrink-code)
- [ProGuard manual](https://www.guardsquare.com/manual/home)
- [Android app signing](https://developer.android.com/studio/publish/app-signing)

For Flutter release builds, consider `--obfuscate` and `--split-debug-info`. Keep the symbol files securely for each release. R8 applies to Android DEX code; it does not automatically obfuscate Flutter AOT native code or arbitrary `.so` libraries.

## Anti-REA / reverse-engineering roadmap

The current release implements process-level heuristic checks described above. Future work may include:

1. Stronger integrity manifests and native image validation, with platform-specific compatibility tests.
2. Additional instrumentation research and regression fixtures for renamed Frida, Gadget, Xposed/LSPosed, Substrate/Substitute, and inline-hook scenarios.
3. A release-artifact audit tool for exported symbols, embedded strings, debug metadata, signing identity, and packaging mistakes.
4. Reproducible static-analysis evaluations using JADX, Ghidra, MobSF, and controlled agent-based reverse-engineering workflows.
5. Backend examples for Play Integrity and App Attest, including nonce/request binding and replay tests.
6. A documented test matrix for rooted/jailbroken physical devices and supported emulator/simulator environments.
7. Developer-owned signing identity profiles for Debug/Profile/Release variants, including multiple accepted fingerprints for planned key rotation.
8. A dedicated signing-validation debug/test workflow with deterministic mismatch fixtures and clear separation from production policy. Prefer test-only dependency injection or native test fixtures over a public runtime bypass that could accidentally ship enabled.

Anti-REA does not mean prompt-injection strings, fake functions, or deliberate analyst deception. Those approaches are unreliable and are not security controls. The objective is measurable resistance, detection, and server-side enforcement.


## Testing

Run the package and example test suites from the repository root:

```bash
flutter pub get
flutter analyze
flutter test
cd example
flutter pub get
flutter analyze
flutter test
```

### Signing-certificate test cases (Android)

1. **Positive:** configure the SHA-256 fingerprint of the certificate signing the installed Debug APK; enable `checkSigningCertificate`; expect no `signing_certificate_mismatch` finding.
2. **Negative:** in a local-only test build, configure a different valid 64-character hexadecimal fingerprint (for example, 64 zeroes); expect `signing_certificate_mismatch` and `shouldLaunch == false` when `blockOnInvalidSignature` is enabled.
3. **Format validation:** test a 64-character hexadecimal value, lowercase/uppercase, colon-separated pairs, whitespace, missing input, short input, and non-hexadecimal characters with `hasValidExpectedSigningCertificateSha256`.
4. **Release distribution:** verify against the certificate that signs the installed artifact. For Play-distributed builds, use the Play app-signing certificate, not the upload key.
5. **Policy:** verify that an invalid/missing fingerprint produces an unsupported/inconclusive finding, and test both `blockOnInconclusive: false` and `true` if your app uses fail-closed behavior.

The deliberately incorrect fingerprint is a test fixture, not a production feature or secret. Never add a public switch that forces a fake detection result in production builds.

Validate Release builds on physical Android and iOS devices. Emulator/simulator tests are useful for functional checks but do not reproduce every rooted or jailbroken device behavior. The package does not claim complete Frida, jailbreak, or root detection.
