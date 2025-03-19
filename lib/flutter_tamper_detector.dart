import 'package:flutter_tamper_detector/src/app_privacy.dart';

import './src/is_emulator.dart';
import './src/is_rooted.dart';
import './src/is_hooked.dart';
import './src/is_debug.dart';
import './src/is_installed_from_playstore.dart'; // Adicionei a importação do novo arquivo

/// A security utility for detecting potential tampering with the Flutter application.
///
/// `FlutterTamperDetector` provides methods to check if the device is:
/// - **Rooted**: Detects if the device has root access.
/// - **Hooked**: Identifies the presence of hooking frameworks like Frida, Xposed, or Cydia Substrate.
/// - **Running on an Emulator**: Determines if the app is being executed in an emulated environment.
/// - **Running in Debug mode**: Determines if the app is being executed in a debug mode.
/// - **Installed from Play Store**: Verifies if the app was installed from the Play Store.
/// - **Privacy Settings**: Allows setting privacy options for hiding the app in the menu and preventing screenshots.
///
/// This allows you to implement security measures, such as preventing execution on compromised devices.
///
/// Example:
/// ```dart
/// bool isRooted = await FlutterTamperDetector().isRooted();
/// if (isRooted) {
///   exit(0); // Terminate the app if the device is rooted.
/// }
/// ```
class FlutterTamperDetector {
  /// Configures the app's security settings.
  ///
  /// This method allows you to enable or disable security features for the app's window.
  ///
  /// [hideInMenu] (default: `true`):
  /// If set to `true`, the app will be hidden from the recent apps menu by enabling the `FLAG_FULLSCREEN` flag.
  /// If set to `false`, the app will appear in the recent apps menu.
  ///
  /// [preventScreenshot] (default: `true`):
  /// If set to `true`, the app will prevent screenshots and screen recording by enabling the `FLAG_SECURE` flag.
  /// If set to `false`, screenshots and screen recording will be allowed.
  ///
  static Future<bool> appSecuritySettings({hideInMenu = true, preventScreenshot = true}) async =>
      await AppSettingsSecurity.appSecuritySettings(hideInMenu: hideInMenu, preventScreenshot: preventScreenshot);

  /// Checks if the app is running on an emulator.
  ///
  /// Returns `true` if the device is an emulator, otherwise `false`.
  /// Optionally, if [exitProcessIfTrue] is set to `true`, the app will attempt to terminate the process if an emulator is detected.
  static Future<bool> isEmulator({bool exitProcessIfTrue = false}) =>
      IsEmulator.check(exitProcessIfTrue: exitProcessIfTrue);

  /// Checks if the device is rooted.
  ///
  /// Returns `true` if the device has root access, otherwise `false`.
  /// Optionally, if [exitProcessIfTrue] is set to `true`, the app will attempt to terminate the process if the device is rooted.
  static Future<bool> isRooted({bool exitProcessIfTrue = false, bool uninstallIfTrue = false}) =>
      IsRooted.check(exitProcessIfTrue: exitProcessIfTrue, uninstallIfTrue: uninstallIfTrue);

  /// Checks if the app is being hooked by a tool like Frida, Xposed, or Cydia Substrate.
  ///
  /// Returns `true` if any hooking framework is detected, otherwise `false`.
  /// Optionally, if [exitProcessIfTrue] is set to `true`, the app will attempt to terminate the process if hooking is detected.
  static Future<bool> isHooked({bool exitProcessIfTrue = false, bool uninstallIfTrue = false}) =>
      IsHooked.check(exitProcessIfTrue: exitProcessIfTrue, uninstallIfTrue: uninstallIfTrue);

  /// Checks if the app is running in debug mode.
  ///
  /// Returns `true` if the app is running in debug mode, otherwise `false`.
  /// Optionally, if [exitProcessIfTrue] is set to `true`, the app will attempt to terminate the process if running in debug mode.
  static Future<bool> isDebug({bool exitProcessIfTrue = false}) => IsDebug.check(exitProcessIfTrue: exitProcessIfTrue);

  /// Checks if the app was installed from the Play Store.
  ///
  /// Returns `true` if the app was installed from the Play Store, otherwise `false`.
  /// Optionally, if [exitProcessIfFalse] is set to `true`, the app will attempt to terminate the process if it was not installed from the Play Store.
  static Future<bool> isInstalledFromPlaystore({bool exitProcessIfFalse = false}) =>
      IsInstalledFromPlaystore.check(exitProcessIfFalse: exitProcessIfFalse);
}
