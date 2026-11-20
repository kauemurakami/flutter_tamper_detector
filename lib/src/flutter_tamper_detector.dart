import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'models/security_finding.dart';
import 'models/security_options.dart';
import 'models/security_report.dart';
import 'models/security_status.dart';
import 'security_logger.dart';

/// Callback invoked after each completed security inspection.
typedef SecurityReportCallback = void Function(SecurityReport report);

/// Coordinates native security inspections and applies the startup policy.
///
/// Call [initialize] before `runApp` to inspect the environment before showing
/// protected UI. Local checks are heuristic and cannot establish trust against
/// an attacker who fully controls the process. Use server-validated attestation
/// for sensitive backend operations.
class FlutterTamperDetector with WidgetsBindingObserver {
  FlutterTamperDetector._();

  /// Shared coordinator used by the static package API.
  static final FlutterTamperDetector instance = FlutterTamperDetector._();

  static const MethodChannel _channel = MethodChannel('flutter_tamper_detector');
  SecurityOptions _options = const SecurityOptions();
  SecurityLogger _logger = const DeveloperSecurityLogger();
  Timer? _monitorTimer;
  SecurityReport? _lastReport;
  final StreamController<SecurityReport> _reportsController =
      StreamController<SecurityReport>.broadcast();
  bool _observerAttached = false;
  bool _inspectionRunning = false;
  SecurityReportCallback? _onReport;

  /// Most recent completed inspection, or `null` before the first inspection.
  SecurityReport? get lastReport => _lastReport;

  /// Broadcast stream of completed startup, manual, and monitoring reports.
  ///
  /// The stream does not replay previous events; read [lastReport] for the
  /// latest report when subscribing after initialization. Each listener owns
  /// its subscription and should cancel it when its screen or service ends.
  /// Cancelling a subscription does not stop application-wide monitoring.
  static Stream<SecurityReport> get reports => instance._reportsController.stream;

  /// Whether periodic or foreground-lifecycle monitoring is currently active.
  static bool get isMonitoring =>
      instance._monitorTimer != null || instance._observerAttached;

  /// Runs configured checks and evaluates the startup policy.
  ///
  /// [options] selects checks, blocking behavior, and monitoring interval.
  /// [logger] receives structured security events; the default logger uses
  /// `dart:developer` logging. [onReport] and [reports] receive every completed
  /// inspection, including periodic checks. The signing-certificate fingerprint
  /// is public metadata and should match the certificate that signs the installed
  /// Android artifact.
  ///
  /// Returns a [SecurityReport]. The caller must inspect [SecurityReport.shouldLaunch]
  /// and decide which UI to display. This package deliberately does not call
  /// `exit()` or terminate the host process.
  static Future<SecurityReport> initialize({
    SecurityOptions options = const SecurityOptions(),
    SecurityLogger logger = const DeveloperSecurityLogger(),
    SecurityReportCallback? onReport,
  }) async {
    return instance._initialize(options: options, logger: logger, onReport: onReport);
  }

  Future<SecurityReport> _initialize({
    required SecurityOptions options,
    required SecurityLogger logger,
    required SecurityReportCallback? onReport,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    _options = options;
    _logger = logger;
    _onReport = onReport;
    final report = await checkNow();
    if (options.monitorHooks || options.monitorDebugger) {
      startMonitoring();
    } else {
      stopMonitoring();
    }
    return report;
  }

  /// Performs a single inspection using the currently configured options.
  ///
  /// Returns an inconclusive report if the native platform cannot be reached.
  /// A platform-channel failure is not silently interpreted as a clean device.
  static Future<SecurityReport> checkNow() => instance._checkNow();

  Future<SecurityReport> _checkNow({bool runtimeOnly = false}) async {
    if (_inspectionRunning) {
      return _lastReport ?? SecurityReport(
        status: SecurityStatus.inconclusive,
        findings: const <SecurityFinding>[],
        shouldLaunch: !_options.blockOnInconclusive,
        isDebugBuild: kDebugMode,
        timestamp: DateTime.now(),
        errors: const <String>['An inspection is already running.'],
      );
    }
    _inspectionRunning = true;
    try {
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
        final report = SecurityReport(
          status: SecurityStatus.inconclusive,
          findings: const <SecurityFinding>[],
          shouldLaunch: !_options.blockOnInconclusive,
          isDebugBuild: kDebugMode,
          timestamp: DateTime.now(),
          errors: const <String>['Security inspection is supported on Android and iOS only.'],
        );
        _lastReport = report;
        _notifyReport(report);
        return report;
      }
      final request = _options.toMap();
      if (runtimeOnly) {
        request
          ..['checkRoot'] = false
          ..['checkModifiedSystem'] = false
          ..['checkEmulator'] = false
          ..['checkDeveloperOptions'] = false
          ..['checkInstaller'] = false
          ..['checkSigningCertificate'] = false;
        request['checkHooks'] = _options.monitorHooks;
        request['checkDebugger'] = _options.monitorDebugger;
      }
      final raw = await _channel.invokeMapMethod<String, Object?>('runSecurityChecks', request);
      if (raw == null) throw const FormatException('Native security response was empty.');
      final nativeFindings = (raw['findings'] as List<Object?>? ?? const <Object?>[])
          .whereType<Map<Object?, Object?>>()
          .map(SecurityFinding.fromMap)
          .toList();
      final errors = (raw['errors'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>()
          .toList();
      final isDebugBuild = kDebugMode;
      final report = SecurityReport.evaluate(
        findings: nativeFindings,
        isDebugBuild: isDebugBuild,
        errors: errors,
        shouldBlock: _shouldBlock,
        blockOnInconclusive: _options.blockOnInconclusive,
      );
      _lastReport = report;
      _notifyReport(report);
      _emit('security_inspection', report.toMap());
      if (report.status == SecurityStatus.riskDetected) {
        _emit('security_risk_detected', report.toMap());
      }
      return report;
    } on PlatformException catch (error) {
      return _inconclusive('Platform inspection failed (${error.code}).');
    } on Object catch (error) {
      return _inconclusive('Security inspection could not be completed (${error.runtimeType}).');
    } finally {
      _inspectionRunning = false;
    }
  }

  bool _shouldBlock(SecurityFinding finding) {
    if (!finding.detected) return false;
    switch (finding.code) {
      case 'root_or_jailbreak': return _options.blockOnRoot;
      case 'modified_system': return _options.blockOnModifiedSystem;
      case 'emulator_or_simulator': return _options.blockOnEmulator;
      case 'instrumentation_detected': return _options.blockOnHooks;
      case 'debugger_attached': return _options.blockOnDebuggerInRelease && !kDebugMode && !kProfileMode;
      case 'developer_options_enabled': return _options.blockOnDeveloperOptions;
      case 'untrusted_installer': return _options.blockOnUntrustedInstaller;
      case 'signing_certificate_mismatch': return _options.blockOnInvalidSignature;
      default: return false;
    }
  }

  void _notifyReport(SecurityReport report) {
    try {
      _onReport?.call(report);
    } on Object {
      // Application callbacks must not interrupt inspection or monitoring.
    }
    _reportsController.add(report);
  }

  void _emit(String event, Map<String, Object?> data) {
    try {
      _logger.logSecurityEvent(event, data);
    } on Object {
      // Telemetry failures must never change the security decision or crash startup.
    }
  }

  SecurityReport _inconclusive(String message) {
    final report = SecurityReport(
      status: SecurityStatus.inconclusive,
      findings: const <SecurityFinding>[],
      shouldLaunch: !_options.blockOnInconclusive,
      isDebugBuild: kDebugMode,
      timestamp: DateTime.now(),
      errors: <String>[message],
    );
    _lastReport = report;
    _notifyReport(report);
    _emit('security_inspection_inconclusive', report.toMap());
    return report;
  }

  /// Starts periodic checks for enabled runtime signals.
  ///
  /// The operating system may suspend the app in the background. The detector
  /// therefore also checks again when the application returns to the foreground.
  static void startMonitoring() => instance._startMonitoring();

  void _startMonitoring() {
    if (!_options.monitorHooks && !_options.monitorDebugger) {
      _stopMonitoring();
      return;
    }
    if (!_observerAttached) {
      WidgetsBinding.instance.addObserver(this);
      _observerAttached = true;
    }
    _monitorTimer?.cancel();
    if (_options.monitoringInterval <= Duration.zero) return;
    _monitorTimer = Timer.periodic(_options.monitoringInterval, (_) {
      if (_options.monitorHooks || _options.monitorDebugger) {
        unawaited(_checkNow(runtimeOnly: true));
      }
    });
  }

  /// Stops periodic inspections and removes the lifecycle observer.
  static void stopMonitoring() => instance._stopMonitoring();

  void _stopMonitoring() {
    _monitorTimer?.cancel();
    _monitorTimer = null;
    if (_observerAttached) {
      WidgetsBinding.instance.removeObserver(this);
      _observerAttached = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && (_options.monitorHooks || _options.monitorDebugger)) {
      unawaited(_checkNow(runtimeOnly: true));
    }
  }

  /// Reports whether the current Flutter build was compiled in debug mode.
  ///
  /// This is a build-mode property, not a runtime debugger check.
  static bool get isDebugBuild => kDebugMode;

  /// Checks whether the app was installed by the expected store.
  ///
  /// Android checks the recorded installer package. iOS reports receipt-file
  /// presence only; receipt presence is not cryptographic App Store attestation.
  /// Throws a platform-channel exception if the native inspection cannot be called.
  static Future<bool> isInstalledFromStore() async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return false;
    final raw = await _channel.invokeMapMethod<String, Object?>(
      'runSecurityChecks', <String, Object?>{'checkInstaller': true},
    );
    final items = raw?['findings'] as List<Object?>? ?? const <Object?>[];
    for (final item in items.whereType<Map<Object?, Object?>>()) {
      final finding = SecurityFinding.fromMap(item);
      if (finding.code == 'untrusted_installer') return !finding.detected && finding.supported;
    }
    return false;
  }

  /// Checks root/jailbreak indicators without applying a process-termination action.
  ///
  /// Throws a platform-channel exception if the native inspection cannot be called.
  static Future<bool> isRooted() async => _readFlag('root_or_jailbreak');

  /// Checks emulator/simulator indicators without terminating the process.
  ///
  /// Throws a platform-channel exception if the native inspection cannot be called.
  static Future<bool> isEmulator() async => _readFlag('emulator_or_simulator');

  /// Checks Android modified-build and verified-boot indicators.
  ///
  /// iOS does not expose an equivalent generic system-modification check.
  /// Throws a platform-channel exception if the native inspection cannot be called.
  static Future<bool> isModifiedSystem() async => _readFlag('modified_system');

  /// Checks Android developer-options and USB-debugging settings.
  ///
  /// iOS does not expose a public equivalent setting.
  /// Throws a platform-channel exception if the native inspection cannot be called.
  static Future<bool> isDeveloperOptionsEnabled() async => _readFlag('developer_options_enabled');

  /// Checks runtime instrumentation indicators without terminating the process.
  ///
  /// Throws a platform-channel exception if the native inspection cannot be called.
  static Future<bool> isHooked() async => _readFlag('instrumentation_detected');

  /// Checks whether a native debugger is currently attached to the process.
  ///
  /// Throws a platform-channel exception if the native inspection cannot be called.
  static Future<bool> isDebuggerAttached() async => _readFlag('debugger_attached');

  /// Checks whether the current application build is debuggable.
  ///
  /// This legacy asynchronous API is retained for source compatibility. Use
  /// [isDebugBuild] for build mode and [isDebuggerAttached] for runtime tracing.
  @Deprecated('Use isDebugBuild or isDebuggerAttached instead.')
  static Future<bool> isDebug() async => isDebugBuild;

  static Future<bool> _readFlag(String code) async {
    final optionName = switch (code) {
      'root_or_jailbreak' => 'checkRoot',
      'emulator_or_simulator' => 'checkEmulator',
      'modified_system' => 'checkModifiedSystem',
      'developer_options_enabled' => 'checkDeveloperOptions',
      'instrumentation_detected' => 'checkHooks',
      'debugger_attached' => 'checkDebugger',
      _ => null,
    };
    if (optionName == null) return false;
    final raw = await _channel.invokeMapMethod<String, Object?>(
      'runSecurityChecks', <String, Object?>{optionName: true},
    );
    final items = raw?['findings'] as List<Object?>? ?? const <Object?>[];
    for (final item in items.whereType<Map<Object?, Object?>>()) {
      final finding = SecurityFinding.fromMap(item);
      if (finding.code == code) return finding.detected;
    }
    return false;
  }
}
