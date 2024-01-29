// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';

import 'package:app/dep/token.dart';
import 'package:app/dep/variables.dart';
import 'package:app/view/.components/global/toast.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:app/dep/message/chatdb.dart';

const secureStorage = FlutterSecureStorage();
DBChat _sl = DBChat();

class DangerScreen extends StatefulWidget {
  const DangerScreen({Key? key}) : super(key: key);

  @override
  _DangerScreenState createState() => _DangerScreenState();
}

class _DangerScreenState extends State<DangerScreen> {
  late Future<String> pfpUrl;
  late Future<String> username;

  @override
  void initState() {
    super.initState();
    pfpUrl = loadPFP();
    username = loadUsername();
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
      headers: {'auth': token!},
    );
    if (response.statusCode == 200) {
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
      appBar: AppBar(
        title: const Text('Gevaarlijke Zone'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 32.0),
              FutureBuilder<String>(
                future: username,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Aan het laden...');
                  } else if (snapshot.hasError) {
                    print('[ERROR] ${snapshot.error}');
                    return const Text('Welkom terug!');
                  } else {
                    return FractionallySizedBox(
                      widthFactor: 0.75,
                      child: Text(
                        'Let op, ${snapshot.data}! Alles wat je hier doet is niet meer terug te draaien.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  await secureStorage.deleteAll();
                  await _sl.rstall();
                  showToast(context, 'Je bent uitgelogd!');
                  await Navigator.pushNamed(context, '/');
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
                      'Uitloggen',
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
                  var token = await getToken();
                  var response = await http.post(
                    Uri.parse('$hostname/account/resetTokens'),
                    headers: {'auth': token!}
                  );
                  if (response.statusCode == 200) {
                    await secureStorage.deleteAll();
                    await _sl.rstall();
                    showToast(context, 'Je bent uitgelogd!');
                    Navigator.pushNamed(context, '/');
                  } else {
                    showToast(context, 'Er ging iets fout bij het verwijderen van jouw tokens! Probeer het later opnieuw, of neem contact op met ons via howdy@bijsven.nl');
                  }
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
                    Icon(Icons.mobile_off),
                    SizedBox(width: 5,),
                    Text(
                      'Log alle apparaten uit!',
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
                  var token = await getToken();
                  var response = await http.post(
                    Uri.parse('$hostname/account/deleteImages'),
                    headers: {'auth': token!}
                  );
                  if (response.statusCode == 200) {
                    showToast(context, 'Alle afbeeldingen zijn verwijderd van onze server.');
                  } else {
                    showToast(context, 'Het lijkt erop dat er iets mis is gegaan. Wacht 2 minuten (voor als je veel afbeeldingen hebt) en probeer het opnieuw. Als dat dan nogsteeds niet werkt, neem met ons contact op via howdy@bijsven.nl!');
                  }
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
                    Icon(FeatherIcons.image),
                    SizedBox(width: 5,),
                    Text(
                      'Verwijder ALLE afbeeldingen.',
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
                  showToast(context, 'Deleting all messages');
                  await _sl.rstall();
                  showToast(context, 'Success! Deleted all the messages');
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
                    Icon(FeatherIcons.messageSquare),
                    SizedBox(width: 5,),
                    Text(
                      'Verwijder ALLE lokale berichten.',
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
      // bottomNavigationBar: const Navigationbar(initialIndex: 4),
    );
  }
}
