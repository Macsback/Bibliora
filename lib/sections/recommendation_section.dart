import 'dart:math';
import 'package:bibliora/models/book_grid_view.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:bibliora/models/book.dart';

class RecommendationSection extends StatefulWidget {
  final VoidCallback? onRefresh;
  const RecommendationSection({super.key, this.onRefresh});

  @override
  RecommendationSectionState createState() => RecommendationSectionState();
}

class RecommendationSectionState extends State<RecommendationSection> {
  List<Book> books = [];
  List<double> bookRatings = [];

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      List<Book> fetchedBooks = await ApiService.fetchBooks();
      setState(() {
        books = fetchedBooks;
        bookRatings = List.generate(books.length, (_) {
          return Random().nextDouble() * 5;
        });
      });
    } catch (e) {
      print('Error loading books: $e');
    }
  }

  void refreshBookList() {
    setState(() {
      books.clear();
    });
    loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Suggested for You',
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),
          BooksGridView(
            books: books,
            bookRatings: bookRatings,
            itemCount: books.length,
          ),
        ],
      ),
    );
  }
}
