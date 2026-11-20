import 'package:example/main.dart';
import 'package:flutter_tamper_detector/flutter_tamper_detector.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs widget tests for the documented example application.
void main() {
  testWidgets('renders the security dashboard for an allowed report', (tester) async {
    final report = SecurityReport(
      status: SecurityStatus.clear,
      findings: const <SecurityFinding>[],
      shouldLaunch: true,
      isDebugBuild: true,
      timestamp: DateTime.now(),
    );

    await tester.pumpWidget(TamperDetectorExample(report: report));
    expect(find.text('Flutter Tamper Detector'), findsOneWidget);
    expect(find.text('Status: clear'), findsOneWidget);
  });
}
