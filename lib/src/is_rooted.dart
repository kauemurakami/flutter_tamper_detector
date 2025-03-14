import 'package:flutter/services.dart';

/// Utility class to detect if the device is rooted.
///
/// This class communicates with the native platform using `MethodChannel`
/// to determine whether the current device has root access.
///
/// Example usage:
/// ```dart
/// bool isRooted = await IsRooted.check();
/// if (isRooted) {
///   print("Device is rooted.");
/// }
/// ```
class IsRooted {
  /// The method channel used for communicating with the native platform.
  static const MethodChannel _channel = MethodChannel(
    'flutter_tamper_detector',
  );

  /// Checks whether the device is rooted.
  ///
  /// Returns `true` if the device is rooted, otherwise `false`.
  ///
  /// If an error occurs while checking, it catches the exception and returns `false`.
  ///
  /// The [exitProcessIfTrue] parameter, which is `false` by default, determines whether the app should terminate the process
  /// if the device is rooted. If set to `true`, the app will attempt to terminate the process on the native side, potentially
  /// using methods like `exitProcess(0)` depending on the implementation in Kotlin/Java.
  ///
  /// [exitProcessIfTrue] helps enforce stricter security measures when detecting rooted devices, allowing the app to exit
  /// automatically in case of tampering.
  ///
  /// If the [exitProcessIfTrue] flag is set to `true`, it will be passed to the native code to trigger an exit condition.
  /// If the check fails, the method returns `false`.
  static Future<bool> check({bool exitProcessIfTrue = false}) async {
    try {
      return await _channel.invokeMethod('isRooted', {
            'exitProcessIfTrue': exitProcessIfTrue,
          }) ??
          false;
    } on PlatformException catch (e) {
      print("Failed to check root status: '${e.message}'.");
      return false;
    }
  }
}
