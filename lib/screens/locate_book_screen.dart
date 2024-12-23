import 'dart:convert';
import 'package:bibliora/constants/colors.dart';
import 'package:bibliora/models/search_dropdown.dart';
import 'package:bibliora/service/config_manager.dart';
import 'package:http/http.dart' as https;
import 'package:bibliora/models/book.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pubnub/pubnub.dart';

class LocateBookScreen extends StatefulWidget {
  const LocateBookScreen({super.key});

  @override
  LocateBookScreenState createState() => LocateBookScreenState();
}

class LocateBookScreenState extends State<LocateBookScreen> {
  List<Book> books = [];
  List<String> filteredBooks = [];

  String? selectedValue;
  String message = "";

  TextEditingController searchController = TextEditingController();

  String status = "Idle";
  late PubNub pubnub;
  late Subscription subscription;

  @override
  void initState() {
    super.initState();

    // Initialize PubNub
    pubnub = PubNub(
      defaultKeyset: Keyset(
        subscribeKey: ConfigManager.getConfigValue('PUBNUB_SUBSCRIBE_KEY'),
        publishKey: ConfigManager.getConfigValue('PUBNUB_PUBLISH_KEY'),
        userId: UserId(ConfigManager.getConfigValue('PUBNUB_USER_ID')),
      ),
    );

    // Subscribe to the channel
    subscription = pubnub
        .subscribe(channels: {ConfigManager.getConfigValue('PUBNUB_CHANNEL')});

    // Listen for messages
    subscription.messages.listen((message) {
      print("Received message: ${message.payload}");
      String newStatus = message.payload['status'] ?? 'No status';
      String newMessage = message.payload['message'] ?? 'No message';

      setState(() {
        status = newStatus;
        this.message = newMessage;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    String userId =
        Provider.of<UserProvider>(context, listen: false).userID.toString();
    fetchUserBooks(userId);
  }

  // Function to fetch books
  Future<void> fetchUserBooks(String userId) async {
    try {
      List<Book> fetchedBooks = await ApiService.fetchUserBooks(userId);
      setState(() {
        books = fetchedBooks;
        filteredBooks =
            books.map((book) => '${book.title} by ${book.author}').toList();
      });
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  // Function to filter books
  void filterBooks(String query) {
    List<String> results = books
        .where((book) =>
            (book.title?.toLowerCase().contains(query.toLowerCase()) ??
                false) ||
            (book.author?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .map((book) => '${book.title} by ${book.author}')
        .toList();
    setState(() {
      filteredBooks = results;
    });
  }

  // Function to trigger the action and send PubNub message
  Future<void> triggerAction() async {
    String backendUrl = ConfigManager.getConfigValue('BACKEND_URL') ?? '';

    try {
      final response = await https.post(
        Uri.parse('$backendUrl/trigger'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response body: ${response.body}');

      // Check if the response body is empty
      if (response.body.isEmpty) {
        setState(() {
          status = "Received empty response from server!";
        });
        return;
      }

      final data = jsonDecode(response.body);

      if (data['message'] == 'Success') {
        setState(() {
          print('Response status code: ${response.statusCode}');
          status = "Your Book was found. Congratulation!";
        });
      } else {
        setState(() {
          status = "Error triggering LED and Buzzer!";
        });
      }
    } catch (error) {
      print("Error: $error");
      setState(() {
        status = "Error occurred while triggering.";
      });
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: white,
        ),
        title: Text(
          'Locate your Book',
          style: TextStyle(color: white),
        ),
        backgroundColor: backgroundColor,
      ),
      body: Container(
        width: double.infinity,
        color: backgroundColor,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 90),
            Icon(
              Icons.book_outlined,
              size: 100,
              color: white,
            ),
            SizedBox(height: 20),
            Text(
              'Find your favorite books easily!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: white,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Misplaced your book? Find it with Bibliora's Locate Feature!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    color: white,
                  ),
                ),
                SizedBox(width: 10),
                Tooltip(
                  message:
                      "Press 'Locate Book' to light up an \nLED and trigger a small vibration \nto show the book's location.",
                  textStyle: TextStyle(fontSize: 16, color: white),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Icon(
                    Icons.help_outline,
                    color: white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            // DropdownSearch to search for user books
            SizedBox(
              width: 350,
              child: SearchDropdown(
                selectedItem: selectedValue,
                filterItems: (filter) {
                  filterBooks(filter);
                  return filteredBooks;
                },
                fillColor: orange,
                onItemSelected: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: triggerAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Locate your Book',
                style: TextStyle(
                  color: white,
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              status,
              style: TextStyle(color: white, fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}
