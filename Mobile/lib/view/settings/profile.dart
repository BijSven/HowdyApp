// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, unused_import

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;

import 'package:app/dep/token.dart';
import 'package:app/dep/variables.dart';
import 'package:app/view/.components/global/toast.dart';
import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AvatarConfig {
  String topType;
  String facialHairType;
  String skinColor;
  String glassesType;
  String clothingType;
  String eyeType;
  String hairColor;

  AvatarConfig({
    required this.topType,
    required this.facialHairType,
    required this.skinColor,
    required this.glassesType,
    required this.clothingType,
    required this.eyeType,
    required this.hairColor,
  });
}

class ProfileEditor extends StatefulWidget {
  const ProfileEditor({Key? key}) : super(key: key);

  @override
  _ProfileEditorState createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  final TextEditingController _usernameController = TextEditingController();

  final List<String> topTypes = [
    "NoHair",
    "Eyepatch",
    "Hat",
    "Hijab",
    "Turban",
    "WinterHat1",
    "WinterHat2",
    "WinterHat3",
    "WinterHat4",
    "LongHairBigHair",
    "LongHairBob",
    "LongHairBun",
    "LongHairCurly",
    "LongHairCurvy",
    "LongHairDreads",
    "LongHairFrida",
    "LongHairFro",
    "LongHairFroBand",
    "LongHairNotTooLong",
    "LongHairShavedSides",
    "LongHairMiaWallace",
    "LongHairStraight",
    "LongHairStraight2",
    "LongHairStraightStrand",
    "ShortHairDreads01",
    "ShortHairDreads02",
    "ShortHairFrizzle",
    "ShortHairShaggyMullet",
    "ShortHairShortCurly",
    "ShortHairShortFlat",
    "ShortHairShortRound",
    "ShortHairShortWaved",
    "ShortHairSides",
    "ShortHairTheCaesar",
    "ShortHairTheCaesarSidePart",
  ];

  final List<String> facialHairTypes = [
    "Blank",
    "BeardMedium",
    "BeardLight",
    "BeardMajestic",
    "MoustacheFancy",
    "MoustacheMagnum",
  ];

  final List<String> skinColors = [
    "Tanned",
    "Yellow",
    "Pale",
    "Light",
    "Brown",
    "DarkBrown",
    "Black",
  ];

  final List<String> glassesTypes = [
    "None",
    "Kurt",
    "Prescription01",
    "Prescription02",
    "Round",
    "Sunglasses",
    "Wayfarers",
  ];

  final List<String> clothingTypes = [
    "BlazerShirt",
    "BlazerSweater",
    "CollarSweater",
    "GraphicShirt",
    "Hoodie",
    "Overall",
    "ShirtCrewNeck",
    "ShirtScoopNeck",
    "ShirtVNeck",
  ];

  final List<String> eyeTypes = [
    "Close",
    "Cry",
    "Default",
    "Dizzy",
    "EyeRoll",
    "Happy",
    "Hearts",
    "Side",
    "Squint",
    "Surprised",
    "Wink",
    "WinkWacky",
  ];

  final List<String> hairColors = [
    "Auburn",
    "Black",
    "Blonde",
    "BlondeGolden",
    "Brown",
    "BrownDark",
    "PastelPink",
    "Blue",
    "Platinum",
    "Red",
    "SilverGray",
  ];

  Map<String, String> translatedOptions = {
    "NoHair": "Geen haar",
    "Eyepatch": "Ooglapje",
    "Hat": "Hoed",
    "Hijab": "Hijab",
    "Turban": "Tulband",
    "WinterHat1": "Wintermuts 1",
    "WinterHat2": "Wintermuts 2",
    "WinterHat3": "Wintermuts 3",
    "WinterHat4": "Wintermuts 4",
    "LongHairBigHair": "Lang krullend haar",
    "LongHairBob": "Lang bobhaar",
    "LongHairBun": "Lang haar in een knot",
    "LongHairCurly": "Lang krullend haar",
    "LongHairCurvy": "Lang golvend haar",
    "LongHairDreads": "Lang dreadlockhaar",
    "LongHairFrida": "Lang haar met bloemen",
    "LongHairFro": "Lang afrohaar",
    "LongHairFroBand": "Lang afrohaar met band",
    "LongHairNotTooLong": "Niet al te lang haar",
    "LongHairShavedSides": "Lang haar met geschoren zijkanten",
    "LongHairMiaWallace": "Lang haar à la Mia Wallace",
    "LongHairStraight": "Lang steil haar",
    "LongHairStraight2": "Lang steil haar 2",
    "LongHairStraightStrand": "Lang steil haar met plukje",
    "ShortHairDreads01": "Kort dreadlockhaar 1",
    "ShortHairDreads02": "Kort dreadlockhaar 2",
    "ShortHairFrizzle": "Kort krullend haar",
    "ShortHairShaggyMullet": "Kort rommelig mullethaar",
    "ShortHairShortCurly": "Kort krullend haar",
    "ShortHairShortFlat": "Kort steil haar",
    "ShortHairShortRound": "Kort rond haar",
    "ShortHairShortWaved": "Kort golvend haar",
    "ShortHairSides": "Kort haar met zijkanten",
    "ShortHairTheCaesar": "Kort haar à la Caesar",
    "ShortHairTheCaesarSidePart": "Kort haar à la Caesar met zijscheiding",
    "Blank": "Geen gezichtshaar",
    "BeardMedium": "Gemiddelde baard",
    "BeardLight": "Lichte baard",
    "BeardMajestic": "Majestueuze baard",
    "MoustacheFancy": "Stijlvolle snor",
    "MoustacheMagnum": "Magnum snor",
    "Tanned": "Bruin",
    "Yellow": "Geel",
    "Pale": "Bleek",
    "Light": "Licht",
    "Brown": "Bruin",
    "DarkBrown": "Donkerbruin",
    "Black": "Zwart",
    "None": "Geen bril",
    "Kurt": "Kurt-bril",
    "Prescription01": "Voorschriftbril 01",
    "Prescription02": "Voorschriftbril 02",
    "Round": "Ronde bril",
    "Sunglasses": "Zonnebril",
    "Wayfarers": "Wayfarer-bril",
    "BlazerShirt": "Blazer met overhemd",
    "BlazerSweater": "Blazer met trui",
    "CollarSweater": "Trui met kraag",
    "GraphicShirt": "Shirt met afbeelding",
    "Hoodie": "Hoodie",
    "Overall": "Overall",
    "ShirtCrewNeck": "Shirt met ronde hals",
    "ShirtScoopNeck": "Shirt met lage hals",
    "ShirtVNeck": "Shirt met V-hals",
    "Close": "Dicht",
    "Cry": "Huilen",
    "Default": "Standaard",
    "Dizzy": "Duizelig",
    "EyeRoll": "Ogen draaien",
    "Happy": "Blij",
    "Hearts": "Hartjes",
    "Side": "Zijkant",
    "Squint": "Samengeknepen",
    "Surprised": "Verbaasd",
    "Wink": "Knipoog",
    "WinkWacky": "Gekke knipoog",
    "Auburn": "Kastanjebruin",
    "Blonde": "Blond",
    "BlondeGolden": "Goudblond",
    "BrownDark": "Donkerbruin",
    "PastelPink": "Pastelroze",
    "Blue": "Blauw",
    "Platinum": "Platina",
    "Red": "Rood",
    "SilverGray": "Zilvergrijs",
  };

  late AvatarConfig avatarConfig;

  @override
  void initState() {
    super.initState();
    avatarConfig = AvatarConfig(
      topType: topTypes.first,
      facialHairType: facialHairTypes.first,
      skinColor: skinColors.first,
      glassesType: glassesTypes.first,
      clothingType: clothingTypes.first,
      eyeType: eyeTypes.first,
      hairColor: hairColors.first,
    );

    fetchProfileSettings();
  }

  void extractSettingsFromURL(String url) {
    final Uri uri = Uri.parse(url);

      setState(() {
        avatarConfig = AvatarConfig(
          topType: uri.queryParameters['topType'] ?? topTypes.first,
          facialHairType: uri.queryParameters['facialHairType'] ?? facialHairTypes.first,
          skinColor: uri.queryParameters['skinColor'] ?? skinColors.first,
          glassesType: uri.queryParameters['accessoriesType'] ?? glassesTypes.first,
          clothingType: uri.queryParameters['clotheType'] ?? clothingTypes.first,
          eyeType: uri.queryParameters['eyeType'] ?? eyeTypes.first,
          hairColor: uri.queryParameters['hairColor'] ?? hairColors.first,
        );
      }
    );
  }

  Future<void> fetchProfileSettings() async {
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
      if (data.containsKey('url')) {
        extractSettingsFromURL(data['url']);
      }
    } else {
      showToast(context, 'Er ging iets fout bij het ophalen van de profielinstellingen!');
      print(response.statusCode);
    }
  }

  String generateURL() {
    return 'https://avataaars.io/?avatarStyle=Circle'
        '&topType=${avatarConfig.topType}'
        '&facialHairType=${avatarConfig.facialHairType}'
        '&skinColor=${avatarConfig.skinColor}'
        '&accessoriesType=${avatarConfig.glassesType}'
        '&clotheType=${avatarConfig.clothingType}'
        '&eyeType=${avatarConfig.eyeType}'
        '&hairColor=${avatarConfig.hairColor}';
  }

  Widget buildClickableList(String label, List<String> items, String selectedValue, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(translatedOptions[item] ?? item),
                trailing: selectedValue == item
                    ? Icon(
                      Icons.check,
                      color: Theme.of(context).hintColor,
                    )
                    : null,
                onTap: () {
                  onChanged(item);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profielbewerker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Aptabase.instance.trackEvent("profileEdit", {
                  "Clothes": avatarConfig.clothingType,
                  "Hair": avatarConfig.topType,
                  "EyeType": avatarConfig.eyeType,
                  "facialHair": avatarConfig.facialHairType,
                  "Glasses": avatarConfig.glassesType,
                  "HairColor": avatarConfig.hairColor,
                  "SkinColor": avatarConfig.skinColor
                });
                var token = await getToken();
                var url = generateURL();
                var response = await http.post(
                  Uri.parse('$hostname/account/profile/set'),
                  headers: {
                    'content-type': 'application/json',
                    'auth': token!,
                  },
                  body: jsonEncode({'url': url}),
                );
                if (response.statusCode == 200) {
                  showToast(context, 'Je profielfoto is geüpdatet!');
                  Navigator.pushReplacementNamed(context, '/home/settings');
                } else {
                  showToast(context, 'Er ging iets fout met het updaten van jouw profielfoto!');
                  print(response.statusCode);
                }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SvgPicture.network(
              generateURL(),
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _usernameController,
                style: TextStyle(color: Theme.of(context).hintColor,),
                decoration: InputDecoration(
                  hintText: 'Slogan...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.transparent,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).hintColor,),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).hintColor,),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.check, color: Theme.of(context).hintColor,),
                    onPressed: () async {
                      String slogan = _usernameController.text;
                      Aptabase.instance.trackEvent('updatedSlogan');
                      final token = await getToken();

                      final payload = jsonEncode({'slogan': slogan});

                      final response = await http.post(
                        Uri.parse('$hostname/account/profile/set'),
                        headers: {
                          'auth': token!,
                          'content-type': 'application/json',
                        },
                        body: payload,
                      );
                      Map<String, dynamic> responseBody = jsonDecode(response.body);
                      String message = responseBody['msg'];

                      showToast(context, message);
                      
                      _usernameController.clear();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            buildClickableList('Haar Type', topTypes, avatarConfig.topType, (value) {
              setState(() {
                avatarConfig.topType = value!;
              });
            }),
            const SizedBox(height: 16),
            buildClickableList('Gezichtshaar', facialHairTypes, avatarConfig.facialHairType, (value) {
              setState(() {
                avatarConfig.facialHairType = value!;
              });
            }),
            const SizedBox(height: 16),
            buildClickableList('Huidskleur', skinColors, avatarConfig.skinColor, (value) {
              setState(() {
                avatarConfig.skinColor = value!;
              });
            }),
            const SizedBox(height: 16),
            buildClickableList('Brillen', glassesTypes, avatarConfig.glassesType, (value) {
              setState(() {
                avatarConfig.glassesType = value!;
              });
            }),
            const SizedBox(height: 16),
            buildClickableList('Kleding', clothingTypes, avatarConfig.clothingType, (value) {
              setState(() {
                avatarConfig.clothingType = value!;
              });
            }),
            const SizedBox(height: 16),
            buildClickableList('Oogtype', eyeTypes, avatarConfig.eyeType, (value) {
              setState(() {
                avatarConfig.eyeType = value!;
              });
            }),
            buildClickableList('Haarkleur', hairColors, avatarConfig.hairColor, (value) {
              setState(() {
                avatarConfig.hairColor = value!;
              });
            }),
          ],
        ),
      ),
    );
  }
}
