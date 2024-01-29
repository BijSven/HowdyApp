
import 'package:app/dep/variables.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

const secureStorage = FlutterSecureStorage();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int currentStep = 0;
  bool agreedToTerms = false; // Nieuwe variabele om de toestemming bij te houden
  bool agreedToPrivacy = false;

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
                  ? _buildUsernameStep()
                  : currentStep == 1
                      ? _buildEmailStep()
                      : _buildPasswordStep(),
            ),
            if (currentStep == 1 || currentStep == 2)
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      currentStep--;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '👋 Gezellig dat je meedoet!',
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
            controller: _usernameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Gebruikersnaam',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.transparent,
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Container(
                width: 30.0, // Pas de breedte aan zoals nodig
                height: 30.0, // Pas de hoogte aan zoals nodig
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Checkbox(
                  value: agreedToTerms,
                  activeColor: const Color.fromARGB(0, 0, 0, 0),
                  onChanged: (value) {
                    setState(() {
                      agreedToTerms = value!;
                    });
                  },
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Ik ga akkoord met de ',
                style: const TextStyle(color: Colors.white,),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const TermsOfServiceScreen()));
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Container(
                width: 30.0, // Pas de breedte aan zoals nodig
                height: 30.0, // Pas de hoogte aan zoals nodig
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Checkbox(
                  value: agreedToPrivacy,
                  activeColor: const Color.fromARGB(0, 0, 0, 0),
                  onChanged: (value) {
                    setState(() {
                      agreedToPrivacy = value!;
                    });
                  },
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Ik ga akkoord met de ',
                style: const TextStyle(color: Colors.white,),
                children: [
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyScreen()));
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_usernameController.text.isNotEmpty && agreedToTerms && agreedToPrivacy) {
              setState(() {
                currentStep++;
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
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/setup/login');
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
          ),
          child: const Text('Heb je al een account?'),
        ),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'E-mail',
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
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.5),
                ),
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
                currentStep++;
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
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Wachtwoord',
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
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _register();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.transparent,
            side: const BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Registreren'),
        ),
      ],
    );
  }

  Future<void> _register() async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    final data = {'user': username, 'mail': email, 'pasw': password};
    final headers = {
          'Content-Type': 'application/json'
        };

    try {
      final response = await http.post(
        Uri.parse('$hostname/account/register'),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        showToast(context, json.decode(response.body)['msg']);
        await secureStorage.write(key: 'token', value: json.decode(response.body)['token']);
        Navigator.pushReplacementNamed(context, '/home/start');
      } else {
        showToast(context, json.decode(response.body)['msg']);
      }
    } catch (e) {
      showToast(context, 'Er is een fout opgetreden!');
      print('[ERRO] There was an error; $e');
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

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Text('Terms of Service'),
      ),
      body: const WebView(
        initialUrl: 'https://howdy.orae.one/terms-of-service',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Text('Terms of Service'),
      ),
      body: const WebView(
        initialUrl: 'https://howdy.orae.one/privacy-policy',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
