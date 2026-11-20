/// Aggregate outcome of a security inspection.
enum SecurityStatus {
  /// Supported checks completed without detecting configured risk indicators.
  clear,

  /// One or more checks observed a risk indicator.
  riskDetected,

  /// A required check failed or is unsupported on the current platform.
  inconclusive,
}

/// Relative severity assigned to a security observation.
enum SecuritySeverity {
  /// Informational environment or configuration signal.
  info,

  /// Low-impact signal that should usually be logged.
  low,

  /// Signal that may justify additional verification.
  medium,

  /// Strong signal that may justify restricting sensitive functionality.
  high,

  /// Critical signal that may justify blocking a protected operation.
  critical,
}
