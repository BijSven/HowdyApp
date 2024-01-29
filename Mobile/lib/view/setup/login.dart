// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/dep/variables.dart';

const secureStorage = FlutterSecureStorage();

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int currentStep = 0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: Center(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500), 
              child: currentStep == 0
                  ? _buildEmailStep()
                  : _buildPasswordStep(),
            ),
            if (currentStep == 1)
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      currentStep = 0; 
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '👋 Welkom terug!',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white), 
            decoration: InputDecoration(
              hintText: 'E-mail',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.transparent, 
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white), 
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white), 
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton( 
          onPressed: () {
            if (_emailController.text.isNotEmpty) {
              setState(() {
                currentStep = 1; 
              });
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.transparent, 
            side: const BorderSide(color: Colors.white), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Volgende'),
        ),
        const SizedBox(height: 20),
        TextButton( 
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/setup/register');
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white, 
          ),
          child: const Text('Nog geen account?'),
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Voer wachtwoord in',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white), 
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Wachtwoord',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.transparent, 
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white), 
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white), 
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton( 
          onPressed: () {
            _authenticate();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.transparent, 
            side: const BorderSide(color: Colors.white), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Inloggen'),
        ),
      ],
    );
  }

  Future<void> _authenticate() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    final data = {'mail': email, 'pasw': password};
    final headers = {
        'Content-Type': 'application/json'
      };

    try {
      final response = await http.post(
        Uri.parse('$hostname/account/login'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 202) {
        showToast(context, json.decode(response.body)['msg']);
        await secureStorage.write(key: 'token', value: json.decode(response.body)['token']);
        Navigator.pushReplacementNamed(context, '/');
      } else {
        showToast(context, json.decode(response.body)['msg']);
      }
    } catch (e) {
      showToast(context, 'Er is een fout opgetreden! Ben je verbonden met het internet?');
    }
  }

  void showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'Sluiten',
          onPressed: scaffold.hideCurrentSnackBar,
        ),
      ),
    );
  }
}
