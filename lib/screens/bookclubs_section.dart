import 'dart:convert';
import 'package:bibliora/models/book_club.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookClubsSection extends StatefulWidget {
  const BookClubsSection({super.key});

  @override
  BookClubsSectionState createState() => BookClubsSectionState();
}

class BookClubsSectionState extends State<BookClubsSection> {
  List<BookClub> bookClubs = [];
  bool isLoading = true;
  String errorMessage = '';

  Future<void> _fetchBookClubs() async {
    try {
      final response =
          await http.get(Uri.parse('https://bibliorabackend.online/bookclubs'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['bookclubs'] != null && data['bookclubs'] is List) {
          setState(() {
            bookClubs = (data['bookclubs'] as List)
                .map((bookJson) => BookClub.fromJson(bookJson))
                .toList();
          });
        } else {
          throw Exception('No book clubs found');
        }
      } else {
        throw Exception('Failed to load book clubs');
      }
    } catch (e) {
      print('Error fetching book clubs: $e');
      setState(() {
        bookClubs = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBookClubs();
  }

  @override
  Widget build(BuildContext context) {
    final imageNames = ['blog_1.jpg', 'blog_2.jpg', 'blog_3.jpg'];
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Center(
            child: Text(
              'Book Clubs',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          if (bookClubs.isEmpty)
            Center(
              child: Text(
                'No book clubs available.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: bookClubs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final club = entry.value;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        color: Color(0xFF1F2020),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x60089DA1),
                            blurRadius: 2,
                            spreadRadius: 3,
                          ),
                        ],
                        border: Border.all(
                          color: Color(0x80089DA1),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // BookClub Image
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/${imageNames[index % imageNames.length]}',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 15),
                          // BookClub Name
                          Text(
                            club.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          // BookClub Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              club.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(height: 20),
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
