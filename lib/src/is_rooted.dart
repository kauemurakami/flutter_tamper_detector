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
  static const MethodChannel _channel = MethodChannel('flutter_tamper_detector');

  /// Checks whether the device is rooted.
  ///
  /// Returns `true` if the device is rooted, otherwise `false`.
  ///
  /// If an error occurs while checking, it catches the exception and returns `false`.
  static Future<bool> check() async {
    try {
      return await _channel.invokeMethod('isRooted') ?? false;
    } on PlatformException catch (e) {
      print("Failed to check root status: '${e.message}'.");
      return false;
    }
  }
}
