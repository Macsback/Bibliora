import 'dart:convert';
import 'package:bibliora/models/book.dart';
import 'package:bibliora/models/user.dart';
import 'package:bibliora/models/bookclubs.dart';
import 'package:http/http.dart' as https;

class ApiService {
  static String baseUrl = "https://bibliorabackend.online/";

  // Get all the Books
  static Future<List<Book>> fetchBooks() async {
    try {
      final response = await https.get(Uri.parse('$baseUrl/books'));

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

  //Get a specific User with the ID
  static Future<User> fetchUserById(int userId) async {
    final response = await https.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception('Failed to load user');
    }
  }

  //Get the users books
  static Future<List<Book>> fetchUserBooks(int userId) async {
    try {
      final response =
          await https.get(Uri.parse('$baseUrl/user_books/$userId'));

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

  //Get all the bookclubs
  static Future<List<BookClub>> fetchBookClubs() async {
    try {
      final response = await https.get(Uri.parse('$baseUrl/bookclubs'));

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
      return []; // Return an empty list in case of error
    }
  }

  //Get the users bookclubs
  static Future<List<BookClub>> fetchUserBookClubs(int userId) async {
    try {
      final response =
          await https.get(Uri.parse('$baseUrl/user_bookclubs/$userId'));

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

  //Add a book to the database
  Future<bool> addBook({
    required String title,
    required String author,
    required String genre,
    required String isbn,
    required String format,
    required int userId,
  }) async {
    try {
      final response = await https.post(
        Uri.parse('$baseUrl/add_book/$userId'),
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
        // Return true if the book was added successfully
        return true;
      } else {
        // Print error and return false if failed
        print('Failed to add book: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle any errors and return false
      print('Error: $e');
      return false;
    }
  }
}
