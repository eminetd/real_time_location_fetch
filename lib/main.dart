import 'package:flutter/material.dart';
import 'package:flutter_application_1/initializer.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(InitialController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Background Location Tracker',
      home: Scaffold(
        body: Center(child: Text('Tracking location in background...')),
      ),
    );
  }
}
