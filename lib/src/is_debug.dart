import 'dart:io';
import 'package:flutter/services.dart';

/// Verify if:
/// - In **Android** -> Checks if running in **debug mode** via Java/Kotlin runtime state engine.
/// - In **iOS** -> Checks if running in **debug mode** via low-level kernel tracing validation (`sysctl` + `P_TRACED`).
///
/// **Note:** The only function visible and available to the user in the Dart
/// layer is [isDebug] (accessed via `IsDebug.check()`), which unifies
/// the platform-specific debugging environment checks under the hood.
///
/// Example usage:
/// ```dart
/// bool isDebug = await IsDebug.check();
/// if (isDebug) {
///   print("Running in debug mode.");
/// }
/// ```
class IsDebug {
  /// The method channel used for communicating with the native platforms.
  static const MethodChannel _channel = MethodChannel(
    'flutter_tamper_detector',
  );

  /// Checks whether the app is running in debug mode or has a debugger attached.
  ///
  /// Returns `true` if the app is in debug mode, otherwise `false`.
  ///
  /// If an error occurs while checking, it catches the exception and returns `false`.
  ///
  /// The [exitProcessIfTrue] parameter, which defaults to `false`, determines whether the app should terminate the process
  /// if debug mode is detected. If set to `true`, the app will attempt to terminate the process on the native side.
  ///
  /// [exitProcessIfTrue] allows the app to take strict security measures when debug mode is detected, helping protect
  /// against reverse engineering or unauthorized testing of the app.
  static Future<bool> check({bool exitProcessIfTrue = false}) async {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        // Both platforms share 'isDebug' method call names natively
        return await _channel.invokeMethod('isDebug', {
              'exitProcessIfTrue': exitProcessIfTrue,
            }) ??
            false;
      }
      return false;
    } on PlatformException catch (e) {
      print("Failed to check debug mode: '${e.message}'.");
      return false;
    }
  }
}
