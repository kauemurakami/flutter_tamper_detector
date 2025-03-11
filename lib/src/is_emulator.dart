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
  static const MethodChannel _channel = MethodChannel('flutter_tamper_detector');

  /// Checks whether the app is running on an emulator.
  ///
  /// Returns `true` if the device is an emulator, otherwise `false`.
  ///
  /// If an error occurs while checking, it catches the exception and returns `false`.
  static Future<bool> check() async {
    try {
      return await _channel.invokeMethod('isEmulator') ?? false;
    } on PlatformException catch (e) {
      print("Failed to check emulator: '${e.message}'.");
      return false;
    }
  }
}
