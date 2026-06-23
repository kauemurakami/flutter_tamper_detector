import 'dart:io';
import 'package:flutter/services.dart';

/// Verify if:
/// - In **Android** -> Checks if the device has **root** access.
/// - In **iOS** -> Checks if the device has a **jailbreak**.
///
/// **Note:** The only function visible and available to the user in the Dart
/// layer is [isRooted] (accessed via `IsRooted.check()`), which unifies
/// the platform-specific security checks under the hood.
///
/// Example usage:
/// ```dart
/// bool isCompromised = await IsRooted.check();
/// if (isCompromised) {
///   print("Device is compromised (Rooted or Jailbroken).");
/// }
/// ```
class IsRooted {
  /// The method channel used for communicating with the native platforms.
  static const MethodChannel _channel = MethodChannel(
    'flutter_tamper_detector',
  );

  /// Checks whether the application is executing on a modified operating system.
  ///
  /// Returns `true` if the device is identified as rooted (Android) or
  /// jailbroken (iOS), otherwise returns `false`.
  ///
  /// If an unhandled platform exception occurs during communication, the error
  /// is caught and this method returns `false`.
  ///
  /// The [exitProcessIfTrue] parameter (defaults to `false`) determines whether
  /// the native side should immediately terminate the application process if
  /// a risk condition is verified.
  ///
  /// The [uninstallIfTrue] parameter (defaults to `false`) triggers a native
  /// reaction: prompts an uninstallation request on Android, or redirects the
  /// user to the App Settings menu before closing on iOS.
  static Future<bool> check({
    bool exitProcessIfTrue = false,
    bool uninstallIfTrue = false,
  }) async {
    try {
      if (Platform.isIOS) {
        // Routes to 'isJailbreak' on the Swift side
        return await _channel.invokeMethod('isJailbreak', {
              'exitProcessIfTrue': exitProcessIfTrue,
              'uninstallIfTrue': uninstallIfTrue,
            }) ??
            false;
      } else if (Platform.isAndroid) {
        // Keeps legacy behavior routing to 'isRooted' on the Kotlin side
        return await _channel.invokeMethod('isRooted', {
              'exitProcessIfTrue': exitProcessIfTrue,
              'uninstallIfTrue': uninstallIfTrue,
            }) ??
            false;
      }
      return false;
    } on PlatformException catch (e) {
      print("Failed to check root/jailbreak: '${e.message}'.");
      return false;
    }
  }
}
