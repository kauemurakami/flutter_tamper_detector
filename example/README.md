# Flutter Tamper Detector example

This runnable example targets Flutter 3.50 / Dart 3.14 and demonstrates:

- Startup inspection before `runApp` and app-owned blocked/allowed UI.
- A live dashboard subscribed to the package-wide `reports` broadcast stream.
- Manual one-off checks for root/jailbreak, emulator, modified system, hooks,
  debugger, developer options, and installer metadata.
- Starting/stopping runtime monitoring without tying its lifecycle to a screen.
- App privacy configuration for screenshot protection and app-switcher masking.
- A `SecurityLogger` adapter that can be replaced with Sentry, Crashlytics, or
  an application-specific telemetry client.
- Android signing-certificate validation with separate Debug/Profile and
  Release fingerprints.

Run the example:

```bash
cd example
flutter pub get
flutter run
```

## Android signing identity

Get the signing fingerprints for the variants from the Android Gradle project:

```powershell
cd example/android
.\gradlew.bat signingReport
```

Use the SHA-256 value for the key that signs the installed build. For a local
Debug/Profile run:

```bash
flutter run \
  --dart-define=ANDROID_DEBUG_SIGNING_CERT_SHA256=YOUR_DEBUG_SHA256
```

For a production Release build:

```bash
flutter build apk --release \
  --dart-define=ANDROID_RELEASE_SIGNING_CERT_SHA256=YOUR_RELEASE_SHA256
```

The sample selects the Release fingerprint only when `kReleaseMode` is true;
Debug and Profile use the Debug fingerprint. With Google Play App Signing, use
the Play **app-signing certificate** for the Play-distributed artifact, not the
upload key. Fingerprints are public certificate metadata; never pass a private
key or keystore password through `--dart-define`.

For a negative local test, replace the configured fingerprint with a different
valid 64-character hexadecimal value (for example, 64 zeroes). The report
should contain `signing_certificate_mismatch`; with `blockOnInvalidSignature`
enabled, the startup policy should deny protected UI. Restore the real
fingerprint before producing a release build.

## Security behavior and limitations

The sample intentionally does not block root, emulator, developer options, or
modified-system signals by default. It blocks detected instrumentation and a
native debugger in Release builds. Adjust the policy for your threat model.
Local checks are heuristics and can be bypassed by an attacker controlling the
process. Use server-side Play Integrity or App Attest validation for sensitive
backend operations.

The dashboard cancels only its own stream subscription in `dispose()`; it does
not stop application-wide monitoring. The blocked screen is an example only:
replace it with your own support, recovery, or verification flow.
