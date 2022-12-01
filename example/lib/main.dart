import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ys_play_example/home_page.dart';

String appKey = '9ddc4fb7c0ef4996b04dd90156368f7c';
String accessToken = 'ra.a6523z0d8cvgkihu7dgs40lh5sgbthba-7zpo9y077u-1tblek5-g3rdgxc33';
String deviceSerial = 'C63167422';
String verifyCode = 'PDSWCZ';
int cameraNo = 1;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        home: HomePage(),
      ),
    );
  }
}
