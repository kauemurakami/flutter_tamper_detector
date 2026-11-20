package com.deebx.flutter_tamper_detector

import android.app.Activity
import android.content.Context
import android.os.Build
import android.os.Debug
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.util.concurrent.Executors

/** Registers the Flutter channel and dispatches native security inspections. */
class FlutterTamperDetectorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private var preventScreenshotEnabled = false
    private var hideInMenuEnabled = false
    private var privacyConfigured = false
    private val securityExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "flutter_tamper_detector")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "runSecurityChecks" -> {
                val options = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
                securityExecutor.execute {
                    try {
                        val response = runSecurityChecks(options)
                        mainHandler.post { result.success(response) }
                    } catch (_: Exception) {
                        mainHandler.post {
                            result.error("INSPECTION_FAILED", "Native security inspection failed.", null)
                        }
                    }
                }
            }
            "setAppPrivacy" -> {
                val prevent = call.argument<Boolean>("preventScreenshot") ?: false
                val hide = call.argument<Boolean>("hideInMenu") ?: false
                preventScreenshotEnabled = prevent
                hideInMenuEnabled = hide
                privacyConfigured = true
                val currentActivity = activity
                if (currentActivity == null) {
                    result.error("NO_ACTIVITY", "A foreground Activity is required to configure window privacy.", null)
                } else {
                    currentActivity.runOnUiThread {
                        AppPrivacy.configure(currentActivity, prevent, hide)
                        result.success(true)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun runSecurityChecks(options: Map<*, *>): Map<String, Any> {
        val findings = mutableListOf<Map<String, Any>>()
        val errors = mutableListOf<String>()
        fun enabled(key: String) = options[key] as? Boolean ?: false
        fun add(code: String, category: String, detected: Boolean, severity: String, description: String, supported: Boolean = true) {
            findings += mapOf(
                "code" to code, "category" to category, "detected" to detected,
                "severity" to severity, "description" to description, "supported" to supported
            )
        }
        fun check(label: String, block: () -> Unit) {
            try { block() } catch (_: Exception) { errors += "$label check could not be completed." }
        }

        if (enabled("checkRoot")) check("root") {
            add("root_or_jailbreak", "environment", RootChecker.isDeviceRooted(), "high", "Root indicators were observed.")
        }
        if (enabled("checkModifiedSystem")) check("modified_system") {
            add("modified_system", "environment", SystemPropsChecker.isModifiedSystem(), "medium", "Build or verified-boot indicators suggest a modified system.")
        }
        if (enabled("checkEmulator")) check("emulator") {
            add("emulator_or_simulator", "environment", IsEmulator.check(), "low", "The runtime appears to be an emulator.")
        }
        if (enabled("checkHooks")) check("instrumentation") {
            val inspection = HookDetector.inspect()
            add("instrumentation_detected", "instrumentation", inspection.processIndicatorDetected, "high", "Process-level instrumentation indicators were observed.", supported = inspection.processInspectionSupported)
            add("instrumentation_port_detected", "instrumentation", inspection.knownPortOpen, "medium", "A common Frida TCP port is accepting local connections; this is not proof of Frida.")
        }
        if (enabled("checkDebugger")) check("debugger") {
            add("debugger_attached", "debugging", Debug.isDebuggerConnected() || Debug.waitingForDebugger(), "high", "A native debugger is attached or the process is waiting for one.")
        }
        if (enabled("checkDeveloperOptions")) check("developer_options") {
            val developerOptions = Settings.Global.getInt(context.contentResolver, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) == 1
            val adbEnabled = Settings.Global.getInt(context.contentResolver, Settings.Global.ADB_ENABLED, 0) == 1
            add("developer_options_enabled", "device_settings", developerOptions || adbEnabled, "info", "Developer options or USB debugging are enabled.")
        }
        if (enabled("checkInstaller")) check("installer") {
            val installer = InstallSource.check(context)
            add("untrusted_installer", "distribution", !installer, "medium", "The initiating installer is not Google Play or could not be verified.")
        }
        if (enabled("checkSigningCertificate")) check("signature") {
            val expected = (options["expectedSigningCertificateSha256"] as? String).orEmpty()
            val actual = SigningCertificate.sha256(context)
            val normalizedExpected = expected.replace(":", "").filterNot { it.isWhitespace() }.uppercase()
            val validFormat = normalizedExpected.matches(Regex("[0-9A-F]{64}"))
            val supported = validFormat && actual != null
            val mismatch = supported && actual != normalizedExpected
            add("signing_certificate_mismatch", "integrity", mismatch, "critical", "The signing certificate does not match the configured SHA-256 fingerprint.", supported = supported)
        }
        return mapOf("findings" to findings, "errors" to errors)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        if (privacyConfigured) {
            binding.activity.runOnUiThread {
                AppPrivacy.configure(binding.activity, preventScreenshotEnabled, hideInMenuEnabled)
            }
        }
    }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        if (privacyConfigured) {
            binding.activity.runOnUiThread {
                AppPrivacy.configure(binding.activity, preventScreenshotEnabled, hideInMenuEnabled)
            }
        }
    }
    override fun onDetachedFromActivity() { activity = null }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        securityExecutor.shutdownNow()
    }
}

private object InstallSource {
    @Suppress("DEPRECATION")
    fun check(context: Context): Boolean = try {
        val manager = context.packageManager
        val installer = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            manager.getInstallSourceInfo(context.packageName).installingPackageName
        } else {
            // Deprecated since API 30; retained only for older Android versions.
            manager.getInstallerPackageName(context.packageName)
        }
        installer == "com.android.vending"
    } catch (_: Exception) { false }
}

private object SigningCertificate {
    @Suppress("DEPRECATION")
    fun sha256(context: Context): String? {
      return try {
        val manager = context.packageManager
        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            manager.getPackageInfo(context.packageName, android.content.pm.PackageManager.GET_SIGNING_CERTIFICATES)
        } else {
            manager.getPackageInfo(context.packageName, android.content.pm.PackageManager.GET_SIGNATURES)
        }
        val signature = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val signingInfo = packageInfo.signingInfo ?: return null
            if (signingInfo.hasMultipleSigners()) {
                signingInfo.apkContentsSigners.firstOrNull()
            } else {
                signingInfo.signingCertificateHistory?.lastOrNull()
            }
        } else {
            packageInfo.signatures?.firstOrNull()
        }
        val certificate = signature?.toByteArray() ?: return null
        MessageDigest.getInstance("SHA-256").digest(certificate).joinToString("") { (it.toInt() and 0xff).toString(16).padStart(2, '0').uppercase() }
      } catch (_: Exception) { null }
    }
}
