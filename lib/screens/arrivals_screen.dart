import 'dart:math';
import 'package:bibliora/models/book_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:bibliora/constants/colors.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:bibliora/models/book.dart';

class ArrivalsScreen extends StatefulWidget {
  final VoidCallback? onRefresh;
  const ArrivalsScreen({super.key, this.onRefresh});

  @override
  ArrivalsScreenState createState() => ArrivalsScreenState();
}

class ArrivalsScreenState extends State<ArrivalsScreen> {
  List<Book> books = [];
  List<double> bookRatings = [];
  bool showPublishDate = true;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      List<Book> fetchedBooks = await ApiService.fetchBooks();

      fetchedBooks.sort((a, b) {
        String yearA = a.publishYear ?? '';
        String yearB = b.publishYear ?? '';

        return yearB.compareTo(yearA);
      });

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
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: white,
        ),
        backgroundColor: backgroundColor,
        title: Text(
          '',
          style: TextStyle(color: white),
        ),
        centerTitle: true,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'New Book Arrivals',
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
        ),
      ),
    );
  }
}
