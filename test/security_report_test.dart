import 'package:flutter_tamper_detector/flutter_tamper_detector.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs unit tests for security report aggregation and blocking policy.
void main() {
  group('SecurityReport.evaluate', () {
    test('returns clear when no risk or error is present', () {
      final report = SecurityReport.evaluate(
        findings: const <SecurityFinding>[
          SecurityFinding(
            code: 'debugger_attached',
            category: 'debugging',
            detected: false,
            severity: SecuritySeverity.high,
            description: 'No debugger was observed.',
          ),
        ],
        isDebugBuild: false,
        shouldBlock: (_) => false,
      );
      expect(report.status, SecurityStatus.clear);
      expect(report.shouldLaunch, isTrue);
    });

    test('reports risk without blocking when policy is report-only', () {
      final report = SecurityReport.evaluate(
        findings: const <SecurityFinding>[
          SecurityFinding(
            code: 'root_or_jailbreak',
            category: 'environment',
            detected: true,
            severity: SecuritySeverity.high,
            description: 'Root indicator observed.',
          ),
        ],
        isDebugBuild: false,
        shouldBlock: (_) => false,
      );
      expect(report.status, SecurityStatus.riskDetected);
      expect(report.shouldLaunch, isTrue);
    });

    test('blocks when policy marks a finding as blocking', () {
      final report = SecurityReport.evaluate(
        findings: const <SecurityFinding>[
          SecurityFinding(
            code: 'instrumentation_detected',
            category: 'instrumentation',
            detected: true,
            severity: SecuritySeverity.critical,
            description: 'Instrumentation indicator observed.',
          ),
        ],
        isDebugBuild: false,
        shouldBlock: (_) => true,
      );
      expect(report.status, SecurityStatus.riskDetected);
      expect(report.shouldLaunch, isFalse);
    });


    test('returns inconclusive when a requested platform check is unsupported', () {
      final report = SecurityReport.evaluate(
        findings: const <SecurityFinding>[
          SecurityFinding(
            code: 'developer_options_enabled',
            category: 'device_settings',
            detected: false,
            severity: SecuritySeverity.info,
            description: 'No public iOS equivalent exists.',
            supported: false,
          ),
        ],
        isDebugBuild: false,
        shouldBlock: (_) => false,
      );
      expect(report.status, SecurityStatus.inconclusive);
      expect(report.shouldLaunch, isTrue);
    });

    test('supports fail-closed policy for inconclusive inspections', () {
      final report = SecurityReport.evaluate(
        findings: const <SecurityFinding>[],
        isDebugBuild: false,
        errors: const <String>['Native check unavailable.'],
        shouldBlock: (_) => false,
        blockOnInconclusive: true,
      );
      expect(report.status, SecurityStatus.inconclusive);
      expect(report.shouldLaunch, isFalse);
    });
  });
}
