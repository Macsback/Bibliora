import 'dart:convert';
import 'dart:typed_data';
import 'package:bibliora/models/book.dart';
import 'package:bibliora/models/user.dart';
import 'package:bibliora/models/bookclubs.dart';
import 'package:bibliora/service/config_manager.dart';
import 'package:http/http.dart' as https;

class ApiService {
  static String backendUrl = ConfigManager.getConfigValue('BACKEND_URL');

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
      print('Error fetching books: $e');
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
        print("Failed to fetch image: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching image: $e");
      return null;
    }
  }

  // Get a specific User with the ID
  static Future<User> fetchUserById(int userId) async {
    final response = await https.get(Uri.parse('$backendUrl/users/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to load user');
    }
  }

  // Get the users books
  static Future<List<Book>> fetchUserBooks(int userId) async {
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
      print('Error fetching user books: $e');
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
      print('Error fetching book clubs: $e');
      return [];
    }
  }

  // Get the users bookclubs
  static Future<List<BookClub>> fetchUserBookClubs(int userId) async {
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
      print('Error fetching user bookclubs: $e');
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
    required int userId,
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
        print('Failed to add book: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
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
        print('Failed to add book: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
