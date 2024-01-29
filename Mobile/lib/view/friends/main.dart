// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:app/dep/token.dart';
import 'package:app/dep/variables.dart';
import 'package:app/view/.components/global/toast.dart';
import 'package:app/view/.components/navigation/main.dart';
import 'package:feather_icons/feather_icons.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _usernameController = TextEditingController();
  List<Map<String, dynamic>> friendList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadFriendListOnLoad();
  }

  Future<void> loadFriendListOnLoad() async {
    setState(() {
      isLoading = true;
    });
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

        if (responseBody.containsKey('all') && responseBody['all'] is List<dynamic>) {
          List<String> friendIds = List<String>.from(responseBody['all']);
          List<Map<String, dynamic>> updatedFriendList = [];

          for (String friendId in friendIds) {
            final userData = await fetchFriendInfo(token, friendId);

            if (userData.statusCode == 200) {
              Map<String, dynamic> userDataResponse = jsonDecode(userData.body);
              String friendName = userDataResponse['name'];
              String friendSlogan = userDataResponse['slogan'] as String? ?? 'GekkeKoe';
              int friendStatus = int.tryParse(userDataResponse['status'].toString()) ?? 0;

              updatedFriendList.add({
                'id': friendId,
                'name': friendName,
                'status': friendStatus,
                'slogan': friendSlogan,
              });
            }
          }

          setState(() {
            friendList = updatedFriendList;
            isLoading = false;
          });
        } else {
          print('Invalid or missing "all" property in the API response.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('[ERROR] With the request! (not status code 200)');
        print('[ERROR] Statuscode: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('[ERROR] With the request: $error');
      setState(() {
        isLoading = false;
      });
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

  
  Future<void> refreshData() async {
    await loadFriendListOnLoad();
  }

  Future<http.Response> fetchFriendInfo(String? token, String friendId) async {
    var request = await http.post(
      Uri.parse('$hostname/friends/info'),
      headers: {
        'auth': token!,
        'content-type': 'application/json',
      },
      body: jsonEncode({'FriendID': friendId}),
    );
    print('[QUERY] ${request.body}');
    return request;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        if (!isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: Text(
              'Vrienden',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: SpinKitSquareCircle( color: Colors.orangeAccent, duration: Duration(milliseconds: 1200), ),
            )
          else if (friendList.isNotEmpty)
            Expanded(
              child: RefreshIndicator(
                onRefresh: refreshData,
                child: ListView.builder(
                  itemCount: friendList.length,
                  itemBuilder: (context, index) {
                    return _buildFriendListItem(
                      friendList[index]['name'],
                      friendList[index]['status'],
                      friendList[index]['id'],
                      friendList[index]['slogan']
                    );
                  },
                ),
              ),
            )
          else
            SizedBox(
              width: 350,
              child: Text(
                '🔍 Hm... We hebben (nog) geen vrienden kunnen vinden!',
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (!isLoading)  
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _usernameController,
              style: TextStyle(color: Theme.of(context).hintColor,),
              decoration: InputDecoration(
                hintText: 'Gebruikersnaam',
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
                  icon: Icon(Icons.add, color: Theme.of(context).hintColor,),
                  onPressed: () async {
                    String username = _usernameController.text;
                    print('Gebruikersnaam: $username');

                    final token = await getToken();

                    final payload = jsonEncode({'friend': username});

                    final response = await http.post(
                      Uri.parse('$hostname/friends/add'),
                      headers: {
                        'auth': token!,
                        'content-type': 'application/json',
                      },
                      body: payload,
                    );
                    Map<String, dynamic> responseBody = jsonDecode(response.body);
                    String message = responseBody['msg'];

                    showToast(context, message);
                    refreshData();
                    
                    _usernameController.clear();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Navigationbar(initialIndex: 3),
    );
  }

  Widget _buildFriendListItem(String name, int status, String friendId, String slogan){
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 1:
        statusText = 'Accepteren';
        statusColor = Colors.green;
        statusIcon = FeatherIcons.checkCircle;
        break;
      case 2:
        statusText = 'Verzonden';
        statusColor = Colors.orange;
        statusIcon = FeatherIcons.watch;
        break;
      default:
        statusText = 'Verwijderen';
        statusColor = Colors.red;
        statusIcon = Icons.heart_broken;
        break;
    }

    return RefreshIndicator(
      onRefresh: () async {
        await refreshData();
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 15,),
        child: ListTile(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).hintColor, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          leading: FutureBuilder<Widget>(
            future: buildProfilePicture(friendId),
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(color: Theme.of(context).hintColor,),
              ),
              InkWell(
                onTap: () async {
                  print('$statusText - $friendId');
                  if (statusText == 'Verzonden') {
                    final token = await getToken();
                    final payload = jsonEncode({'friend': friendId});
                    final response = await http.post(
                      Uri.parse('$hostname/friends/cancel'),
                      headers: {
                        'auth': token!,
                        'content-type': 'application/json',
                      },
                      body: payload,
                    );
                    Map<String, dynamic> responseBody = jsonDecode(response.body);
                    String message = responseBody['code'];
                    print(message);
                    if (message == 'request_canceled') {
                      showToast(context, 'Het vriendschapverzoek is geannuleerd!');
                      refreshData();
                    }
                  } if (statusText == 'Accepteren') {
                    final token = await getToken();
                    final payload = jsonEncode({'friend': friendId});
                    final response = await http.post(
                      Uri.parse('$hostname/friends/accept'),
                      headers: {
                        'auth': token!,
                        'content-type': 'application/json',
                      },
                      body: payload,
                    );
                    Map<String, dynamic> responseBody = jsonDecode(response.body);
                    String message = responseBody['code'];
                    if (message == 'friend_accepted') {
                      showToast(context, 'Friend geaccepteerd!');
                      refreshData();
                    }
                  } if (statusText == 'Verwijderen') {
                    final token = await getToken();
                    final payload = jsonEncode({'friend': friendId});
                    final response = await http.post(
                      Uri.parse('$hostname/friends/remove'),
                      headers: {
                        'auth': token!,
                        'content-type': 'application/json',
                      },
                      body: payload,
                    );
                    Map<String, dynamic> responseBody = jsonDecode(response.body);
                    String message = responseBody['code'];
                    if (message == 'friend_deleted') {
                      showToast(context, 'Vriend is verwijderd!');
                      refreshData();
                    }
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            ),
          subtitle: Text(
            slogan,
            style: TextStyle(color: Theme.of(context).hintColor.withOpacity(0.75),),
          ),
        ),
      ),
    );
  }
}
