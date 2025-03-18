import 'package:flutter/material.dart';
import 'package:flutter_tamper_detector/flutter_tamper_detector.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isEmulator = false;
  bool isRooted = false;
  bool isHooked = false;
  bool isDebug = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceStatus();
  }

  // Function to check device status
  void _checkDeviceStatus() async {
    bool emulator = await FlutterTamperDetector.isEmulator();
    bool rooted = await FlutterTamperDetector.isRooted();
    bool hooked = await FlutterTamperDetector.isHooked();
    bool debug = await FlutterTamperDetector.isDebug();

    /*If you want the package to automatically terminate the application process,
    test with our `exitProcessIfTrue:true` parameter.
    bool emulator = await FlutterTamperDetector.isEmulator(exitProcessIfTrue: true);
    bool rooted = await FlutterTamperDetector.isRooted(exitProcessIfTrue: true);
    or
    bool rooted = await FlutterTamperDetector.isRooted(uninstallIfTrue: true);
    bool hooked = await FlutterTamperDetector.isHooked(exitProcessIfTrue: true);
    or
    bool hooked = await FlutterTamperDetector.isHooked(uninstallIfTrue: true);
    bool debug = await FlutterTamperDetector.isDebug(exitProcessIfTrue: true);
    */

    setState(() {
      isEmulator = emulator;
      isRooted = rooted;
      isHooked = hooked;
      isDebug = debug;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Flutter Tamper Detector Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Is Debug: $isDebug'),
              Text('Is Hooked: $isHooked'),
              Text('Is Rooted: $isRooted'),
              Text('Is Emulator: $isEmulator'),
            ],
          ),
        ),
      ),
    );
  }
}
