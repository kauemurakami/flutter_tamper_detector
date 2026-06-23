import 'dart:io';
import 'package:flutter/services.dart';

/// Verify if:
/// - In **Android** -> Checks if running processes use a **hook framework** (Frida/Xposed) looking at open ports and memory maps.
/// - In **iOS** -> Checks if running processes contain **injected dynamic libraries** (via Mach-O dyld image analysis).
///
/// **Note:** The only function visible and available to the user in the Dart
/// layer is [isHooked] (accessed via `IsHooked.check()`), which unifies
/// the platform-specific hook engine validations under the hood.
///
/// Example usage:
/// ```dart
/// bool isHooked = await IsHooked.check();
/// if (isHooked) {
///   print("An active hooking framework was detected.");
/// }
/// ```
class IsHooked {
  /// The method channel used for communicating with the native platforms.
  static const MethodChannel _channel = MethodChannel(
    'flutter_tamper_detector',
  );

  /// Checks whether the application is being targeted or altered by runtime hooking engines.
  ///
  /// Returns `true` if runtime indicators point to external inspection systems (Frida,
  /// Objection, Xposed, or Cydia Substrate), otherwise returns `false`.
  ///
  /// If an unhandled platform exception occurs during communication, the error
  /// is caught and this method returns `false`.
  ///
  /// The [exitProcessIfTrue] parameter (defaults to `false`) determines whether
  /// the native side should immediately terminate the application process if
  /// an active hook is verified.
  ///
  /// The [uninstallIfTrue] parameter (defaults to `false`) triggers a defensive
  /// fallback response: requests an application wipe dialog on Android, or pushes the
  /// client to the App Settings pane before executing a native kill switch on iOS.
  static Future<bool> check({
    bool exitProcessIfTrue = false,
    bool uninstallIfTrue = false,
  }) async {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        // Both platforms share 'isHooked' method call names natively
        return await _channel.invokeMethod('isHooked', {
              'exitProcessIfTrue': exitProcessIfTrue,
              'uninstallIfTrue': uninstallIfTrue,
            }) ??
            false;
      }
      return false;
    } on PlatformException catch (e) {
      print("Failed to check hooking state: '${e.message}'.");
      return false;
    }
  }
}
