import 'package:flutter/services.dart';

class IsRooted {
  static const MethodChannel _channel = MethodChannel('flutter_tamper_detector');

  static Future<bool> check() async {
    try {
      return await _channel.invokeMethod('isRooted') ?? false;
    } on PlatformException catch (e) {
      print("Failed to check root status: '${e.message}'.");
      return false;
    }
  }
}
