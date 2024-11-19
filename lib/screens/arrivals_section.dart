import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bibliora/models/book.dart';

class ArrivalSection extends StatefulWidget {
  const ArrivalSection({super.key});

  @override
  ArrivalSectionState createState() => ArrivalSectionState();
}

class ArrivalSectionState extends State<ArrivalSection> {
  List<Book> books = [];
  List<double> bookRatings = [4.5, 3.0, 5.0, 4.0, 4.5, 3.5, 4.0, 4.5, 5.0, 3.5];

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
      padding: const EdgeInsets.all(20),
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
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 30,
              childAspectRatio: 0.75,
            ),
            itemCount: books.length < 10 ? books.length : 10,
            itemBuilder: (context, index) {
              var book = books[index];
              String imageAsset =
                  'assets/${(book.title ?? '').replaceAll(RegExp(r'\s+'), '_').toLowerCase()}.jpg';
              double rating = bookRatings[index];
              return Padding(
                padding: const EdgeInsets.only(right: 30, left: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Image.asset(
                            imageAsset,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 10),
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
                          const SizedBox(height: 5),
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
                          const SizedBox(height: 5),
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
                          // Star ratings
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: generateStars(rating),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Generates Stars for rating
  List<Widget> generateStars(double rating) {
    int fullStars = rating.floor();
    double fractionalPart = rating - fullStars;

    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.yellowAccent, size: 20));
      } else if (i == fullStars && fractionalPart >= 0.5) {
        stars.add(Icon(Icons.star_half, color: Colors.yellowAccent, size: 20));
      } else {
        stars
            .add(Icon(Icons.star_border, color: Colors.yellowAccent, size: 20));
      }
    }
    return stars;
  }
}
