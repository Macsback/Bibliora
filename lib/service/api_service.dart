import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bibliora/models/book.dart';
import 'package:bibliora/models/user.dart';
import 'package:bibliora/models/bookclubs.dart';
import 'package:bibliora/service/config_manager.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as https;
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String backendUrl = ConfigManager.getConfigValue('BACKEND_URL');
  GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: ConfigManager.getConfigValue('google_client_id'),
  );
  final Dio dio = Dio();

  // Get all the Books
  static Future<List<Book>> fetchBooks() async {
    try {
      final response = await https.get(Uri.parse('$backendUrl/books'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['books'] != null && data['books'] is List) {
          return (data['books'] as List)
              .map((bookJson) => Book.fromJson(bookJson))
              .toList();
        } else {
          throw Exception('No books found');
        }
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      return [];
    }
  }

  //Get the book thumbnail
  static Future<Uint8List?> fetchImageFromBackend(String coverImageUrl) async {
    try {
      final response = await https.post(
        Uri.parse('$backendUrl/fetch-image'),
        headers: {'Content-Type': 'application/json'},
        body: '{"coverImageUrl": "$coverImageUrl"}',
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get a specific User with the ID
  static Future<User> fetchUserById(String userId) async {
    try {
      final response = await https.get(
        Uri.parse('$backendUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user: $e');
      throw Exception('Failed to load user: $e');
    }
  }

  // Get the users books
  static Future<List<Book>> fetchUserBooks(String userId) async {
    try {
      final response =
          await https.get(Uri.parse('$backendUrl/user_books/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['user_books'] != null && data['user_books'] is List) {
          return (data['user_books'] as List)
              .map(
                  (bookJson) => Book.fromJson(bookJson as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('No user books found');
        }
      } else {
        throw Exception('Failed to load user books');
      }
    } catch (e) {
      return [];
    }
  }

  // Get all the bookclubs
  static Future<List<BookClub>> fetchBookClubs() async {
    try {
      final response = await https.get(Uri.parse('$backendUrl/bookclubs'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['bookclubs'] != null && data['bookclubs'] is List) {
          return (data['bookclubs'] as List)
              .map((bookClub) =>
                  BookClub.fromJson(bookClub as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('No book clubs found');
        }
      } else {
        throw Exception('Failed to load book clubs');
      }
    } catch (e) {
      return [];
    }
  }

  // Get the users bookclubs
  static Future<List<BookClub>> fetchUserBookClubs(String userId) async {
    try {
      final response =
          await https.get(Uri.parse('$backendUrl/user_bookclubs/$userId'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['user_bookclubs'] != null && data['user_bookclubs'] is List) {
          return (data['user_bookclubs'] as List)
              .map((userBookclubs) =>
                  BookClub.fromJson(userBookclubs as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('No user bookclubs found');
        }
      } else {
        throw Exception('Failed to load user bookclubs');
      }
    } catch (e) {
      return [];
    }
  }

  // Add book to the UserBook Table
  Future<bool> addUserBook({
    required String title,
    required String author,
    required String genre,
    required String isbn,
    required String format,
    required String userId,
  }) async {
    try {
      final response = await https.post(
        Uri.parse('$backendUrl/add_user_book/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Title': title,
          'Author': author,
          'Genre': genre,
          'ISBN': isbn,
          'Format': format,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.body);
        return false;
      }
    } catch (e) {
      print("Error API $e");
      return false;
    }
  }

  Future<bool> addBook({
    required String title,
    required String author,
    required String genre,
    required String isbn,
    required String format,
  }) async {
    try {
      final response = await https.post(
        Uri.parse('$backendUrl/add_book'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'Title': title,
          'Author': author,
          'Genre': genre,
          'ISBN': isbn,
          'Format': format,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Sign-in method
  Future<void> googleLogin(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final accessToken = googleAuth.accessToken;

        final response = await https.post(
          Uri.parse('$backendUrl/frontend_login'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'google_id': googleUser.id,
            'email': googleUser.email,
            'displayName': googleUser.displayName,
            'profile_picture': googleUser.photoUrl,
            'access_token': accessToken,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        // Check if the response status is 200 or 201
        if (response.statusCode == 200 || response.statusCode == 201) {
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider.setUserId(googleUser.id as int);

          // Ensure navigation is only triggered after successful login
          Navigator.pushReplacementNamed(context, '/profile');
        } else {
          // Handle non-success status codes
          print('Error: ${response.body}');
          print('Error code: ${response.statusCode}');
        }
      }
    } catch (error, stackTrace) {
      print("Google login error: $error");
      print("Stack trace: $stackTrace");

      if (error is TimeoutException) {
        print("The request timed out");
      } else if (error is SocketException) {
        print("Network error: ${error.message}");
      } else {
        print("Unknown error: $error");
      }
    }
  }

  // Sign out method
  Future<void> logout() async {
    await googleSignIn.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  Future<void> showLoginDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login with Google'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  googleLogin(context);
                },
                child: Text('Login with Google'),
              ),
            ],
          ),
        );
      },
    );
  }
}
