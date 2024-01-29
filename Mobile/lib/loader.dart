import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:app/dep/token.dart';
import 'package:app/dep/variables.dart';
import 'package:aptabase_flutter/aptabase_flutter.dart';

const secureStorage = FlutterSecureStorage();

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoading = true;
  String statusText = 'Aan het verbinden...';

  Future<void> _initFirebaseMessaging(BuildContext context) async {
    setState(() {
      statusText = 'Initialiseren van Firebase Messaging...';
    });

    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

    await firebaseMessaging.requestPermission(
      sound: true,
      badge: true,
      alert: true,
      provisional: false,
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.of(context).pushReplacementNamed('/home/message');
    });

    final String? fcmToken = await firebaseMessaging.getToken();
    secureStorage.write(key: 'FCMToken', value: fcmToken);
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$hostname/add/FCMToken'),
        headers: {
          'auth': token!,
          'content-type': 'application/json',
        },
        body: jsonEncode({
          "Token": fcmToken!,
        }),
      );
      if (response.statusCode == 200) {
        secureStorage.write(key: 'FCMTokenStatus', value: "confirmed");
      } else {
        secureStorage.write(key: 'FCMTokenStatus', value: 'unable-to-add');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    checkinternet();
    checkStatus().then((status) {
      setState(() {
        isLoading = false;
        statusText = 'Laden voltooid!';
      });
      if (status) {
        Navigator.of(context).pushReplacementNamed('/home/start');
      } else {
        Navigator.of(context).pushReplacementNamed('/setup/welcome');
      }
      _initFirebaseMessaging(context);
    });
  }
  
  Future<void> checkinternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        isLoading = false;
        statusText = 'Geen internet!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SpinKitSquareCircle( color: Colors.orangeAccent, duration: Duration(milliseconds: 1200), ),
            const SizedBox(height: 25),
            FractionallySizedBox(
              widthFactor: 0.75,
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    statusText,
                    speed: const Duration(milliseconds: 50),
                    textAlign: TextAlign.center,
                    textStyle: const TextStyle(
                      fontSize: 18,
                    )
                  ),
                ],
                totalRepeatCount: 2,
                pause: const Duration(milliseconds: 1000),
                displayFullTextOnTap: true,
                stopPauseOnTap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> checkStatus() async {
  final token = await getToken();
  if (token == null) {
    return false;
  }
  final response = await http.post(
    Uri.parse('$hostname/account/me'),
    headers: {
      'auth': token,
    },
  );

  if (response.statusCode == 200) {
    Aptabase.instance.trackEvent("start");
    return true;
  } else {
    return false;
  }
}