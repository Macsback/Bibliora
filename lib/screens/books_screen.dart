import 'package:bibliora/models/book.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List books = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  _fetchBooks() async {
    final response = await http.get(Uri.parse('http://52.87.5.217:5000/books'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['books'] != null && data['books'] is List) {
        setState(() {
          books = (data['books'] as List)
              .map((bookJson) => Book.fromJson(bookJson))
              .toList();
        });
      } else {
        throw Exception('No books found');
      }
    } else {
      throw Exception('Failed to load books');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Books')),
      body: books.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(books[index].title),
                  subtitle: Text(
                      'Title: ${books[index].title}\nDescription: ${books[index].description}\nAuthor: ${books[index].author}\nGenres: ${books[index].genres}\nISBN: ${books[index].isbn}\nBorrow Link: ${books[index].borrowLink}\nFormat: ${books[index].format}\nIs Available for Borrow: ${books[index].isAvailableForBorrow}'),
                  isThreeLine: true, // Allows multiple lines in the subtitle
                );
              },
            ),
    );
  }
}
