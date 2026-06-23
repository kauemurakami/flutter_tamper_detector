import 'dart:io';
import 'package:flutter/services.dart';

/// Verify if:
/// - In **Android** -> Protects the window using `FLAG_SECURE` (blocks screen actions) and `FLAG_FULLSCREEN` settings.
/// - In **iOS** -> Masks App Switcher via `UIBlurEffect` layout overlay and locks active screen recordings using `UIScreen.main.isCaptured`.
///
/// **Note:** The only function visible and available to the user in the Dart
/// layer is [appSecuritySettings] (accessed via `AppSettingsSecurity.appSecuritySettings()`),
/// which unifies privacy window configurations under the hood.
class AppSettingsSecurity {
  /// The method channel used for communicating with the native platform.
  static const MethodChannel _channel = MethodChannel(
    'flutter_tamper_detector',
  );

  /// Configures the application window security and privacy masks.
  ///
  /// This method allows you to enable or disable security features for the app's window framework.
  ///
  /// [preventScreenshot] (default: `true`):
  /// If set to `true`, the app will prevent snapshots and video recording routines. Uses `FLAG_SECURE` on Android,
  /// and custom secure text container filters + dynamic `isCaptured` event observers on iOS.
  ///
  /// [hideInMenu] (default: `true`):
  /// If set to `true`, the system prevents revealing sensitive data when inside the recent apps selection view.
  /// Employs system visibility flags on Android, and injects an automated `UIBlurEffect` native frame on iOS.
  static Future<bool> appSecuritySettings({
    bool preventScreenshot = true,
    bool hideInMenu = true,
  }) async {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        final bool result =
            await _channel.invokeMethod('setAppPrivacy', {
              'preventScreenshot': preventScreenshot,
              'hideInMenu': hideInMenu,
            }) ??
            false;
        return result;
      }
      return false;
    } on PlatformException catch (e) {
      print("Failed to apply app security settings: '${e.message}'");
      return false;
    }
  }
}
