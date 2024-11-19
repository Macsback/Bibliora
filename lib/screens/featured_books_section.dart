import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bibliora/models/book.dart';

class FeaturedBooksSection extends StatefulWidget {
  const FeaturedBooksSection({super.key});

  @override
  FeaturedBooksSectionState createState() => FeaturedBooksSectionState();
}

class FeaturedBooksSectionState extends State<FeaturedBooksSection> {
  List<Book> books = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  _fetchBooks() async {
    try {
      final response =
          await http.get(Uri.parse('https://bibliorabackend.online/books'));

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
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your Reading List',
            style: TextStyle(
                fontSize: 45, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: books.take(6).map((book) {
                String imageAsset =
                    'assets/${(book.title ?? '').replaceAll(RegExp(r'\s+'), '_').toLowerCase()}.jpg';
                return Padding(
                  padding: const EdgeInsets.only(right: 30, left: 20),
                  child: Container(
                    width: 210,
                    height: 350,
                    decoration: BoxDecoration(
                      color: Color(0xFF1F2020),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x80089DA1),
                          blurRadius: 2,
                          spreadRadius: 3,
                        ),
                      ],
                      border: Border.all(
                        color: Color(
                            0x80089DA1), // Border color (similar to shadow color)
                        width: 2, // Border width
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Book cover
                        Image.asset(
                          imageAsset,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 10),
                        // Title
                        Text(
                          book.title ?? 'Unknown Title',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        // Author name
                        Text(
                          book.author ?? 'Unknown Author',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14, // Smaller author text
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        // Genres
                        for (var genre in (book.genres ?? []).take(3))
                          Text(
                            genre,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
