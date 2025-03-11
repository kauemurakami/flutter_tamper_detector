import 'package:flutter/services.dart';

/// Utility class to detect if the app is being hooked by tools like Frida, Xposed, or Cydia Substrate.
///
/// This class communicates with the native platform using `MethodChannel`
/// to determine whether the application is being tampered with.
///
/// Example usage:
/// ```dart
/// bool isHooked = await IsHooked.check();
/// if (isHooked) {
///   print("Application is being hooked.");
/// }
/// ```
class IsHooked {
  /// The method channel used for communicating with the native platform.
  static const MethodChannel _channel = MethodChannel('flutter_tamper_detector');

  /// Checks whether the app is being hooked by malicious tools.
  ///
  /// Returns `true` if hooking is detected, otherwise `false`.
  ///
  /// If an error occurs while checking, it catches the exception and returns `false`.
  static Future<bool> check() async {
    try {
      return await _channel.invokeMethod('isHooked') ?? false;
    } on PlatformException catch (e) {
      print("Failed to check hooked: '${e.message}'.");
      return false;
    }
  }
}
