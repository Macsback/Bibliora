import 'package:bibliora/sections/reading_list_section.dart';
import 'package:bibliora/sections/user_bookclubs_section.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Unknown Name';
  String userEmail = 'Unknown Email';
  String memberSince = 'Unknown Date';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      int userId = Provider.of<UserProvider>(context, listen: false).userID;
      final user = await ApiService.fetchUserById(userId);
      setState(() {
        userName = user.username;
        userEmail = user.email;
        memberSince = user.memberSince;
      });
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1F2020),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF1F2020),
        title: Text(
          'Profile Page',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Info Section
              Container(
                padding: EdgeInsets.all(16.0),
                margin: EdgeInsets.only(bottom: 16.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 75,
                        backgroundImage:
                            AssetImage('assets/profile-picture.png'),
                      ),
                      SizedBox(height: 16),
                      Text(
                        userName,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(userEmail,
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      Text('Member Since: $memberSince',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      SizedBox(height: 16),
                      Text('Actions',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF089DA1)),
                            child: Text('Edit Profile',
                                style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF089DA1)),
                            child: Text('Change Password',
                                style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF089DA1)),
                            child: Text('Logout',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Reading List Section
              Container(
                  padding: EdgeInsets.all(16.0),
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: ReadingListSection()),

              // Book Clubs Section
              Container(
                  padding: EdgeInsets.all(16.0),
                  margin: EdgeInsets.only(bottom: 16.0),
                  child: UserBookClubsSection()),

              // Footer Section
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '© 2024 Bibliora | All Rights Reserved',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}