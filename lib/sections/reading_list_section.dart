import 'package:bibliora/models/book.dart';
import 'package:bibliora/screens/add_book_screen.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:flutter/material.dart';
import '../service/api_service.dart';
import 'package:provider/provider.dart';

class ReadingListSection extends StatefulWidget {
  final VoidCallback? onRefresh;

  const ReadingListSection({super.key, this.onRefresh});

  @override
  ReadingListSectionState createState() => ReadingListSectionState();
}

class ReadingListSectionState extends State<ReadingListSection> {
  List<Book> userBooks = [];
  bool booksLoaded = false;

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).userID;
    loadUserBooks(userId);
  }

  Future<void> loadUserBooks(int userId) async {
    try {
      if (!booksLoaded) {
        List<Book> fetchedBooks = await ApiService.fetchUserBooks(userId);
        setState(() {
          userBooks = fetchedBooks;
          booksLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading books: $e');
    }
  }

  void refreshReadingList() {
    final userId = Provider.of<UserProvider>(context, listen: false).userID;
    setState(() {
      booksLoaded = false;
      userBooks.clear();
    });
    loadUserBooks(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Book Lists',
                style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Currently Reading',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddBookScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF089DA1),
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
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: userBooks.take(6).map((book) {
                    String imageAsset =
                        'assets/${(book.title ?? '').replaceAll(RegExp(r'\s+'), '_').toLowerCase()}.jpg';
                    return Padding(
                      padding: EdgeInsets.only(right: 30, left: 20),
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
                            color: Color(0x80089DA1),
                            width: 2,
                          ),
                        ),
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Book cover
                            Image.asset(
                              imageAsset,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 10),
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
                            SizedBox(height: 5),
                            // Author name
                            Text(
                              book.author ?? 'Unknown Author',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 5),
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
      },
    );
  }
}
