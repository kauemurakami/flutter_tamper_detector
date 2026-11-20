import 'package:flutter_tamper_detector/flutter_tamper_detector.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verifies security option serialization and diagnostic redaction.
void main() {
  test('diagnostic JSON does not include the signing certificate fingerprint', () {
    final fingerprint = List<String>.filled(64, 'A').join();
    final options = SecurityOptions(
      checkSigningCertificate: true,
      expectedSigningCertificateSha256: fingerprint,
    );

    expect(options.toDiagnosticJson(), isNot(contains(fingerprint)));
    expect(options.toMap()['expectedSigningCertificateSha256'], fingerprint);
  });

  test('accepts a 64-character SHA-256 fingerprint with separators', () {
    final fingerprint = List<String>.generate(32, (_) => 'AB').join(':');
    final options = SecurityOptions(
      checkSigningCertificate: true,
      expectedSigningCertificateSha256: '  $fingerprint  ',
    );

    expect(options.hasValidExpectedSigningCertificateSha256, isTrue);
  });

  test('rejects missing, short, and non-hexadecimal fingerprints', () {
    expect(
      const SecurityOptions().hasValidExpectedSigningCertificateSha256,
      isFalse,
    );
    expect(
      const SecurityOptions(expectedSigningCertificateSha256: 'A1:B2')
          .hasValidExpectedSigningCertificateSha256,
      isFalse,
    );
    expect(
      SecurityOptions(
        expectedSigningCertificateSha256: List<String>.filled(64, 'G').join(),
      ).hasValidExpectedSigningCertificateSha256,
      isFalse,
    );
  });

  test('runtime monitoring is enabled by default for hooks and debugger', () {
    const options = SecurityOptions();

    expect(options.monitorHooks, isTrue);
    expect(options.monitorDebugger, isTrue);
    expect(options.blockOnHooks, isTrue);
    expect(options.blockOnRoot, isFalse);
  });

  test('report events are exposed as a broadcast stream', () {
    expect(FlutterTamperDetector.reports.isBroadcast, isTrue);
  });
}
