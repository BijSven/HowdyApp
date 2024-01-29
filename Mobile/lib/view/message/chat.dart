// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, library_prefixes, unused_local_variable

import 'dart:convert';
import 'dart:math';
import 'package:app/dep/colors.dart';
import 'package:app/dep/message/chatdb.dart';
import 'package:app/dep/token.dart';
import 'package:app/dep/variables.dart';
import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

DBChat _sl = DBChat();
ScreenshotCallback screenshotCallback = ScreenshotCallback();

String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatScreen extends StatefulWidget {
  final String friendID;
  final String friendName;

  const ChatScreen({Key? key, required this.friendID, required this.friendName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

int randomInt() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  
  int result = 0;
  for (int value in values) {
    result = (result << 8) + value;
  }

  return result;
}

class MessageData {
  final Map<String, dynamic> author;
  final int createdAt;
  final int id;
  final String? text;
  final String? uri;
  final String type;

  MessageData({required this.author, required this.createdAt, required this.id, this.text, this.uri, required this.type});

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      author: json['author'],
      createdAt: json['createdAt'],
      id: json['id'],
      text: json['text'],
      uri: json['uri'],
      type: json['type'],
    );
  }
}


class _ChatScreenState extends State<ChatScreen> {
  List<types.Message> _messages = [];
  late var _user = const types.User(firstName: '', id: '');
  late var _friend = const types.User(firstName: '', id: '');
  late IO.Socket socket;
  int _page = 1;
  bool isLoadingMessages = false;
  
  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    screenshotCallback.addListener(() {
      _handleScreenshotTaken();
    });
    _connectSocket();
    _sl.open().then((_) {
      _loadMessages();
    });
  }

  void _connectSocket() async {
    print('[SOCKET] Setting up connection...');
    var token = await getToken();
    try {
      socket = IO.io('https://howdy.live.orae.one', <String, dynamic>{
        'transports': ['websocket'],
      });
      print('[SOCKET] Socket: Websocket');
      
      socket.onConnect((_) {
        print('[SOCKET] Connection established!');
        socket.emit('auth', jsonEncode({
          'token': token,
        }));
        print('[SOCKET] Authenicated!');
      });

      socket.on('refresh', (data) => _loadNewMSG());
      socket.onDisconnect((_) => print('[SOCKET] Disconnected from socket!'));
      socket.connect();
    } catch (e) {
      print('[SOCKET] Error: $e');
    }
  }

  void _loadUserData() async {
    final userName = await loadUsername();

    final token = await getToken();
    var response = await http.get(
      Uri.parse('$hostname/data/id'),
      headers: {'auth': token!}
    );

    var data = jsonDecode(response.body);
    String UserID = data['ID'];

    final user = types.User(firstName: userName, id: UserID);
    final friend = types.User(
      firstName: widget.friendName,
      id: widget.friendID,
    );

    setState(() {
      _user = user;
      _friend = friend;
    });
  }

  void _handleScreenshotTaken() {
    final screenshotMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecond,
      id: randomString(),
      text: '_Heeft een screenshot gemaakt van de chat_',
      remoteId: _friend.id,
    );

    _addMessage(screenshotMessage);
  }

  void _loadMessages() async {
    setState(() {
      isLoadingMessages = true;
    });

    try {
      var token = await getToken();
      var response = await http.get(
        Uri.parse('$hostname/messages/load?UserID=${widget.friendID}'),
        headers: {'auth': token!},
      );


      if (response.statusCode == 200) {
        List<MessageData> messageDataList = (json.decode(response.body) as List)
            .map((message) => MessageData.fromJson(message))
            .toList()
            .reversed
            .toList();

        List<Future<types.Message>> preserverMessages = messageDataList
            .map((messageData) async {
                Map<String, dynamic> author = Map<String, dynamic>.from(messageData.author);
                author['id'] = author['id']?.toString();

                if (messageData.type == 'txt') {
                    await _sl.addmsg(messageData.author['id'].toString(), messageData.createdAt.toString(), messageData.id.toInt(), messageData.text.toString(), widget.friendID.toString(),);
                    return types.TextMessage(
                        author: types.User.fromJson(author),
                        createdAt: messageData.createdAt,
                        id: messageData.id.toString(),
                        text: messageData.text ?? '',
                        remoteId: widget.friendID,
                    );
                } else if (messageData.type == 'img') {
                  return types.ImageMessage(
                      author: types.User.fromJson(author),
                      createdAt: messageData.createdAt,
                      id: messageData.id.toString(),
                      uri: messageData.uri ?? '',
                      name: author['firstName'] ?? '',
                      remoteId: widget.friendID,
                      size: 0,
                  );
                } else {
                  throw Exception('Unknown message type: ${messageData.type}');
                }
            })
            .toList();

        List<types.Message> serverMessages = await Future.wait(preserverMessages);

        for (var messageData in serverMessages) {
          final token = await getToken();
          var response = await http.get(
            Uri.parse('$hostname/data/id'),
            headers: {'auth': token!}
          );

          String username = await loadUsername();

          var data = jsonDecode(response.body);
          String UserID = data['ID'];

          String UserUserID;

          if (messageData.author.id.toString() != UserID) { UserUserID = UserID; }
          else { UserUserID = widget.friendID; }

          if(messageData is types.TextMessage) {
            _sl.addmsg(
              messageData.author.id.toString(),
              messageData.createdAt.toString(),
              int.parse(messageData.id),
              messageData.text.toString(),
              UserUserID,
            );
          }
        }
        
        List<Map<String, dynamic>> localMessages = await _sl.getMessages(widget.friendID, 1);

        List<Future<types.Message>> futureMessagesLocalMessages = localMessages.map((messageData) async {
          String User01 = messageData['User01'];
          String User02 = messageData['User02'];
          String msgid = messageData['id'].toString();
          String content = messageData['Content'];
          String createdAtTime = messageData['Time'];
          String Type = messageData['Type'];

          int timeMaded = int.parse(createdAtTime);

          final token = await getToken();
          var response = await http.get(
            Uri.parse('$hostname/data/id'),
            headers: {'auth': token!}
          );

          String username = await loadUsername();

          var data = jsonDecode(response.body);
          String UserID = data['ID'];
          String UserUsername;

          if (User01 == UserID) {
            UserUsername = username;
          } else {
            UserUsername = widget.friendName;
          }

          if (Type == 'txt') {
            return types.TextMessage(
              author: types.User(id: User01, firstName: UserUsername),
              id: msgid,
              text: content,
              createdAt: timeMaded,
            );
          } else {
            throw Exception('Unknown message type: $Type');
          }
        }).toList().reversed.toList();
          
        List<types.Message> localMessagesConverted = await Future.wait(futureMessagesLocalMessages);

        localMessagesConverted.sort((a, b) => (b.createdAt ?? 0) - (a.createdAt ?? 0));

        setState(() {
          _messages = localMessagesConverted;
          isLoadingMessages = false;
        });
      } else {
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error loading messages: ");
      print(stackTrace);
    }
  }

  Future<void> _handleEndReached() async {
    print('[PAGER] Loading page: $_page');
    List<Map<String, dynamic>> localMessages = await _sl.getMessages(widget.friendID, _page);

    List<Future<types.Message>> futureMessagesLocalMessages = localMessages.map((messageData) async {
      String User01 = messageData['User01'];
      String User02 = messageData['User02'];
      String msgid = messageData['id'].toString();
      String content = messageData['Content'];
      String createdAtTime = messageData['Time'];
      String Type = messageData['Type'];

      int timeMaded = int.parse(createdAtTime);

      final token = await getToken();
      var response = await http.get(
        Uri.parse('$hostname/data/id'),
        headers: {'auth': token!}
      );

      String username = await loadUsername();

      var data = jsonDecode(response.body);
      String UserID = data['ID'];
      String UserUsername;

      if (User01 == UserID) {
        UserUsername = username;
      } else {
        UserUsername = widget.friendName;
      }

      if (Type == 'txt') {
        return types.TextMessage(
          author: types.User(id: User01, firstName: UserUsername),
          id: msgid,
          text: content,
          createdAt: timeMaded,
        );
      } else {
        throw Exception('Unknown message type: $Type');
      }
    }).toList().reversed.toList();

              
    List<types.Message> localMessagesConverted = await Future.wait(futureMessagesLocalMessages);

    localMessagesConverted.sort((a, b) => (b.createdAt ?? 0) - (a.createdAt ?? 0));
    
    setState(() {
      _messages = [...localMessagesConverted, ..._messages,];
      _page = _page + 1;
    });
  }


  void _loadNewMSG() async {
    try {
      var token = await getToken();
      var response = await http.get(
        Uri.parse('$hostname/messages/load?UserID=${widget.friendID}'),
        headers: {'auth': token!},
      );

      if (response.statusCode == 200) {
        List<MessageData> messageDataList = (json.decode(response.body) as List)
            .map((message) => MessageData.fromJson(message))
            .toList()
            .reversed
            .toList();

        for (var messageData in messageDataList) {

          final token = await getToken();
          var response = await http.get(
            Uri.parse('$hostname/data/id'),
            headers: {'auth': token!}
          );

          String username = await loadUsername();
          var data = jsonDecode(response.body);
          String UserID = data['ID'];
          String UserUsername;

          if (messageData.author['id'] == UserID) { UserUsername = username; }
          else { UserUsername = widget.friendName; }

          var messagetoadd = types.TextMessage(
              author: types.User(id: messageData.author['id'], firstName: UserUsername),
              id: messageData.id.toString(),
              text: messageData.text.toString(),
              createdAt: messageData.createdAt.toInt(),
            );
          
          String UserUserID;

          if (messageData.author['id'].toString() != UserID) { UserUserID = UserID; }
          else { UserUserID = widget.friendID; }

          _sl.addmsg(
            messageData.author['id'].toString(),
            messageData.createdAt.toString(),
            messageData.id.toInt(),
            messageData.text.toString(),
            UserUserID,
          );

          
          setState(() {
            _messages.insert(0, messagetoadd);
          });
        }
      } else {
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error loading messages: ");
      print(stackTrace);
    }
  }


  @override
  Widget build(BuildContext context) {
    if(isLoadingMessages) {
      return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SpinKitSquareCircle( color: Colors.orangeAccent, duration: Duration(milliseconds: 1200), ),
            const SizedBox(height: 25),
            FractionallySizedBox(
              widthFactor: 0.75,
              child: Text(
                'Chat voor ${widget.friendName} aan het laden...',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text('Bericht naar ${widget.friendName}'),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).hintColor,
              ),
              onPressed: () async {
                Aptabase.instance.trackEvent("ChatClosed");
                Navigator.pushReplacementNamed(context, '/home/message');
              },
            ),
          ),
          body: Chat(
          theme: DefaultChatTheme(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            primaryColor: Theme.of(context).primaryColor,
            secondaryColor: TColor(context, const Color.fromARGB(255, 63, 63, 63), Colors.white,),
              receivedMessageBodyTextStyle: TextStyle(
                color: TColor(context, Colors.white, Colors.black),
                fontSize: 16,
              ),
          ),
          l10n: ChatL10nEn(
            inputPlaceholder: 'Begin met je bericht te schrijven!',
            unreadMessagesLabel: 'Ongelezen bericht!',
            emptyChatPlaceholder: 'Er zijn nog geen berichten in de chat met ${widget.friendName}...',
          ),
            showUserAvatars: false,
            showUserNames: true,
            messages: _messages,
            onSendPressed: _handleSendPressed,
            user: _user,
            onPreviewDataFetched: _handlePreviewDataFetched,
            onAttachmentPressed: _handleFileSelection,
            onEndReached: _handleEndReached,
          ),
      );
    }
  }
  void _addMessage(types.Message message) {
    Aptabase.instance.trackEvent("MessageSent");
    setState(() {
      _messages.insert(0, message);
      _addMessageToServer(message);
      if(message is types.TextMessage) {
        _sl.addmsg(message.author.id, message.createdAt.toString(), int.parse(message.id), message.text.toString(), widget.friendID.toString(),);
      }
    });
  }

  void _handleFileSelection() async {
    Aptabase.instance.trackEvent('ChatToCamera');
    Navigator.pushReplacementNamed(context, '/home/start');
  }

  void _addMessageToServer(types.Message message) async {
    if (message is types.TextMessage) {
      var token = await getToken();
      var response = await http.post(
        Uri.parse('$hostname/messages/add'),
        headers: {'Content-Type': 'application/json', 'auth': token!},
        body: jsonEncode({
          'Content': message.text,
          'Channel': widget.friendID,
          'Type': 'txt',
        })
      );
      print('Statuscode: ${response.statusCode}');
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomInt().toString(),
      text: message.text,
      remoteId: _friend.id,
    );

    _addMessage(textMessage);
  }
  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
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
    return 'Unknown';
  }
}
