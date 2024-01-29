// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:app/view/.components/navigation/main.dart';
import 'package:app/view/message/chat.dart';
import 'package:app/view/message/view.dart';
import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:app/dep/token.dart';
import 'package:app/dep/variables.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late Future<List<Map<String, dynamic>>> friendListFuture;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    friendListFuture = loadFriendListOnLoad();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> loadFriendListOnLoad() async {
    List<Map<String, dynamic>> updatedFriendList = [];

    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$hostname/friends/list'),
        headers: {
          'auth': token!,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

        if (responseBody.containsKey('now') && responseBody['now'] is List<dynamic>) {
          List<String> friendIds = List<String>.from(responseBody['now']);

          for (String friendId in friendIds) {
            final userData = await fetchFriendInfo(token, friendId);

            if (userData.statusCode == 200) {
              Map<String, dynamic> userDataResponse = jsonDecode(userData.body);
              String friendName = userDataResponse['name'];

              final hasNewImages = await sendQueryRequest(friendId);

              updatedFriendList.add({
                'id': friendId,
                'name': friendName,
                'hasNewImage': hasNewImages,
              });
            }
          }
        } else {
          print('Invalid or missing "now" property in the API response.');
        }
      } else {
        print('[ERROR] With the request! (not status code 200)');
      }
    } catch (error) {
      print('[ERROR] With the request: $error');
    }

    return updatedFriendList;
  }

  Future<Widget> buildProfilePicture(String friendID) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$hostname/data/profile?ID=$friendID'),
      headers: {
        'auth': token!,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseBody.containsKey('url')) {
        final imageUrl = responseBody['url'];
        return SvgPicture.network(
          imageUrl,
          width: 40,
          height: 40,
        );
      } else {
        print('URL ontbreekt in de API-reactie.');
      }
    } else {
      print('Fout bij het ophalen van profielfoto (statuscode ${response.statusCode}).');
    }
    return Container();
  }


  Future<http.Response> fetchFriendInfo(String? token, String friendId) async {
    return await http.post(
      Uri.parse('$hostname/friends/info'),
      headers: {
        'auth': token!,
        'content-type': 'application/json',
      },
      body: jsonEncode({'FriendID': friendId}),
    );
  }

  Future<String> sendQueryRequest(String friendId) async {
    var token = await getToken();
    final response = await http.post(
      Uri.parse('$hostname/messages/query'),
      headers: {
        'auth': token!,
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'ID': friendId,
      })
    );

    print('[QUERY] ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

      String status = responseBody['new'];
      if (status == 'txt') {
        return 'txt';
      } if (status == 'img') {
        return 'img';
      } if (status == 'txt + img') {
        return 'both';
      } if (status == '') {
        return '';
      }
    }
    return '';
  }

  Future<void> _refreshFriendList() async {
    setState(() {
      friendListFuture = loadFriendListOnLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshFriendList,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: friendListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitSquareCircle( color: Colors.orangeAccent, duration: Duration(milliseconds: 1200), ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  child: Text(
                    'Hm... Het ziet er hier kaal uit! Probeer vrienden toe te voegen in het vrienden-menu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                    )
                  ),
                ),
              );
            } else {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final friend = snapshot.data![index];
                        final friendName = friend['name'];

                        return FutureBuilder<String>(
                          future: sendQueryRequest(friend['id']),
                          builder: (context, querySnapshot) {
                            if (querySnapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: Container()
                              );
                            } else if (querySnapshot.hasError) {
                              return const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              );
                            } else {
                              String result = querySnapshot.data ?? '';

                              String messageText = 'Klik om te chatten met $friendName';
                              bool hasNewContact = false;
                              bool imageAvailable = false;

                              if (result == 'txt') {
                                messageText = 'Nieuw tekstbericht van $friendName!';
                                hasNewContact = true;
                              } else if (result == 'img') {
                                messageText = 'Nieuw afbeeldingsbericht van $friendName!';
                                hasNewContact = true;
                                imageAvailable = true;
                              } else if (result == 'txt + img' || result == 'both') {
                                messageText = 'Nieuw tekst- en afbeeldingsbericht van $friendName!';
                                hasNewContact = true;
                                imageAvailable = true;
                              }

                              Icon notificationIcon = Icon(
                                hasNewContact ? FeatherIcons.bell : FeatherIcons.messageCircle,
                                color: hasNewContact ? Colors.red : Theme.of(context).hintColor,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(top: 15,),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Theme.of(context).hintColor, width: 1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  leading: FutureBuilder<Widget>(
                                    future: buildProfilePicture(friend['id']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return const Icon(
                                          Icons.error_outline,
                                          color: Colors.red,
                                        );
                                      } else {
                                        return snapshot.data ?? Container();
                                      }
                                    },
                                  ),
                                  title: Text(
                                    friendName,
                                    style: TextStyle(
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  subtitle: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        if (hasNewContact)
                                          const TextSpan(
                                            text: '•',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        TextSpan(
                                          text: messageText,
                                          style: TextStyle(
                                            color: hasNewContact
                                                ? Colors.red
                                                : Theme.of(context).hintColor.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onTap: () {
                                    print('Starting message to $friendName');
                                    if (!imageAvailable) {
                                      void navigateToChatView(String friendID) {
                                        Aptabase.instance.trackEvent('ChatOpen', {'context': 'Message'});
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(friendID: friendID, friendName: friendName,),
                                          ),
                                        );
                                      }
                                      navigateToChatView(friend['id']);
                                    } else {
                                      void navigateToViewImage(String friendID) {
                                        Aptabase.instance.trackEvent('ChatOpen', {'context': 'Image'});
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ImageScreen(friendID: friendID, friendName: friendName,),
                                          ),
                                        );
                                      }
                                      navigateToViewImage(friend['id']);
                                    }
                                  },
                                  trailing: notificationIcon,
                                ),
                              );
                            }
                          },
                        );
                      },
                    )
                  ),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: const Navigationbar(initialIndex: 1),
    );
  }
}
