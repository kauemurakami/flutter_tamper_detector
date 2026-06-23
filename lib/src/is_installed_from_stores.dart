import 'dart:io';
import 'package:flutter/services.dart';

/// Verify if:
/// - In **Android** -> Checks if the application package installer origins from the **Google Play Store**.
/// - In **iOS** -> Checks if the installation contains a cryptographically valid **App Store or TestFlight receipt**.
///
/// **Note:** The only function visible and available to the user in the Dart
/// layer is [IsInstalledFromStores] (accessed via `IsInstalledFromStores.check()`),
/// which unifies market validation strategies under the hood.
///
/// Example usage:
/// ```dart
/// bool isOfficial = await IsInstalledFromStores.check();
/// if (isOfficial) {
///   print("App was installed from an official store source.");
/// }
/// ```
class IsInstalledFromStores {
  /// The method channel used for communicating with the native platforms.
  static const MethodChannel _channel = MethodChannel(
    'flutter_tamper_detector',
  );

  /// Checks whether the app was installed from an official market source.
  ///
  /// Returns `true` if the app package traces back to the Google Play Store (Android)
  /// or contains active production/sandbox receipts from Apple (iOS), otherwise `false`.
  ///
  /// If an error occurs while checking, it catches the exception and returns `false`.
  ///
  /// The [exitProcessIfFalse] parameter, which defaults to `false`, determines whether the app should terminate the process
  /// if it is not installed from an official store. If set to `true`, the app will attempt to terminate the process on the native side.
  ///
  /// [exitProcessIfFalse] allows the app to enforce stricter security measures if it is not installed from official channels,
  /// helping protect against unauthorized installations or repackaged clones.
  static Future<bool> check({bool exitProcessIfFalse = false}) async {
    try {
      if (Platform.isIOS) {
        // Routes to 'isInstalledFromAppStore' on the Swift side
        return await _channel.invokeMethod('isInstalledFromAppStore', {
              'exitProcessIfTrue': exitProcessIfFalse,
            }) ??
            false;
      } else if (Platform.isAndroid) {
        // Keeps legacy behavior routing to 'isInstalledFromPlayStore' on the Kotlin side
        return await _channel.invokeMethod('isInstalledFromPlayStore', {
              'exitProcessIfTrue': exitProcessIfFalse,
            }) ??
            false;
      }
      return false;
    } on PlatformException catch (e) {
      print("Failed to check installation source: '${e.message}'");
      return false;
    }
  }
}
