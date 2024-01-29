import 'package:app/view/.components/navigation/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NewsHome extends StatelessWidget {
  const NewsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitSquareCircle( color: Colors.orangeAccent, duration: Duration(milliseconds: 1200), ),
          ],
      ),),
      bottomNavigationBar: Navigationbar(initialIndex: 0),
    );
  }
}