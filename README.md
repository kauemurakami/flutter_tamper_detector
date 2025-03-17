[![Star on GitHub](https://img.shields.io/github/stars/kauemurakami/flutter_tamper_detector.svg?style=flat&logo=github&colorB=deeppink&label=stars)](https://github.com/kauemurakami/flutter_tamper_detector)
# flutter_tamper_detector

flutter_tamper_detector is a Flutter security plugin designed to detect and prevent application tampering. It checks if the device is rooted, if tools like Frida, Xposed, or Cydia Substrate are being used, or if the app is running on an emulator. With this information, you can implement security measures in your Flutter app, such as terminating the application or blocking execution.

## Getting Started

```
$ flutter pub add flutter_tamper_detector
```
or add in your dependencies
```
dependencies:
  flutter_tamper_detector: <latest>
```

## Usage

Simple and easy to use!<br/>

```dart
import 'package:flutter_tamper_detector/flutter_tamper_detector.dart';
```
Now just use the functions directly with our main class `FlutterTamperDetector`:<br/>

```dart
bool isEmulator = await FlutterTamperDetector.isEmulator();
bool isRooted   = await FlutterTamperDetector.isRooted();
bool isHooked   = await FlutterTamperDetector.isHooked();
bool isDebug    = await FlutterTamperDetector.isDebug();

```
Then you can make some decision in your app according to your needs, for example, the app if it is running on a rooted device.<br/>
```dart
 Future<void> checkIfRooted() async {
    bool isRooted = await FlutterTamperDetector.isRooted();

    if (isRooted) {
      print('Device is rooted...');
      // TODO: your logic here
    } else {
      print('Device is not rooted.');
    }
  }
```
Or, if you want to automatically terminate the app process when any of the functions are true, you can use the `exitProcessIfTrue: true` parameter.<br>
This way, the application will terminate the process immediately without the need for a decision structure in your Flutter code.<br>
```dart
bool isEmulator = await FlutterTamperDetector.isEmulator(exitProcessIfTrue: true);
bool isRooted   = await FlutterTamperDetector.isRooted(exitProcessIfTrue: true);
bool isHooked   = await FlutterTamperDetector.isHooked(exitProcessIfTrue: true);
bool isDebug    = await FlutterTamperDetector.isDebug(exitProcessIfTrue: true);
```
See more details in [`/example`](https://github.com/kauemurakami/flutter_tamper_detector/tree/main/example)<br/>

## Use native
If you want to stop the process before even entering the Flutter engine, I will provide an example using the same classes here in the package for you to implement directly in the `onCreate` of our `MainActivity.kt`, this way we close the application and end the process before even entering the Flutter engine. Suggestion received via Linkedin from: *Adrian Kohls*<br>
Access -> [native_tamper_detector](https://github.com/kauemurakami/native_tamper_detector)

## ProGuard/R8
If your Flutter app is configured to use ProGuard or R8 (code minification enabled), some flutter_tamper_detector classes may be obfuscated or removed.<br/>
To avoid this, add the following rules to your proguard-rules.pro file (located in `android/app/proguard-rules.pro` in your project):<br/>
```proguard
# Keeps all classes from the native package
-keep class com.deebx.flutter_tamper_detector.** { *; }

# Prevents class names from being changed
-keepnames class com.deebx.flutter_tamper_detector.**
```
See more details in [`/example`](https://github.com/kauemurakami/flutter_tamper_detector/tree/main/example).

## How test
 1 - Run on a emulator<br/>
 2 - Run on a device rooted (ex with [magisk](https://github.com/topjohnwu/Magisk))<br/>
 3 - Run on a device that has frida on it, for example, you can test this by following the [official frida documentation](https://frida.re/docs/android/), after completing the steps described there, run the application.<br/>
 Don't worry, after that you will be able to remove Frida from your device.<br/>
