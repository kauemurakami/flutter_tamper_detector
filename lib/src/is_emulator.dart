import 'package:flutter/services.dart';

/// Utility class to detect if the app is running on an emulator.
///
/// This class communicates with the native platform using `MethodChannel`
/// to determine whether the current device is an emulator.
///
/// Example usage:
/// ```dart
/// bool isEmulator = await IsEmulator.check();
/// if (isEmulator) {
///   print("Running on an emulator.");
/// }
/// ```
class IsEmulator {
  /// The method channel used for communicating with the native platform.
  static const MethodChannel _channel = MethodChannel(
    'flutter_tamper_detector',
  );

  /// Checks whether the app is running on an emulator.
  ///
  /// Returns `true` if the device is an emulator, otherwise `false`.
  ///
  /// If an error occurs while checking, it catches the exception and returns `false`.
  ///
  /// The [exitProcessIfTrue] parameter, which defaults to `false`, determines whether the app should terminate the process
  /// if an emulator is detected. If set to `true`, the app will attempt to terminate the process on the native side,
  /// potentially using methods like `exitProcess(0)` depending on the implementation in Kotlin/Java.
  ///
  /// [exitProcessIfTrue] allows the app to take strict security measures when an emulator is detected, helping protect
  /// against reverse engineering or unauthorized testing of the app.
  ///
  /// If the [exitProcessIfTrue] flag is set to `true`, it will be passed to the native code to trigger an exit condition.
  /// If the check fails, the method returns `false`.
  static Future<bool> check({bool exitProcessIfTrue = false}) async {
    try {
      return await _channel.invokeMethod('isEmulator', {
            'exitProcessIfTrue': exitProcessIfTrue,
          }) ??
          false;
    } on PlatformException catch (e) {
      print("Failed to check emulator: '${e.message}'.");
      return false;
    }
  }
}
