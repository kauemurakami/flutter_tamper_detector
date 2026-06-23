import 'package:flutter/material.dart';
import 'package:flutter_tamper_detector/flutter_tamper_detector.dart';

bool windowSecurityOn = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  windowSecurityOn = await FlutterTamperDetector.appSecuritySettings(
    hideInMenu: true,
    preventScreenshot: true,
  );

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
  bool isInstalledFromStore = false;

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
    bool isInstalledFromStore =
        await FlutterTamperDetector.isInstalledFromStore();

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
    bool isInstalledFromStore = await FlutterTamperDetector.isInstalledFromStore(exitProcessIfFalse: true);
    */

    setState(() {
      isEmulator = emulator;
      isRooted = rooted;
      isHooked = hooked;
      isDebug = debug;
      isInstalledFromStore = isInstalledFromStore;
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
              Text('Window secutity on: $windowSecurityOn'),
              Text(
                'Is installed from the official store: $isInstalledFromStore',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
