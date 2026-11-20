import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tamper_detector/flutter_tamper_detector.dart';

/// Initializes the security policy before the example renders its first frame.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use a separate public certificate fingerprint for local Debug/Profile
  // builds and production Release builds. Supply values through --dart-define.
  const debugSigningFingerprint = String.fromEnvironment(
    'ANDROID_DEBUG_SIGNING_CERT_SHA256',
  );
  const releaseSigningFingerprint = String.fromEnvironment(
    'ANDROID_RELEASE_SIGNING_CERT_SHA256',
  );
  final signingFingerprint = kReleaseMode
      ? releaseSigningFingerprint
      : debugSigningFingerprint;

  final securityOptions = SecurityOptions(
    checkRoot: true,
    checkModifiedSystem: Platform.isAndroid,
    checkEmulator: true,
    checkHooks: true,
    checkDebugger: true,
    checkDeveloperOptions: Platform.isAndroid,
    checkInstaller: false,
    checkSigningCertificate:
        Platform.isAndroid && signingFingerprint.isNotEmpty,
    expectedSigningCertificateSha256: signingFingerprint.isEmpty
        ? null
        : signingFingerprint,
    blockOnRoot: false,
    blockOnModifiedSystem: false,
    blockOnEmulator: false,
    blockOnHooks: true,
    blockOnDebuggerInRelease: true,
    blockOnDeveloperOptions: false,
    blockOnUntrustedInstaller: false,
    blockOnInvalidSignature: true,
    blockOnInconclusive: false,
    monitorHooks: true,
    monitorDebugger: true,
    monitoringInterval: const Duration(seconds: 15),
  );

  if (securityOptions.checkSigningCertificate &&
      !securityOptions.hasValidExpectedSigningCertificateSha256) {
    developer.log(
      'The configured Android signing fingerprint is not a valid SHA-256 value.',
      name: 'example.security.configuration',
    );
  }

  final report = await FlutterTamperDetector.initialize(
    options: securityOptions,
    logger: const ExampleSecurityLogger(),
    onReport: (updatedReport) {
      developer.log(
        'Inspection completed: ${updatedReport.status.name}; '
        'launch=${updatedReport.shouldLaunch}',
        name: 'example.security.policy',
      );
    },
  );

  runApp(TamperDetectorExample(report: report));
}

/// Demonstrates how an application can forward package events to its logger.
class ExampleSecurityLogger implements SecurityLogger {
  /// Creates the example logger used by this standalone sample.
  const ExampleSecurityLogger();

  @override
  void logSecurityEvent(String event, Map<String, Object?> data) {
    // Replace this with Sentry.captureMessage, Crashlytics, or your own logger.
    // Never attach passwords, tokens, personal data, or stable device IDs.
    developer.log('$event: $data', name: 'example.security');
  }
}

/// Root widget that demonstrates startup policy and runtime inspection.
class TamperDetectorExample extends StatelessWidget {
  /// Creates the example screen with the initial security report.
  const TamperDetectorExample({super.key, required this.report});

  /// Report returned before the first frame was rendered.
  final SecurityReport report;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Tamper Detector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: report.shouldLaunch
          ? SecurityDashboard(initialReport: report)
          : SecurityBlockedScreen(report: report),
    );
  }
}

/// Shows live reports and demonstrates the package's public inspection APIs.
class SecurityDashboard extends StatefulWidget {
  /// Creates the dashboard with the startup inspection result.
  const SecurityDashboard({super.key, required this.initialReport});

  /// Initial report used to populate the dashboard.
  final SecurityReport initialReport;

  @override
  State<SecurityDashboard> createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> {
  late SecurityReport _report = widget.initialReport;
  StreamSubscription<SecurityReport>? _reportSubscription;
  final Map<String, String> _probeResults = <String, String>{};
  bool _busy = false;
  bool _preventCapture = false;
  late bool _monitoringEnabled = FlutterTamperDetector.isMonitoring;

  @override
  void initState() {
    super.initState();
    // This broadcast stream lets any screen observe reports without owning the
    // application's global monitoring lifecycle.
    _reportSubscription = FlutterTamperDetector.reports.listen((report) {
      if (!mounted) return;
      setState(() => _report = report);
    });
  }

  Future<void> _inspectAgain() async {
    setState(() => _busy = true);
    await FlutterTamperDetector.checkNow();
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _runProbe(
    String label,
    Future<bool> Function() operation, {
    bool positiveMeansTrusted = false,
  }) async {
    setState(() => _probeResults[label] = 'Checking…');
    try {
      final detected = await operation();
      if (!mounted) return;
      final positive = detected;
      setState(() {
        _probeResults[label] = positive
            ? (positiveMeansTrusted
                  ? 'Expected condition confirmed'
                  : 'Signal detected')
            : (positiveMeansTrusted
                  ? 'Expected condition not confirmed'
                  : 'No signal detected');
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(
        () => _probeResults[label] = 'Check failed: ${error.runtimeType}',
      );
    }
  }

  void _toggleMonitoring(bool enabled) {
    if (enabled) {
      FlutterTamperDetector.startMonitoring();
    } else {
      FlutterTamperDetector.stopMonitoring();
    }
    if (!mounted) return;
    setState(() => _monitoringEnabled = enabled);
  }

  Future<void> _togglePrivacy(bool enabled) async {
    final applied = await AppPrivacy.configure(
      preventScreenshot: enabled,
      obscureAppSwitcherPreview: enabled,
    );
    if (!mounted) return;
    setState(() => _preventCapture = applied && enabled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          applied
              ? 'Privacy settings updated.'
              : 'Privacy settings could not be applied on this platform/state.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    // A screen owns only its subscription. The singleton monitor belongs to
    // the application and must not be stopped when this dashboard is removed.
    unawaited(_reportSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (_report.status) {
      SecurityStatus.clear => Colors.green,
      SecurityStatus.riskDetected => Colors.orange,
      SecurityStatus.inconclusive => Colors.blueGrey,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Tamper Detector')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.shield_outlined, color: color, size: 32),
              title: Text('Status: ${_report.status.name}'),
              subtitle: Text(
                _report.shouldLaunch
                    ? 'The configured policy allows protected UI.'
                    : 'The configured policy blocks protected UI.',
              ),
              trailing: Icon(
                _report.shouldLaunch ? Icons.lock_open : Icons.lock,
                color: color,
              ),
            ),
          ),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _monitoringEnabled,
                  onChanged: _toggleMonitoring,
                  title: const Text('Runtime monitoring'),
                  subtitle: const Text(
                    'Periodic hook/debugger checks and checks on app resume.',
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: _preventCapture,
                  onChanged: _togglePrivacy,
                  title: const Text('Protect sensitive screen capture'),
                  subtitle: const Text(
                    'Android FLAG_SECURE; iOS app-switcher masking and capture signals.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Security findings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (_report.findings.isEmpty)
            const Card(
              child: ListTile(
                title: Text('No supported findings were returned.'),
                subtitle: Text(
                  'An empty report is not proof of a trusted device.',
                ),
              ),
            ),
          ..._report.findings.map(
            (finding) => Card(
              child: ListTile(
                leading: Icon(
                  finding.detected
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: finding.detected ? Colors.orange : Colors.green,
                ),
                title: Text(finding.code),
                subtitle: Text(
                  '${finding.description}\n'
                  'Severity: ${finding.severity.name} · '
                  'Supported: ${finding.supported}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
          if (_report.errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Inspection errors',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ..._report.errors.map(
              (error) => ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(error),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text('Manual checks', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text(
            'Run individual checks on demand. These methods return local signals; '
            'they do not terminate the app or replace server-side verification.',
          ),
          const SizedBox(height: 8),
          _ProbeTile(
            title: 'Root / jailbreak',
            result: _probeResults['Root / jailbreak'],
            onPressed: () =>
                _runProbe('Root / jailbreak', FlutterTamperDetector.isRooted),
          ),
          _ProbeTile(
            title: 'Emulator / simulator',
            result: _probeResults['Emulator / simulator'],
            onPressed: () => _runProbe(
              'Emulator / simulator',
              FlutterTamperDetector.isEmulator,
            ),
          ),
          if (Platform.isAndroid)
            _ProbeTile(
              title: 'Modified system',
              result: _probeResults['Modified system'],
              onPressed: () => _runProbe(
                'Modified system',
                FlutterTamperDetector.isModifiedSystem,
              ),
            ),
          _ProbeTile(
            title: 'Runtime instrumentation',
            result: _probeResults['Runtime instrumentation'],
            onPressed: () => _runProbe(
              'Runtime instrumentation',
              FlutterTamperDetector.isHooked,
            ),
          ),
          _ProbeTile(
            title: 'Native debugger',
            result: _probeResults['Native debugger'],
            onPressed: () => _runProbe(
              'Native debugger',
              FlutterTamperDetector.isDebuggerAttached,
            ),
          ),
          if (Platform.isAndroid)
            _ProbeTile(
              title: 'Developer options / ADB',
              result: _probeResults['Developer options / ADB'],
              onPressed: () => _runProbe(
                'Developer options / ADB',
                FlutterTamperDetector.isDeveloperOptionsEnabled,
              ),
            ),
          _ProbeTile(
            title: 'Store / receipt indicator',
            result: _probeResults['Store / receipt indicator'],
            onPressed: () => _runProbe(
              'Store / receipt indicator',
              FlutterTamperDetector.isInstalledFromStore,
              positiveMeansTrusted: true,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _inspectAgain,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: const Text('Run complete security inspection'),
          ),
          const SizedBox(height: 16),
          Text(
            'Integration notes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Use shouldLaunch to decide which UI or protected features are '
            'available. Send sanitized reports to your logger, and validate '
            'Play Integrity / App Attest proofs on your backend for sensitive actions.',
          ),
          const SizedBox(height: 8),
          Text(
            'Last report: ${_report.timestamp.toLocal()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Renders an individual on-demand security check and its latest result.
class _ProbeTile extends StatelessWidget {
  const _ProbeTile({
    required this.title,
    required this.result,
    required this.onPressed,
  });

  final String title;
  final String? result;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(result ?? 'Not run yet'),
        trailing: IconButton(
          tooltip: 'Run $title check',
          onPressed: onPressed,
          icon: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}

/// Displays a customizable example screen when the configured policy blocks.
class SecurityBlockedScreen extends StatelessWidget {
  /// Creates the blocked screen with the report that caused the decision.
  const SecurityBlockedScreen({super.key, required this.report});

  /// Security report used to explain the startup decision.
  final SecurityReport report;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.gpp_bad_outlined, size: 56),
            const SizedBox(height: 16),
            Text(
              'Access restricted',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The application security policy did not allow protected UI '
              'to start. This is an example screen; replace it with your '
              'own support, recovery, or verification flow.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text('Status: ${report.status.name}'),
            for (final finding in report.findings.where(
              (item) => item.detected,
            ))
              ListTile(
                dense: true,
                title: Text(finding.code),
                subtitle: Text(finding.description),
              ),
          ],
        ),
      ),
    ),
  );
}
