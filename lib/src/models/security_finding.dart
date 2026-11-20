import 'security_status.dart';

/// A single observation collected by a platform security check.
class SecurityFinding {
  /// Creates an immutable security observation.
  ///
  /// [code] is a stable identifier, [category] groups related checks,
  /// [detected] records the observed condition, [severity] describes its
  /// relative impact, [description] explains the result, and [supported]
  /// indicates whether the current platform can perform the check.
  const SecurityFinding({
    required this.code,
    required this.category,
    required this.detected,
    required this.severity,
    required this.description,
    this.supported = true,
  });

  /// Stable machine-readable identifier, such as `debugger_attached`.
  final String code;

  /// Broad area inspected, such as `instrumentation` or `environment`.
  final String category;

  /// Whether the detector observed the condition represented by [code].
  final bool detected;

  /// Relative severity assigned to this observation.
  final SecuritySeverity severity;

  /// Human-readable explanation that is safe to include in diagnostic logs.
  final String description;

  /// Whether this platform/build supports the check.
  final bool supported;

  /// Converts this finding to a JSON-compatible map.
  Map<String, Object?> toMap() => <String, Object?>{
        'code': code,
        'category': category,
        'detected': detected,
        'severity': severity.name,
        'description': description,
        'supported': supported,
      };

  /// Creates a finding from a platform-channel response.
  ///
  /// [map] is the decoded native result containing the finding fields.
  factory SecurityFinding.fromMap(Map<Object?, Object?> map) {
    final severityName = map['severity'] as String? ?? 'info';
    return SecurityFinding(
      code: map['code'] as String? ?? 'unknown',
      category: map['category'] as String? ?? 'general',
      detected: map['detected'] as bool? ?? false,
      severity: SecuritySeverity.values.firstWhere(
        (value) => value.name == severityName,
        orElse: () => SecuritySeverity.info,
      ),
      description: map['description'] as String? ?? 'No description provided.',
      supported: map['supported'] as bool? ?? true,
    );
  }
}
