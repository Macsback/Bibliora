import 'package:bibliora/screens/bookclubs_screen.dart';
import 'package:bibliora/screens/books_screen.dart';
import 'package:bibliora/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bibliora',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      routes: {
        '/books': (context) => BooksScreen(),
        '/users': (context) => UsersScreen(),
        '/bookClubs': (context) => BookClubsScreen(),
      },
    );
  }
}
