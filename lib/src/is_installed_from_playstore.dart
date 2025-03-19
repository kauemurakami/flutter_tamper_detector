import 'package:flutter/services.dart';

/// Utility class to detect if the app was installed from the Play Store.
/// This class communicates with the native platform using `MethodChannel`
/// to determine whether the app was installed via the Google Play Store.
///
/// Example usage:
/// ```dart
/// bool isInstalled = await IsInstalledFromPlaystore.check();
/// if (isInstalled) {
///   print("App was installed from the Play Store.");
/// }
/// ```
class IsInstalledFromPlaystore {
  /// The method channel used for communicating with the native platform.
  static const MethodChannel _channel = MethodChannel(
    'flutter_tamper_detector',
  );

  /// Checks whether the app was installed from the Play Store.
  ///
  /// Returns `true` if the app was installed from the Play Store, otherwise `false`.
  ///
  /// If an error occurs while checking, it catches the exception and returns `false`.
  ///
  /// The [exitProcessIfTrue] parameter, which defaults to `false`, determines whether the app should terminate the process
  /// if it is not installed from the Play Store. If set to `true`, the app will attempt to terminate the process on the native side,
  /// potentially using methods like `exitProcess(0)` depending on the implementation in Kotlin/Java.
  ///
  /// [exitProcessIfTrue] allows the app to enforce stricter security measures if it is not installed from the Play Store,
  /// helping protect against unauthorized installations from unofficial sources.
  ///
  /// If the [exitProcessIfTrue] flag is set to `true`, it will be passed to the native code to trigger an exit condition.
  /// If the check fails, the method returns `false`.
  static Future<bool> check({bool exitProcessIfFalse = false}) async {
    try {
      return await _channel.invokeMethod('isInstalledFromPlayStore', {
            'exitProcessIfTrue': exitProcessIfFalse,
          }) ??
          false;
    } on PlatformException catch (e) {
      print("Failed to check installation source: '${e.message}'");
      return false;
    }
  }
}
