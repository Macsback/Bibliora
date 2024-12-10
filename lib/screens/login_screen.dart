import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final idToken = googleAuth.idToken;

        if (idToken != null) {
          // Send the ID token to your backend for verification and login
          final response = await http.post(
            Uri.parse('https://bibliorabackend.online/google-login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'id_token': idToken}),
          );

          if (response.statusCode == 200) {
            // Login successful
            print('Login successful');
            // Navigate to home screen or dashboard
          } else {
            // Handle error
            print('Error: ${response.body}');
          }
        }
      }
    } catch (error) {
      print("Google login error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: ElevatedButton(
          onPressed: _googleLogin,
          child: Text("Login with Google"),
        ),
      ),
    );
  }
}
