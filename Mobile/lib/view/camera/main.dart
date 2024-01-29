// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:app/view/camera/editor.dart';
import 'package:aptabase_flutter/aptabase_flutter.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:app/view/.components/navigation/main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  XFile? capturedImage;
  DateTime? lastTap;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  void initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );
    await _controller.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  void flipCamera() async {
    int lensDirection = _controller.description.lensDirection == CameraLensDirection.front ? 1 : 0;
    await _controller.dispose();
    List<CameraDescription> cameras = await availableCameras();
    _controller = CameraController(
      cameras[lensDirection],
      ResolutionPreset.high,
    );
    await _controller.initialize();
    if (mounted) {
      setState(() {});
    }
  }


  void handleCameraTap() {
    final now = DateTime.now();
    if (lastTap == null || now.difference(lastTap!) > const Duration(seconds: 1)) {
      lastTap = now;
    } else {
      flipCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _controller.dispose();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 8, 16, 24),
        body: GestureDetector(
          onTap: handleCameraTap,
          child: Column(
            children: [
              FloatingActionButton(onPressed: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
                child: const Icon(FeatherIcons.settings),
              ),
              Expanded(
                child: CameraPreview(_controller),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
          child: GestureDetector(
            onTap: () async {
              if (!_controller.value.isInitialized) {
                return;
              }

              XFile imageFile = await _controller.takePicture();

              setState(() {
                capturedImage = imageFile;
              });

              final imageBytes = await File(imageFile.path).readAsBytes();
              final encodedImage = base64Encode(imageBytes);

              Aptabase.instance.trackEvent("CameraUsed", { "type": 'photo' });

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => EditorScreen(encodedImage: encodedImage,),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.white,
                      width: 6.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const Navigationbar(initialIndex: 2,),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}