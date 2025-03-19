import 'package:flutter/services.dart';

/// A class to handle app security settings by communicating with the native platform.
///
/// This class provides methods to modify the app's security behavior, such as preventing screenshots
/// and hiding the app from the recent apps menu, by interacting with the native platform through
/// a method channel.
class AppSettingsSecurity {
  /// The method channel used for communicating with the native platform.
  static const MethodChannel _channel = MethodChannel('flutter_tamper_detector');

  /// Configures the app's security settings.
  ///
  /// This method allows you to enable or disable security features for the app's window.
  ///
  /// [preventScreenshot] (default: `false`):
  /// If set to `true`, the app will prevent screenshots and screen recording by enabling the `FLAG_SECURE` flag.
  /// If set to `false`, screenshots and screen recording will be allowed.
  ///
  /// [hideInMenu] (default: `false`):
  /// If set to `true`, the app will be hidden from the recent apps menu by enabling the `FLAG_FULLSCREEN` flag.
  /// If set to `false`, the app will appear in the recent apps menu.
  ///
  static Future<bool> appSecuritySettings({bool preventScreenshot = true, bool hideInMenu = true}) async {
    try {
      final bool result =
          await _channel.invokeMethod('setAppPrivacy', {
            'preventScreenshot': preventScreenshot,
            'hideInMenu': hideInMenu,
          }) ??
          false;
      return result;
    } on PlatformException catch (e) {
      print("Failed to apply app security settings: '${e.message}'");
      return false;
    }
  }
}
