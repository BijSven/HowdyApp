// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:app/view/.components/global/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:app/dep/token.dart';
import 'package:app/dep/variables.dart';

class SendScreen extends StatefulWidget {
  final String encodedImage;

  const SendScreen({Key? key, required this.encodedImage}) : super(key: key);

  @override
  _SendScreenState createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  late Future<List<Map<String, dynamic>>> friendListFuture;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    friendListFuture = loadFriendListOnLoad();
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
        final responseBody =
            jsonDecode(response.body) as Map<String, dynamic>;

        if (responseBody.containsKey('now') &&
            responseBody['now'] is List<dynamic>) {
          List<String> friendIds =
              List<String>.from(responseBody['now']);

          for (String friendId in friendIds) {
            final userData = await fetchFriendInfo(token, friendId);

            if (userData.statusCode == 200) {
              Map<String, dynamic> userDataResponse =
                  jsonDecode(userData.body);
              String friendName = userDataResponse['name'];

              updatedFriendList.add({
                'id': friendId,
                'name': friendName,
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

  Future<bool> sendMessageStory(String? token, String img) async {
    final response = await http.post(
      Uri.parse('$hostname/story/new'),
      headers: {
        'auth': token!,
        'content-type': 'application/json',
      },
      body: jsonEncode({'img': img}),
    );

    print('Done!');
    if (response.statusCode == 200) {
      print('Accepted, sent!');
      showToast(context, 'Je afbeelding is toegevoegd aan de story.');
      Navigator.pushReplacementNamed(context, '/home/story');
      return true;
    } else {
      print('Rejected, returned 0');
      showToast(context, 'Aowh! Er ging iets fout tijdens het versturen.');
      return false;
    }
  }

    Future<bool> sendMessageToFriend(String? token, String img, String friendid) async {
    final response = await http.post(
      Uri.parse('$hostname/messages/add'),
      headers: {
        'auth': token!,
        'content-type': 'application/json',
      },
      body: jsonEncode({
          'Channel': friendid,
          'Content': img,
          'Type': 'img'
      }),
    );

    print('Done!');
    if (response.statusCode == 200) {
      print('Accepted, sent!');
      showToast(context, 'Je bericht is verstuurd!');
      Navigator.pushReplacementNamed(context, '/home/message');
      return true;
    } else {
      print('Rejected, returned ${response.statusCode}');
      showToast(context, 'Aowh! Er ging iets fout tijdens het versturen.');
      showToast(context, 'Check of je vriend op de laatste versie van Howdy zit.');
      return false;
    }
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
    return Container(); // Geen profielfoto beschikbaar, retourneer een lege container.
  }


  Future<void> _refreshFriendList() async {
    setState(() {
      friendListFuture = loadFriendListOnLoad();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Versturen'),
      ),
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
                child: Text(
                    'Hm... Het ziet er hier kaal uit! Probeer vrienden toe te voegen in het vrienden-menu!'),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 15,),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15,),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Theme.of(context).hintColor, width: 1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: Text(
                          'Verhaal',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        subtitle: Text(
                          'Klik om toe te voegen aan het verhaal met je vrienden!',
                          style: TextStyle(
                            color: Theme.of(context).hintColor.withOpacity(0.8),
                          ),
                        ),
                        onTap: () async {
                          var token = await getToken();
                          sendMessageStory(token, widget.encodedImage);
                        },
                      ),
                    ),
                    Divider(
                      color: Theme.of(context).hintColor.withOpacity(0.5),
                      thickness: 1,
                      indent: 8,
                      endIndent: 8,
                    ),
                    Expanded(
                      child: Card(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: snapshot.data!.map((friend) {
                            final friendName = friend['name'];
                            final friendId = friend['id'];

                            return Column(
                              children: [
                                ListTile(
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
                                  subtitle: Text(
                                    'Klik om een foto te sturen naar $friendName!',
                                    style: TextStyle(
                                      color: Theme.of(context).hintColor.withOpacity(0.8),
                                    ),
                                  ),
                                  onTap: () async {
                                    print('Starting message to $friendName');
                                    var token = await getToken();
                                    sendMessageToFriend(token!, widget.encodedImage, friendId);
                                  },
                                ),
                                Divider(
                                  color: Theme.of(context).hintColor.withOpacity(0.5),
                                  thickness: 1,
                                  indent: 8,
                                  endIndent: 8,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
