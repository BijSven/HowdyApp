import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 252, 75),
      extendBody: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 25),
              child: Column(
                children: [
                  Text(
                      '👋 Howdy!',
                      style: TextStyle(
                        color: Color.fromARGB(255, 25, 37, 18),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      )
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton( 
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/setup/register');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Nieuw account!'),
                ),
                Container(width: 25,),
                ElevatedButton( 
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/setup/login');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Aanmelden!'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
