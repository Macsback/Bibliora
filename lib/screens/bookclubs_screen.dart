import 'package:bibliora/models/bookClub.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookClubsScreen extends StatefulWidget {
  const BookClubsScreen({super.key});

  @override
  _BookClubsScreenState createState() => _BookClubsScreenState();
}

class _BookClubsScreenState extends State<BookClubsScreen> {
  List<BookClub> bookClubs = [];

  @override
  void initState() {
    super.initState();
    _fetchBookClubs();
  }

  _fetchBookClubs() async {
    final response =
        await http.get(Uri.parse('http://52.87.5.217:5000/bookclubs'));

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Clubs')),
      body: bookClubs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookClubs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Name: ${bookClubs[index].name}'),
                  subtitle:
                      Text('Description: ${bookClubs[index].description}'),
                );
              },
            ),
    );
  }
}
