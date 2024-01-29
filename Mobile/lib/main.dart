// ---
// Copyright © 2023 ORAE IBC. All Rights Reserved
// This file is the main source for our app.
// ---

// ignore_for_file: library_private_types_in_public_api, non_constant_identifier_names, use_build_context_synchronously

import 'package:app/dep/variables.dart';
import 'package:app/firebase_options.dart';
import 'package:app/loader.dart';
import 'package:app/view/friends/main.dart';
import 'package:app/view/message/main.dart';
import 'package:app/view/news/main.dart';
import 'package:app/view/settings/danger.dart';
import 'package:app/view/settings/profile.dart';
import 'package:app/view/settings/main.dart';
import 'package:app/view/setup/register.dart';
import 'package:app/view/setup/login.dart';
import 'package:app/view/camera/main.dart';
import 'package:app/dep/theme.dart';
import 'package:app/view/feed/main.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app/view/setup/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aptabase_flutter/aptabase_flutter.dart';

const secureStorage = FlutterSecureStorage();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Aptabase.init(analyticToken, const InitOptions(host: 'https://analytics.orae.one'));

  await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform, );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const StartLoader());
}

class StartLoader extends StatelessWidget {
  const StartLoader({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/setup/welcome': (context) => const WelcomeScreen(),
        '/setup/login': (context) => const LoginScreen(),
        '/setup/register': (context) => const RegisterScreen(),
        '/home/feed': (context) => const FeedHome(),
        '/home/news': (context) => const NewsHome(),
        '/home/message': (context) => const MessageScreen(),
        '/home/friends': (context) => const FriendsScreen(),
        '/home/start': (context) => const CameraScreen(),
        '/home/settings': (context) => const SettingsScreen(),
        '/home/settings/edit': (context) => const ProfileEditor(),
        '/home/settings/danger': (context) => const DangerScreen(),
      },
    );
  }
}