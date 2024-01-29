import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:app/view/camera/send.dart';

class EditorScreen extends StatelessWidget {
  final String encodedImage;

  const EditorScreen({Key? key, required this.encodedImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildImageFromBase64(encodedImage),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home/start');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 236, 76, 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Verwerpen'),
                ),
                const SizedBox(width: 25),
                ElevatedButton(
                  onPressed: () {
                    navigateToSendScreen(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 70, 136, 236),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Verzenden!'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void navigateToSendScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SendScreen(encodedImage: encodedImage),
      ),
    );
  }

  Widget _buildImageFromBase64(String base64String) {
    try {
      final Uint8List bytes = base64Decode(base64String);
      return Image.memory(bytes);
    } catch (e) {
      print('Fout bij het decoderen van de afbeelding: $e');
      return Container();
    }
  }
}
