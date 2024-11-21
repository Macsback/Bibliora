import 'package:bibliora/screens/profile_screen.dart';

import '../sections/footer_section.dart';
import '../sections/recommendation_section.dart';
import '../sections/banner_section.dart';
import '../sections/bookclubs_section.dart';
import '../sections/about_section.dart';
import '../sections/reading_list_section.dart';
import '../sections/service_section.dart';
import '../sections/reviews_section.dart';
import 'package:flutter/material.dart';
import '../sections/welcome_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// HomePage
class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F2020),
      //Navigation Bar
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80,
        flexibleSpace: Container(
          height: 80,
          decoration: BoxDecoration(
            boxShadow: [
              // Bottom shadow
              BoxShadow(
                color: Color(0x80089DA1),
                blurRadius: 3,
                spreadRadius: 0,
                offset: Offset(0, 3),
              ),
              // No shadow on the left
              BoxShadow(
                color: Color(0xFF1F2020),
                offset: Offset(-5, 0),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              // No shadow on the right
              BoxShadow(
                color: Color(0xFF1F2020),
                offset: Offset(5, 0),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          //Navigation Elements
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Logo
              Image.asset('assets/logo.png', height: 50),
              Row(
                children: [
                  navLink('Home'),
                  navLink('About'),
                  navLink('Reading Lists'),
                  navLink('Arrivals'),
                  navLink('Reviews'),
                  navLink('Book Clubs'),
                ],
              ),
              //Icons
              Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.person),
                    color: Colors.white,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeSection(),
            ServicesSection(),
            ReadingListSection(),
            ReviewsSection(),
            RecommendationSection(),
            BannerSection(),
            BookClubsSection(),
            AboutSection(),
            FooterSection(),
          ],
        ),
      ),
    );
  }
}

// Navigation link logic
Widget navLink(String title) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8.0),
    child: TextButton(
      onPressed: () {},
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
