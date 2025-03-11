import 'package:flutter/services.dart';

class IsEmulator {
  static const MethodChannel _channel = MethodChannel('flutter_tamper_detector');

  static Future<bool> check() async {
    try {
      return await _channel.invokeMethod('isEmulator') ?? false;
    } on PlatformException catch (e) {
      print("Failed to check emulator: '${e.message}'.");
      return false;
    }
  }
}
