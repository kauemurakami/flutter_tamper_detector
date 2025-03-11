import 'package:flutter/services.dart';

class IsHooked {
  static const MethodChannel _channel = MethodChannel('flutter_tamper_detector');

  static Future<bool> check() async {
    try {
      return await _channel.invokeMethod('isHooked') ?? false;
    } on PlatformException catch (e) {
      print("Failed to check hooked: '${e.message}'.");
      return false;
    }
  }
}
