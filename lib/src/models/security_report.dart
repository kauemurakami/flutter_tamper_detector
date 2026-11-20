import 'security_finding.dart';
import 'security_status.dart';

/// Immutable result of one security inspection and its startup policy decision.
class SecurityReport {
  /// Creates a report containing all observations collected in one inspection.
  const SecurityReport({
    required this.status,
    required this.findings,
    required this.shouldLaunch,
    required this.isDebugBuild,
    required this.timestamp,
    this.errors = const <String>[],
  });

  /// Aggregate outcome: clear, risk detected, or inconclusive.
  final SecurityStatus status;

  /// Individual platform observations returned by native code.
  final List<SecurityFinding> findings;

  /// Whether the configured policy permits the protected application to launch.
  final bool shouldLaunch;

  /// Whether this application binary is a debug build (not debugger attachment).
  final bool isDebugBuild;

  /// Time at which this report was assembled.
  final DateTime timestamp;

  /// Non-sensitive descriptions of checks that could not be completed.
  final List<String> errors;

  /// Returns only serializable diagnostic data; no device identifiers are added.
  Map<String, Object?> toMap() => <String, Object?>{
        'status': status.name,
        'shouldLaunch': shouldLaunch,
        'isDebugBuild': isDebugBuild,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'findings': findings.map((finding) => finding.toMap()).toList(),
        'errors': errors,
      };

  /// Builds a report from the Dart policy and native findings.
  ///
  /// [findings] contains the observations to aggregate. [isDebugBuild] describes
  /// the compiled build mode. [shouldBlock] decides whether each detected
  /// finding blocks launch. [blockOnInconclusive] selects fail-closed behavior
  /// when a required check is unavailable. [errors] contains sanitized errors.
  factory SecurityReport.evaluate({
    required List<SecurityFinding> findings,
    required bool isDebugBuild,
    required bool Function(SecurityFinding finding) shouldBlock,
    bool blockOnInconclusive = false,
    List<String> errors = const <String>[],
  }) {
    final blocked = findings.any((finding) => finding.detected && shouldBlock(finding));
    final status = blocked || findings.any((finding) => finding.detected)
        ? SecurityStatus.riskDetected
        : errors.isNotEmpty || findings.isEmpty || findings.any((finding) => !finding.supported)
            ? SecurityStatus.inconclusive
            : SecurityStatus.clear;
    return SecurityReport(
      status: status,
      findings: List<SecurityFinding>.unmodifiable(findings),
      shouldLaunch: !blocked && !(status == SecurityStatus.inconclusive && blockOnInconclusive),
      isDebugBuild: isDebugBuild,
      timestamp: DateTime.now(),
      errors: List<String>.unmodifiable(errors),
    );
  }
}
