# Security testing plan

Run the package tests and example analysis with Flutter 3.50 / Dart 3.14 or newer:

```bash
flutter pub get
flutter analyze
flutter test
cd example
flutter pub get
flutter analyze
flutter test
```

## Required device matrix before publishing

| Environment | Expected validation |
|---|---|
| Stock Android release | No false positives; startup and monitoring latency measured |
| Android Debug/Profile | Debugger signal may be present; startup is not blocked by release-only debugger policy |
| Android rooted with Magisk | Root and modified-system signals evaluated independently |
| Android unlocked bootloader/custom ROM | Modified-system signal may be present without root; policy remains configurable |
| Android emulator | Emulator signal reported without assuming maliciousness |
| Frida server with default name/path/port | Relevant path, process, or port indicators evaluated |
| Renamed Frida server/custom port | Record whether process-level evidence remains visible; do not expect path/port heuristics to guarantee detection |
| Frida Gadget embedded in app | Inspect current-process maps and thread names; record bypasses |
| Xposed/LSPosed/Substrate variants | Record library/process indicators and false positives |
| iOS Simulator | Simulator signal reported; jailbreak/hook checks may be unsupported or intentionally skipped |
| Stock iOS release | No false positives; app-switcher masking and capture behavior verified |
| Jailbroken iOS device | Jailbreak paths/sandbox behavior and loaded-image indicators evaluated |
| Re-signed Android APK | Signing fingerprint mismatch when configured with the production signing certificate |
| Play-distributed Android build | Verify against the Play app-signing certificate, not the upload key |
| Unsupported native API / channel failure | Report is `inconclusive`, not silently `clear` |

## Release checks

- Test the exact Release artifact after R8 and Flutter obfuscation.
- Preserve the Dart split-debug-info files and native symbols for the exact build.
- Validate certificate fingerprints against the certificate that actually signs the installed artifact.
- Run positive and negative signing tests: actual Debug certificate versus a deliberately incorrect valid 64-character SHA-256 fingerprint (local test build only).
- Verify malformed or missing fingerprints are marked unsupported/inconclusive and exercise both fail-open and fail-closed `blockOnInconclusive` policies.
- Verify Debug/Profile and Release build variants receive their own intended fingerprint; for Play builds, use the Play app-signing certificate.
- Confirm that periodic checks stop when `stopMonitoring` is called and resume checks when the app returns to foreground.
- Verify that telemetry failures do not crash the app or change the security decision.
- Verify that the `example_old/` directory is unchanged and excluded from the Pub package archive.

A rooted emulator is useful for initial development but does not reproduce every physical-device, kernel, SELinux, vendor-ROM, or jailbreak condition. Do not publish detection-rate claims without a repeatable device matrix.
