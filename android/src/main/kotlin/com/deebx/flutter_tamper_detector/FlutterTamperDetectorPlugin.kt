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
            // Verifica se o dispositivo está rooteado
            "isRooted" -> {
                val isRooted = RootChecker.isDeviceRooted() // Chama a função que verifica o root
                result.success(isRooted) // Retorna true ou false para o Flutter
            }
            // Verifica se o dispositivo está hookeado
            "isHooked" -> {
                val hooked = HookDetector.check()
                result.success(hooked)
            }
            // Verifica se o dispositivo é um emulador
            "isEmulator" -> {
                val isEmulator = IsEmulator.check()
                result.success(isEmulator)
            }
            else -> result.notImplemented() // Caso o método não seja implementado
        }
    }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
