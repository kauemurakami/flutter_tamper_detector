import Flutter
import UIKit

/// Bridges Dart security requests to the native iOS security implementation.
public class FlutterTamperDetectorPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_tamper_detector",
            binaryMessenger: registrar.messenger()
        )
        let instance = FlutterTamperDetectorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "runSecurityChecks":
            DispatchQueue.global(qos: .userInitiated).async {
                let report = self.runSecurityChecks(arguments)
                DispatchQueue.main.async { result(report) }
            }
        case "setAppPrivacy":
            let preventScreenshot = arguments["preventScreenshot"] as? Bool ?? false
            let hideInMenu = arguments["hideInMenu"] as? Bool ?? false
            DispatchQueue.main.async {
                AppPrivacyWindow.shared.configure(
                    preventScreenshot: preventScreenshot,
                    hideInMenu: hideInMenu
                )
                result(true)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func runSecurityChecks(_ options: [String: Any]) -> [String: Any] {
        var findings: [[String: Any]] = []
        var errors: [String] = []
        func enabled(_ key: String) -> Bool { options[key] as? Bool ?? false }
        func add(_ code: String, _ category: String, _ detected: Bool,
                 _ severity: String, _ description: String, supported: Bool = true) {
            findings.append([
                "code": code, "category": category, "detected": detected,
                "severity": severity, "description": description, "supported": supported
            ])
        }

        if enabled("checkRoot") {
            add("root_or_jailbreak", "environment", IsJailbreak.check(), "high",
                "Jailbreak indicators were observed.")
        }
        if enabled("checkModifiedSystem") {
            add("modified_system", "environment", false, "info",
                "A generic modified-system check is not available on iOS.", supported: false)
        }
        if enabled("checkEmulator") {
            add("emulator_or_simulator", "environment", IsSimulator.check(), "low",
                "The app is running in the iOS Simulator.")
        }
        if enabled("checkHooks") {
            add("instrumentation_detected", "instrumentation", IsHooked.check(), "high",
                "Known injected dynamic-library indicators were observed.", supported: IsHooked.isSupported)
        }
        if enabled("checkDebugger") {
            add("debugger_attached", "debugging", IsDebug.isDebuggerAttached(), "high",
                "A native debugger appears to be attached to the process.", supported: IsDebug.isSupported)
        }
        if enabled("checkDeveloperOptions") {
            add("developer_options_enabled", "device_settings", false, "info",
                "iOS does not expose a public API for a general developer-options state.", supported: false)
        }
        if enabled("checkInstaller") {
            let hasReceipt = IsInstalledFromAppStore.hasReceipt()
            add("untrusted_installer", "distribution", !hasReceipt, "medium",
                "An App Store receipt was not found. Receipt presence alone is not cryptographic attestation.")
        }
        if enabled("checkSigningCertificate") {
            add("signing_certificate_mismatch", "integrity", false, "info",
                "Local iOS signing-certificate fingerprint verification is not implemented; use server-validated App Attest.", supported: false)
        }
        return [
            "findings": findings,
            "errors": errors
        ]
    }
}
