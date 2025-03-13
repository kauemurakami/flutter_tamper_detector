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
```
Then you can make some decision in your app according to your needs, for example, the app if it is running on a rooted device.<br/>
```dart
 Future<void> checkIfRooted() async {
    bool isRooted = await FlutterTamperDetector.isRooted();

    if (isRooted) {
      print('Device is rooted, exiting the app...');
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
```
See more details in the example section<br/>

## How test
 1 - Run on a emulator<br/>
 2 - Run on a device rooted (ex with [magisk](https://github.com/topjohnwu/Magisk))<br/>
 3 - Run on a device that has frida on it, for example, you can test this by following the [official frida documentation](https://frida.re/docs/android/), after completing the steps described there, run the application.<br/>
 Don't worry, after that you will be able to remove Frida from your device.<br/>
