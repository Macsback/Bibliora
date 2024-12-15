import 'dart:convert';

import 'package:bibliora/constants/colors.dart';
import 'package:bibliora/sections/reading_list_section.dart';
import 'package:bibliora/sections/user_bookclubs_section.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:flutter/scheduler.dart';
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
  String profilePicture = 'Unknown Picture';

  ApiService apiService = ApiService();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchUser();
    });
  }

  Future<void> _fetchUser() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String? userId = userProvider.userID.toString();

      print("userid: $userId");

      final user = await ApiService.fetchUserById(userId);
      print("User: $user");

      final imageBytes =
          await ApiService.fetchImageFromBackend(user.profilePicture);
      String base64Image = imageBytes != null
          ? base64Encode(imageBytes)
          : 'assets/profile-picture.png';

      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          userName = user.username;
          userEmail = user.email;
          memberSince = user.memberSince;
          profilePicture = base64Image;
        });
      });
    } catch (e, stackTrace) {
      print('Error loading user: $e');
      print('StackTrace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: white,
        ),
        backgroundColor: backgroundColor,
        title: Text(
          'Profile Page',
          style: TextStyle(color: white),
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
                        backgroundImage: NetworkImage(profilePicture),
                      ),
                      SizedBox(height: 16),
                      Text(
                        userName,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: white),
                      ),
                      Text(userEmail,
                          style: TextStyle(fontSize: 16, color: white)),
                      Text('Member Since: $memberSince',
                          style: TextStyle(fontSize: 16, color: white)),
                    ],
                  ),
                ),
              ),
              ReadingListSection(),
              UserBookClubsSection()
            ],
          ),
        ),
      ),
    );
  }
}
