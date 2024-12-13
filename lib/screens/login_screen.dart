import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId:
        "83146556166-6j2evtmvjfe8m27sq3i0as50s3sq3ng8.apps.googleusercontent.com",
    scopes: ['email', 'openid', 'profile'],
  );

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account != null) {
        // Prepare the account data to send to the backend
        final accountData = {
          'google_id': account.id,
          'email': account.email,
          'displayName': account.displayName,
          'photoUrl': account.photoUrl,
        };

        // Send the account data to the backend
        final response = await http.post(
          Uri.parse('https:/bibliorabackend.online/google_login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(accountData),
        );

        if (response.statusCode == 200) {
          print('Login successful: ${response.body}');
        } else if (response.statusCode == 201) {
          print("User created: ${response.body}");
        } else {
          print('Login failed: ${response.body}');
        }
      } else {
        print("User canceled or sign-in failed.");
      }
    } catch (error) {
      print("Error during Google Sign-In: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: _signInWithGoogle,
          child: Text("Login with Google"),
        ),
      ),
    );
  }
}
