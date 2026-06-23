import Flutter
import UIKit

public class FlutterTamperDetectorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_tamper_detector", binaryMessenger: registrar.messenger())
    let instance = FlutterTamperDetectorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]

    switch call.method {
   case "isSimulator": 
        let exitProcessIfTrue = args?["exitProcessIfTrue"] as? Bool ?? false
        let isSimulator = IsSimulator.check()
        
        if isSimulator && exitProcessIfTrue {
            exit(0)
        }
        result(isSimulator)

    case "isJailbreak": 
        let exitProcessIfTrue = args?["exitProcessIfTrue"] as? Bool ?? false
        let uninstallIfTrue = args?["uninstallIfTrue"] as? Bool ?? false
        
        let isJailbroken = IsJailbreak.check()
        
        if isJailbroken {
            if exitProcessIfTrue {
                exit(0)
            } else if uninstallIfTrue {
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:]) { _ in
                        exit(0)
                    }
                } else {
                    exit(0)
                }
            }
        }
        result(isJailbroken)
    default:
        result(FlutterMethodNotImplemented)
    }
  }
}
