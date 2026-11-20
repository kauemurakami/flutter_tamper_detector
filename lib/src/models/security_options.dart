import 'dart:convert';

/// Controls which local checks run and how their findings affect startup.
class SecurityOptions {
  /// Creates the security policy used by `FlutterTamperDetector.initialize`.
  const SecurityOptions({
    this.checkRoot = true,
    this.checkModifiedSystem = false,
    this.checkEmulator = true,
    this.checkHooks = true,
    this.checkDebugger = true,
    this.checkDeveloperOptions = false,
    this.checkInstaller = false,
    this.checkSigningCertificate = false,
    this.expectedSigningCertificateSha256,
    this.blockOnRoot = false,
    this.blockOnModifiedSystem = false,
    this.blockOnEmulator = false,
    this.blockOnHooks = true,
    this.blockOnDebuggerInRelease = true,
    this.blockOnDeveloperOptions = false,
    this.blockOnUntrustedInstaller = false,
    this.blockOnInvalidSignature = true,
    this.blockOnInconclusive = false,
    this.monitoringInterval = const Duration(seconds: 15),
    this.monitorHooks = true,
    this.monitorDebugger = true,
  });

  /// Enables Android root and iOS jailbreak heuristics.
  final bool checkRoot;

  /// Checks indicators such as verified-boot state and test build tags.
  final bool checkModifiedSystem;

  /// Checks whether the app runs in an emulator or simulator.
  final bool checkEmulator;

  /// Inspects loaded modules, process maps, and known instrumentation indicators.
  final bool checkHooks;

  /// Checks whether a native debugger is attached to the process.
  final bool checkDebugger;

  /// Checks Android developer options and USB debugging settings.
  final bool checkDeveloperOptions;

  /// Checks whether the installation source is an expected official store.
  final bool checkInstaller;

  /// Checks the Android signing certificate against [expectedSigningCertificateSha256].
  final bool checkSigningCertificate;

  /// Expected Android signing-certificate SHA-256 fingerprint, formatted as
  /// 64 hexadecimal characters (colons and whitespace are accepted).
  /// This is a public certificate fingerprint, not a private key or secret.
  final String? expectedSigningCertificateSha256;

  /// Whether [expectedSigningCertificateSha256] has a valid SHA-256 format.
  ///
  /// A valid value contains exactly 64 hexadecimal characters after optional
  /// colon and whitespace separators are removed. This validates formatting
  /// only; it does not verify that the fingerprint belongs to the installed APK.
  bool get hasValidExpectedSigningCertificateSha256 {
    final fingerprint = expectedSigningCertificateSha256;
    if (fingerprint == null) return false;
    final normalized = fingerprint.replaceAll(RegExp(r'[\s:]'), '');
    return RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(normalized);
  }

  /// Blocks startup when root/jailbreak heuristics detect a signal.
  final bool blockOnRoot;

  /// Blocks startup when modified-system indicators are detected.
  final bool blockOnModifiedSystem;

  /// Blocks startup when an emulator/simulator is detected.
  final bool blockOnEmulator;

  /// Blocks startup when instrumentation indicators are detected.
  final bool blockOnHooks;

  /// Blocks startup for an attached debugger in a non-debug build.
  final bool blockOnDebuggerInRelease;

  /// Blocks startup when Android developer options or USB debugging are enabled.
  final bool blockOnDeveloperOptions;

  /// Blocks startup when the installer does not match Google Play (Android).
  final bool blockOnUntrustedInstaller;

  /// Blocks startup when the supplied signing-certificate fingerprint mismatches.
  final bool blockOnInvalidSignature;

  /// Blocks startup when a required check cannot be completed. Defaults to fail-open.
  final bool blockOnInconclusive;

  /// Interval between background/foreground runtime inspections.
  final Duration monitoringInterval;

  /// Enables periodic instrumentation checks after initialization.
  final bool monitorHooks;

  /// Enables periodic debugger checks after initialization.
  final bool monitorDebugger;

  /// Serializes the options for the native inspection request.
  Map<String, Object?> toMap() => <String, Object?>{
        'checkRoot': checkRoot,
        'checkModifiedSystem': checkModifiedSystem,
        'checkEmulator': checkEmulator,
        'checkHooks': checkHooks,
        'checkDebugger': checkDebugger,
        'checkDeveloperOptions': checkDeveloperOptions,
        'checkInstaller': checkInstaller,
        'checkSigningCertificate': checkSigningCertificate,
        'expectedSigningCertificateSha256': expectedSigningCertificateSha256,
      };

  /// Returns a JSON representation suitable for diagnostics (fingerprint omitted).
  String toDiagnosticJson() {
    final map = toMap()..remove('expectedSigningCertificateSha256');
    return jsonEncode(map);
  }
}
