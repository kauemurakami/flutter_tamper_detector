package com.deebx.flutter_tamper_detector

import android.content.Context
import android.app.Activity
import android.content.Intent
import android.net.Uri
import java.io.BufferedReader
import java.io.InputStreamReader
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
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_tamper_detector")
    channel.setMethodCallHandler(this)
     context = flutterPluginBinding.applicationContext
  }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val exitProcessIfTrue = call.argument<Boolean>("exitProcessIfTrue") ?: false
        val uninstallIfTrue = call.argument<Boolean>("uninstallIfTrue") ?: false

        when (call.method) {
            "isRooted" -> {
                val isRooted = RootChecker.isDeviceRooted()
                handleExitOrUninstall(isRooted, exitProcessIfTrue, uninstallIfTrue)
                result.success(isRooted)
            }
            "isHooked" -> {
                val isHooked = HookDetector.check()
                handleExitOrUninstall(isHooked, exitProcessIfTrue, uninstallIfTrue)
                result.success(isHooked)
            }
            "isEmulator" -> {
                val isEmulator = IsEmulator.check()
                handleExitOrUninstall(isEmulator, exitProcessIfTrue, false)
                result.success(isEmulator)
            }
            "isDebug" -> {
                val isDebug = IsDebug.check(context)
                handleExitOrUninstall(isDebug, exitProcessIfTrue, false)
                result.success(isDebug)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleExitOrUninstall(shouldExit: Boolean, exitProcessIfTrue: Boolean, uninstallIfTrue: Boolean) {
        if (uninstallIfTrue && shouldExit) {
            uninstallApp()
        }
        if (exitProcessIfTrue && shouldExit) {
            exitProcess(0)
        }
    }
    // private fun handleExitCondition(call: MethodCall, shouldExit: Boolean) {
    //     val exitProcessIfTrue = call.argument<Boolean>("exitProcessIfTrue") ?: false

    //     if (exitProcessIfTrue && shouldExit) {
    //         exitProcess(0)
    //     }
    // }

    private fun uninstallApp() {
        try {
            // Tentativa de desinstalação via root (comando "su")
            val packageName = context.packageName
            val process = Runtime.getRuntime().exec("su")
            val outputStream = process.outputStream
            outputStream.write("pm uninstall $packageName\n".toByteArray())
            outputStream.flush()
            outputStream.close()

            // Verificar o resultado da desinstalação
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val result = reader.readLine()
            reader.close()


            // Se a desinstalação via root falhar, tenta desinstalar normalmente
            if (result == null || !result.contains("Success")) {
                val intent = Intent(Intent.ACTION_DELETE)
                intent.data = Uri.parse("package:$packageName")
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
            }
        } catch (e: Exception) {
            e
        }
    }
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
