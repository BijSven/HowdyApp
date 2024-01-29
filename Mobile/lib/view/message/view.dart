import 'dart:typed_data';
import 'package:app/dep/token.dart';
import 'package:app/dep/variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImageScreen extends StatefulWidget {
  final String friendID;
  final String friendName;

  const ImageScreen({Key? key, required this.friendID, required this.friendName}) : super(key: key);

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  Uint8List imageData = Uint8List(0);

  @override
  void initState() {
    super.initState();
    fetchImage();
  }

  Future<void> fetchImage() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$hostname/messages/img/${widget.friendID}'),
        headers: {'auth': token!},
      );
      if (response.statusCode == 200) {
        setState(() {
          imageData = response.bodyBytes;
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Afbeelding van ${widget.friendName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.pushReplacementNamed(context, '/home/message');
          },
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: imageData.isEmpty
            ? const CircularProgressIndicator()
            : Image.memory(imageData),
      ),
    );
  }
}
