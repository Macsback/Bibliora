import 'package:bibliora/models/bookclubs.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserBookClubsSection extends StatefulWidget {
  const UserBookClubsSection({super.key});

  @override
  UserBookClubsSectionState createState() => UserBookClubsSectionState();
}

class UserBookClubsSectionState extends State<UserBookClubsSection> {
  List<BookClub> userBookClubs = [];

  @override
  void initState() {
    super.initState();
    loadUserBookClubs();
  }

  Future<void> loadUserBookClubs() async {
    try {
      final userProvider = Provider.of<UserProvider>(context);
      int? userId = userProvider.userID;

      List<BookClub> fetchedUserBookClubs =
          await ApiService.fetchUserBookClubs(userId.toString());
      setState(() {
        userBookClubs = fetchedUserBookClubs;
      });
    } catch (e) {
      print('Error loading book clubs: $e');
    }
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
              'Your Book Clubs',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          if (userBookClubs.isEmpty)
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
                children: userBookClubs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final club = entry.value;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
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
                            club.bookClubName ?? 'Unknown Name',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          // BookClub Description
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              club.description ?? 'Unknown Description',
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
