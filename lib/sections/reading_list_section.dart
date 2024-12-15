import 'dart:math';

import 'package:bibliora/constants/colors.dart';
import 'package:bibliora/models/book.dart';
import 'package:bibliora/models/book_image.dart';
import 'package:bibliora/screens/add_user_book_screen.dart';
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
  List<double> bookRatings = [];

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).userID;
    loadUserBooks(userId.toString());
  }

  Future<void> loadUserBooks(String userId) async {
    try {
      if (!booksLoaded) {
        List<Book> fetchedBooks = await ApiService.fetchUserBooks(userId);
        setState(() {
          userBooks = fetchedBooks.take(5).toList();
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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    String? userId = userProvider.userID.toString();
    setState(() {
      booksLoaded = false;
      userBooks.clear();
    });
    loadUserBooks(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
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
                  fontSize: 45, fontWeight: FontWeight.w900, color: white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Currently Reading',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: white),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddUserBookScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: userBooks.take(6).map((book) {
                  int bookIndex = userBooks.indexOf(book);
                  double rating = bookRatings[bookIndex];

                  return Padding(
                    padding: EdgeInsets.only(right: 30, left: 20),
                    child: Container(
                      width: 210,
                      height: 370,
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
                          BookImage(coverImageUrl: book.coverImageUrl ?? ''),
                          SizedBox(height: 10),
                          Text(
                            book.title ?? 'Unknown Title',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5),
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
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: generateStars(rating),
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
    });
  }

  List<Widget> generateStars(double rating) {
    int fullStars = rating.floor();
    double fractionalPart = rating - fullStars;

    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: yellowAccent, size: 20));
      } else if (i == fullStars && fractionalPart >= 0.5) {
        stars.add(Icon(Icons.star_half, color: yellowAccent, size: 20));
      } else {
        stars.add(Icon(Icons.star_border, color: yellowAccent, size: 20));
      }
    }
    return stars;
  }
}
