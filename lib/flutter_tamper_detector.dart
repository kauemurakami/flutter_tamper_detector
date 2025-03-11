import './src/is_emulator.dart';
import './src/is_rooted.dart';
import './src/is_hooked.dart';

/// A security utility for detecting potential tampering with the Flutter application.
///
/// `FlutterTamperDetector` provides methods to check if the device is:
/// - **Rooted**: Detects if the device has root access.
/// - **Hooked**: Identifies the presence of hooking frameworks like Frida, Xposed, or Cydia Substrate.
/// - **Running on an Emulator**: Determines if the app is being executed in an emulated environment.
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
  /// Checks if the app is running on an emulator.
  ///
  /// Returns `true` if the device is an emulator, otherwise `false`.
  static Future<bool> isEmulator() => IsEmulator.check();

  /// Checks if the device is rooted.
  ///
  /// Returns `true` if the device has root access, otherwise `false`.
  static Future<bool> isRooted() => IsRooted.check();

  /// Checks if the app is being hooked by a tool like Frida, Xposed, or Cydia Substrate.
  ///
  /// Returns `true` if any hooking framework is detected, otherwise `false`.
  static Future<bool> isHooked() => IsHooked.check();
}
