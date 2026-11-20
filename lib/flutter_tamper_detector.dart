/// Flutter Tamper Detector public API.
///
/// The package collects local security signals on Android and iOS. Signals are
/// heuristics, not proof that a device or process is uncompromised. For
/// sensitive server operations, combine local checks with server-validated
/// platform attestation (Play Integrity or App Attest).
library flutter_tamper_detector;

export 'src/app_privacy.dart';
export 'src/models/security_finding.dart';
export 'src/models/security_options.dart';
export 'src/models/security_report.dart';
export 'src/models/security_status.dart';
export 'src/security_logger.dart';
export 'src/flutter_tamper_detector.dart';
