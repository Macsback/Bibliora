import 'dart:math';
import 'package:bibliora/models/book_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:bibliora/constants/colors.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:bibliora/models/book.dart';

class BooksScreen extends StatefulWidget {
  final VoidCallback? onRefresh;
  const BooksScreen({super.key, this.onRefresh});

  @override
  BooksScreenState createState() => BooksScreenState();
}

class BooksScreenState extends State<BooksScreen> {
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
                'Book Collection',
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
