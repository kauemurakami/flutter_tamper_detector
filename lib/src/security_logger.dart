import 'dart:developer' as developer;

/// Receives security events without coupling the package to a telemetry vendor.
///
/// Implement this interface to forward events to Sentry, Crashlytics, or an
/// internal observability service. Avoid attaching credentials, personal data,
/// full file paths, or stable device identifiers to security events.
abstract interface class SecurityLogger {
  /// Records a structured security event.
  ///
  /// [event] is a stable event name. [data] contains sanitized diagnostic
  /// fields, usually the serialized security report.
  void logSecurityEvent(String event, Map<String, Object?> data);
}

/// Default logger that emits events through `dart:developer`.
class DeveloperSecurityLogger implements SecurityLogger {
  /// Creates the built-in logger. Set [enabled] to false to silence it.
  const DeveloperSecurityLogger({this.enabled = true});

  /// Whether diagnostic events are emitted.
  final bool enabled;

  @override
  void logSecurityEvent(String event, Map<String, Object?> data) {
    if (!enabled) return;
    developer.log(
      '$event: $data',
      name: 'flutter_tamper_detector',
      level: 900,
    );
  }
}
