import 'dart:math';
import 'package:bibliora/constants/colors.dart';
import 'package:bibliora/models/book.dart';
import 'package:bibliora/models/book_grid_view.dart';
import 'package:bibliora/screens/add_user_book_screen.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/api_service.dart';

class ReadingListScreen extends StatefulWidget {
  final VoidCallback? onRefresh;

  const ReadingListScreen({super.key, this.onRefresh});

  @override
  ReadingListScreenState createState() => ReadingListScreenState();
}

class ReadingListScreenState extends State<ReadingListScreen> {
  List<Book> userBooks = [];
  bool booksLoaded = false;
  List<double> bookRatings = [];
  bool showRemoveButton = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    String? userId = userProvider.userID.toString();
    loadUserBooks(userId);
  }

  Future<void> loadUserBooks(String userId) async {
    try {
      if (!booksLoaded) {
        List<Book> fetchedBooks = await ApiService.fetchUserBooks(userId);
        setState(() {
          userBooks = fetchedBooks;
          bookRatings = List.generate(userBooks.length, (_) {
            return Random().nextDouble() * 5;
          });
          booksLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading books: $e');
    }
  }

  void refreshReadingList() {
    final userProvider = Provider.of<UserProvider>(context);
    String? userId = userProvider.userID.toString();
    setState(() {
      booksLoaded = false;
      userBooks.clear();
    });
    loadUserBooks(userId);
  }

  // Remove book from both the view and the database
  Future<void> removeBookFromList(Book book) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? userId = userProvider.userID.toString();

    try {
      await ApiService.removeBookFromUser(userId, book.title.toString());
      setState(() {
        userBooks.remove(book);
      });
    } catch (e) {
      print('Error removing book: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          title: Text(
            'Your Reading List',
            style: TextStyle(color: white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          color: backgroundColor,
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddUserBookScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        '+ Add Books',
                        style: TextStyle(
                          color: white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                BooksGridView(
                  books: userBooks,
                  bookRatings: bookRatings,
                  itemCount: userBooks.length,
                  removeBook: showRemoveButton ? removeBookFromList : null,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
