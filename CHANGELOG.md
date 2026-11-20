## 1.0.0
### Fixed
- Corrected Android signing-certificate selection so Kotlin uses a consistent `Signature?` type on API 28+ and legacy Android versions.
- Kept application-wide monitoring active when the example dashboard is disposed; the dashboard now cancels only its own report subscription.

### Added
- Broadcast `FlutterTamperDetector.reports` stream and `isMonitoring` state for app-wide report observation.
- SHA-256 fingerprint format validation through `SecurityOptions.hasValidExpectedSigningCertificateSha256`.
- Separate Debug/Profile and Release signing fingerprint configuration in the example, plus positive/negative signing test guidance.
- Expanded example dashboard with live reports, individual checks, monitoring controls, app privacy, and a customizable blocked screen.
- Additional signing validation test cases and documentation in the README and security testing guide.
- Anti-REA roadmap items for developer-owned signing profiles, key rotation, and a safe debug/test validation workflow.

### Added
- Centralized `FlutterTamperDetector.initialize` API with configurable security checks and startup policy.
- Structured `SecurityReport`, `SecurityFinding`, `SecurityStatus`, and `SecuritySeverity` models.
- Three aggregate outcomes: `clear`, `riskDetected`, and `inconclusive`.
- Configurable fail-open/fail-closed handling for inconclusive checks.
- Periodic and foreground-resume runtime inspection for instrumentation and debugger indicators.
- Android process-map, thread-name, known-path, and common Frida-port heuristics.
- Android developer-options and USB-debugging indicators.
- Android verified-boot/build-property checks separated from root heuristics.
- Android signing-certificate SHA-256 fingerprint comparison.
- Vendor-neutral `SecurityLogger` interface for Sentry, Crashlytics, and custom telemetry adapters.
- `onReport` callback for startup and runtime-monitoring events.
- `AppPrivacy.configure` with platform-specific behavior documented accurately and the clearer `obscureAppSwitcherPreview` option.
- Swift Package Manager manifest and privacy manifest resource integration for iOS.
- Updated example app, DartDoc, security model, migration guide, and Anti-REA roadmap.

### Changed
- Requires Flutter 3.50.0+ and Dart 3.14.0+.
- Android installer lookup uses `PackageManager.getInstallSourceInfo` on API 30+ and retains the deprecated `getInstallerPackageName` fallback only for older Android versions.
- Debug build detection is separated from runtime debugger attachment.
- Local detectors return findings; the package no longer terminates or attempts to uninstall the host application.
- Android app privacy uses `FLAG_SECURE` instead of `FLAG_FULLSCREEN` for screenshot and recent-task thumbnail protection.

### Removed
- Automatic process termination and application self-uninstallation behavior.
- Claims that local receipt presence, installer metadata, file names, or process ports prove application integrity.
- Broad ProGuard keep-rule recommendations; the README links to official Flutter/R8/ProGuard documentation instead.

### Security notes
- Root, jailbreak, emulator, instrumentation, debugger, and modified-system checks remain heuristic.
- iOS screenshot prevention is not guaranteed; the plugin masks app-switcher content and reacts to active capture where possible.
- Play Integrity and App Attest require backend validation and are documented as integration guidance, not falsely advertised as built-in remote attestation.
- Rust/FFI is intentionally not included in this release. Native checks remain Kotlin and Swift.

## 0.6.1
- Migrated Android build configuration to support AGP 9.0+ built-in Kotlin.
- Applied a compatibility fix ahead of the planned 1.0 API refactor.

## 0.6.0
- Added the initial iOS build.

## 0.5.0
- Added app privacy settings for screenshot protection and recent-apps preview masking.

## 0.4.0
- Added installation-source detection for Google Play.

## 0.3.1
- Fixed formatting and package scoring metadata.

## 0.3.0
- Added the original optional root-assisted self-uninstallation behavior (removed in 1.0.0).

## 0.2.1
- Added additional Magisk-related root indicators.

## 0.2.0
- Added the original Android debuggable-build check.

## 0.1.4
- Added initial R8/ProGuard documentation (replaced in 1.0.0 with official documentation links).

## 0.1.3
- Applied Dart formatting fixes.

## 0.1.2
- Updated the README.

## 0.1.1
- Added an example of native startup checks.

## 0.1.0
- Added optional native process termination after a positive detector result (removed in 1.0.0).

## 0.0.2
- Fixed repository references.

## 0.0.1
- Initial release with root, hook, and emulator detection.
