package com.deebx.flutter_tamper_detector

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

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
                val isRooted = RootChecker.isDeviceRooted() root
                result.success(isRooted)
            }
            "isHooked" -> {
                val hooked = HookDetector.check()
                result.success(hooked)
            }
            "isEmulator" -> {
                val isEmulator = IsEmulator.check()
                result.success(isEmulator)
            }
            else -> result.notImplemented()
        }
    }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
