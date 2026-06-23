import 'dart:io';
import 'package:flutter/services.dart';

/// Verify if:
/// - In **Android** -> Checks if running on an **emulator**.
/// - In **iOS** -> Checks if running on a **simulator**.
///
/// **Note:** The only function visible and available to the user in the Dart
/// layer is [isEmulator] (accessed via `IsEmulator.check()`), which unifies
/// the platform-specific checks under the hood.
///
/// Example usage:
/// ```dart
/// bool isCompromisedEnvironment = await IsEmulator.check();
/// if (isCompromisedEnvironment) {
///   print("Running on an emulator or simulator.");
/// }
/// ```
class IsEmulator {
  /// The method channel used for communicating with the native platforms.
  static const MethodChannel _channel = MethodChannel(
    'flutter_tamper_detector',
  );

  /// Checks whether the application is executing inside a virtual environment.
  ///
  /// Returns `true` if the device is identified as an emulator (Android) or
  /// a simulator (iOS), otherwise returns `false`.
  ///
  /// If an unhandled platform exception occurs during communication, the error
  /// is caught and this method returns `false`.
  ///
  /// The [exitProcessIfTrue] parameter (defaults to `false`) determines whether
  /// the native side should immediately terminate the application process if a
  /// virtual environment is detected.
  ///
  /// Turning [exitProcessIfTrue] to `true` acts as an automated anti-tampering
  /// response layer directly managed by Kotlin (Android) or Swift (iOS).
  static Future<bool> check({bool exitProcessIfTrue = false}) async {
    try {
      if (Platform.isIOS) {
        return await _channel.invokeMethod('isSimulator', {
              'exitProcessIfTrue': exitProcessIfTrue,
            }) ??
            false;
      } else if (Platform.isAndroid) {
        return await _channel.invokeMethod('isEmulator', {
              'exitProcessIfTrue': exitProcessIfTrue,
            }) ??
            false;
      }
      return false;
    } on PlatformException catch (e) {
      print("Failed to check emulator/simulator: '${e.message}'.");
      return false;
    }
  }
}
