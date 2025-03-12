package com.deebx.flutter_tamper_detector

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlin.system.exitProcess

/** FlutterTamperDetectorPlugin */
class FlutterTamperDetectorPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_tamper_detector")
    channel.setMethodCallHandler(this)
  }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "isRooted" -> {
                val isRooted = RootChecker.isDeviceRooted()
                handleExitCondition(call, isRooted)
                result.success(isRooted)
            }
            "isHooked" -> {
                val isHooked = HookDetector.check()
                handleExitCondition(call, isHooked)
                result.success(isHooked)
            }
            "isEmulator" -> {
                val isEmulator = IsEmulator.check()
                handleExitCondition(call, isEmulator)
                result.success(isEmulator)
            }
            else -> result.notImplemented()
        }
    }
 private fun handleExitCondition(call: MethodCall, shouldExit: Boolean) {
    val exitProcessIfTrue = call.argument<Boolean>("exitProcessIfTrue") ?: false

    if (exitProcessIfTrue && shouldExit) {
        exitProcess(0)
    }
}
  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
