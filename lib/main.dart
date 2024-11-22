import 'package:bibliora/screens/book_locate_screen.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bibliora',
      home: HomeScreen(),
    );
  }
}
