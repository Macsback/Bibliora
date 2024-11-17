import 'package:bibliora/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  UsersScreenState createState() => UsersScreenState();
}

class UsersScreenState extends State<UsersScreen> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  _fetchUsers() async {
    final response = await http.get(Uri.parse('http://52.87.5.217:5000/users'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['users'] != null && data['users'] is List) {
        setState(() {
          users = (data['users'] as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();
        });
      } else {
        throw Exception('Unexpected data format for users');
      }
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Username: ${users[index].username}'),
                  subtitle: Text('E-Mail ${users[index].email}'),
                );
              },
            ),
    );
  }
}
