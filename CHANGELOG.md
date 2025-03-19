## 0.5.0
* Implemented new functionality to enhance app security settings, allowing control over screenshot prevention and hiding the app from the recent apps menu.
* Added the `appSecuritySettings` method, which uses a native method channel to configure the app’s window

## 0.4.0
* Adding functionality to check if the application was installed from the store (PlayStore)
* `isInstalledFromPlaystore` with the optional parameter `exitProcessIfFalse`

## 0.3.1
* Fix format to pub points
* This not affect current implamentations

## 0.3.0
* Added new param in `isRooted` and `isHooked` `uninstallIfTrue`, in these two cases, because we use the attacker's own root to uninstall our app.
* Added new functions to uninstall app if device is root or contains hooks.
* This feature can only be tested on rooted devices, because we use root against it by uninstalling the app with special root permissions.

## 0.2.1
* Added more verifications for Magisk
* This not affect the current implementation

## 0.2.0
* Implemented `isDebug` method to detect if the app is running in debug mode.
* **New Method**: `FlutterTamperDetector.isDebug()`
* Returns `true` if the app is in debug mode, otherwise returns `false`.
* Utilizes native code in Kotlin to check the app's `ApplicationInfo.FLAG_DEBUGGABLE` flag.
* Optional parameter `exitProcessIfTrue` if `true` finish app process immediately.

## 0.1.4 
* Added instructions in **README.md** for properly configuring ProGuard/R8.  
* Updated the **example app (`example/`)** to include information about ProGuard.  
* Improved documentation to make it easier to configure the package in projects that use code minification and obfuscation.  

## 0.1.3
* Use dart format to fix the pub points
* Not affect the code

## 0.1.2
* Fix Readme

## 0.1.1
* Adding an example/project so you can natively implement and terminate processes before even entering the flutter engine
* See Readme

## 0.1.0
* Added a new parameter to terminate the application process automatically natively
* Update README and example

## 0.0.2
* Fix references to repository

## 0.0.1

* Initial release of `flutter_tamper_detector`
* Added root, hook, and emulator detection
