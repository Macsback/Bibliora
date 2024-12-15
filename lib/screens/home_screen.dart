import 'package:bibliora/constants/colors.dart';
import 'package:bibliora/main.dart';
import 'package:bibliora/screens/books_screen.dart';
import 'package:bibliora/screens/locate_book_screen.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:provider/provider.dart';
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
      backgroundColor: backgroundColor,
      //Navigation Bar
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80,
        flexibleSpace: Container(
          height: 80,
          decoration: BoxDecoration(
            color: backgroundColor,
            boxShadow: [
              // Bottom shadow
              BoxShadow(
                color: boxShadowColor,
                blurRadius: 3,
                spreadRadius: 0,
                offset: Offset(0, 3),
              ),
              // No shadow on the left
              BoxShadow(
                color: boxShadowColor,
                offset: Offset(-5, 0),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              // No shadow on the right
              BoxShadow(
                color: boxShadowColor,
                offset: Offset(5, 0),
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          // Navigation Elements
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Logo
              Image.asset('assets/logo.png', height: 50),
              Row(
                children: [
                  navLink('Home', HomeScreen()),
                  navLink('Books', BooksScreen()),
                  navLink('Reading Lists', ReadingListSection()),
                  navLink('Arrivals', BooksScreen()),
                  navLink('Reviews', ReviewsSection()),
                  navLink('Book Clubs', BookClubsSection()),
                ],
              ),
              // Icons
              Row(
                children: [
                  Icon(
                    Icons.search,
                    color: white,
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.favorite,
                    color: white,
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.location_on),
                    color: white,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LocateBookScreen()),
                    ),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                      icon: Icon(Icons.person),
                      color: white,
                      onPressed: () {
                        ApiService apiService = ApiService();

                        apiService.showLoginDialog(context);
                      }),
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
Widget navLink(String title, Widget destinationScreen) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8.0),
    child: TextButton(
      onPressed: () {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) => destinationScreen),
          );
        } else {
          print("Navigator key's current state is null.");
        }
      },
      child: Text(
        title,
        style: TextStyle(color: white, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
