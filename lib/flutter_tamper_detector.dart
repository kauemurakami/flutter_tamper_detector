import './src/is_emulator.dart';
import './src/is_rooted.dart';
import './src/is_hooked.dart';

class FlutterTamperDetector {
  static Future<bool> isEmulator() => IsEmulator.check();
  static Future<bool> isRooted() => IsRooted.check();
  static Future<bool> isHooked() => IsHooked.check();
}
