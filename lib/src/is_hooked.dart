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
  static const MethodChannel _channel = MethodChannel(
    'flutter_tamper_detector',
  );

  /// Checks whether the app is being hooked by malicious tools.
  ///
  /// Returns `true` if hooking is detected, otherwise `false`.
  ///
  /// If an error occurs while checking, it catches the exception and returns `false`.
  ///
  /// The [exitProcessIfTrue] parameter, which defaults to `false`, determines whether the app should terminate the process
  /// if hooking is detected. If set to `true`, the app will attempt to terminate the process on the native side, potentially
  /// using methods like `exitProcess(0)` depending on the implementation in Kotlin/Java.
  ///
  /// The [uninstallIfTrue] parameter, which also defaults to `false`, determines whether the app should attempt to automatically
  /// uninstall itself if hooking is detected. If set to `true`, the app will try to uninstall via root access. If root
  /// uninstallation fails, a standard uninstall prompt will be shown to the user.
  ///
  /// Using [uninstallIfTrue] and [exitProcessIfTrue] simultaneously provides a more aggressive approach to mitigate potential
  /// tampering or reverse-engineering attempts, ensuring stricter security.
  ///
  /// If both flags are set to `true`, the app will prioritize attempting uninstallation before terminating the process.
  ///
  /// If the check fails, the method returns `false`.
  static Future<bool> check({
    bool exitProcessIfTrue = false,
    bool uninstallIfTrue = false,
  }) async {
    try {
      return await _channel.invokeMethod('isHooked', {
            'exitProcessIfTrue': exitProcessIfTrue,
            'uninstallIfTrue': uninstallIfTrue,
          }) ??
          false;
    } on PlatformException catch (e) {
      print("Failed to check hooked: '${e.message}'.");
      return false;
    }
  }
}
