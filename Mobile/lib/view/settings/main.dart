// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:app/dep/token.dart';
import 'package:app/dep/variables.dart';
import 'package:app/view/.components/global/toast.dart';
import 'package:app/view/.components/navigation/main.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

const secureStorage = FlutterSecureStorage();

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Future<String> pfpUrl;
  late Future<String> username;
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();
    pfpUrl = loadPFP();
    username = loadUsername();
    getVersionInfo();
  }

  Future<void> getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }
  

  Future<String> loadPFP() async {
    var token = await getToken();
    var response = await http.get(
      Uri.parse('$hostname/data/profile?ID=Self'),
      headers: {
        'content-type': 'application/json',
        'auth': token!,
      },
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var url = data['url'];
      return url;
    } else {
      showToast(context, 'Er ging iets fout bij het ophalen van de profielinstellingen!');
      print(response.statusCode);
      return 'null';
    }
  }
  
  Future<String> loadUsername() async {
    var token = await getToken();
    var response = await http.post(
      Uri.parse('$hostname/account/me'),
      headers: {'auth': token!}
    );
    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String username = data['name'];
      return username;
    } else {
      return 'NotFoundERROR';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0,),
                  child: FutureBuilder<String>(
                    future: pfpUrl,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return SvgPicture.network(
                          snapshot.data!,
                          width: 65,
                          height: 65,
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,),
                  child: FutureBuilder<String>(
                    future: username,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text('Aan het laden...');
                      } else if (snapshot.hasError) {
                        print('[ERROR] ${snapshot.error}');
                        return const Text('Welkom terug!');
                      } else {
                        return Text(
                          'Welkom terug, ${snapshot.data}!',
                          style: const TextStyle(
                            fontSize: 24
                          )
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            FractionallySizedBox(
              widthFactor: 0.75,
              child: Padding(
                padding: const EdgeInsets.only(top: 15,),
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          PackageInfo packageInfo = await PackageInfo.fromPlatform();

                          String appName = packageInfo.appName;
                          String packageName = packageInfo.packageName;
                          String version = packageInfo.version;
                          String buildNumber = packageInfo.buildNumber;

                          showToast(context,
                            'App Name: $appName\n'
                            'Package Name: $packageName\n'
                            'Version: $version\n'
                            'Build Number: $buildNumber'
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(FeatherIcons.alertCircle),
                            const SizedBox(width: 5,),
                            Text(
                              'Howdy! $version',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home/settings/edit');
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FeatherIcons.user),
                            SizedBox(width: 5,),
                            Text(
                              'Profiel aanpassen',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pushNamed(context, '/home/settings/danger');
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 236, 70, 70),
                          side: const BorderSide(color: Color.fromARGB(255, 250, 50, 50)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FeatherIcons.logOut),
                            SizedBox(width: 5,),
                            Text(
                              'Gevaarlijke zone',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10,),
              child: Column(
                children: [
                  Text(
                    'Howdy Social - All Rights Reserved',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5,),
                  Text(
                    'ORAE Corp. - All Rights Reserved',
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Navigationbar(initialIndex: 4),
    );
  }
}
