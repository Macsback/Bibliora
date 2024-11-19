import 'footer_section.dart';
import 'arrivals_section.dart';
import 'banner_section.dart';
import 'bookclubs_section.dart';
import 'about_section.dart';
import 'featured_books_section.dart';
import 'service_section.dart';
import 'reviews_section.dart';
import 'package:flutter/material.dart';
import 'main_section.dart';

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
                  Icon(
                    Icons.person,
                    color: Colors.white,
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
            MainSection(),
            ServicesSection(),
            AboutSection(),
            FeaturedBooksSection(),
            ArrivalSection(),
            ReviewsSection(),
            BannerSection(),
            BookClubsSection(),
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
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: TextButton(
      onPressed: () {},
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
