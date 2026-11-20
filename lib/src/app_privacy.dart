import 'package:flutter/services.dart';

/// Applies platform-specific privacy protections to the application window.
class AppPrivacy {
  static const MethodChannel _channel = MethodChannel(
    'flutter_tamper_detector',
  );

  /// Configures screenshot/capture protection and app-switcher preview masking.
  ///
  /// On Android, either option enables `FLAG_SECURE`, which blocks screenshots
  /// and screen recording and obscures the recent-apps thumbnail. Android does
  /// not provide a general API to remove an app from the Recents list.
  ///
  /// On iOS, screenshots cannot be reliably prevented by third-party apps.
  /// The plugin can obscure the app-switcher snapshot and react to active
  /// screen capture, but capture notifications may arrive after a screenshot.
  ///
  /// [preventScreenshot] enables the strongest supported capture protection.
  /// [obscureAppSwitcherPreview] masks sensitive content when the app backgrounds.
  /// [hideInMenu] is a deprecated compatibility alias for the preview option.
  ///
  /// Returns `true` when the native platform accepted the configuration.
  static Future<bool> configure({
    bool preventScreenshot = false,
    bool obscureAppSwitcherPreview = false,
    @Deprecated('Use obscureAppSwitcherPreview instead.') bool? hideInMenu,
  }) async {
    final obscurePreview = hideInMenu ?? obscureAppSwitcherPreview;
    try {
      return await _channel.invokeMethod<bool>(
            'setAppPrivacy',
            <String, Object?>{
              'preventScreenshot': preventScreenshot,
              'hideInMenu': obscurePreview,
            },
          ) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Backwards-compatible alias for [configure].
  ///
  /// [preventScreenshot] enables the strongest platform-supported capture
  /// protection. [hideInMenu] masks the app-switcher preview where supported.
  @Deprecated('Use AppPrivacy.configure instead.')
  static Future<bool> appSecuritySettings({
    bool preventScreenshot = false,
    bool hideInMenu = false,
  }) => configure(
    preventScreenshot: preventScreenshot,
    obscureAppSwitcherPreview: hideInMenu,
  );
}
