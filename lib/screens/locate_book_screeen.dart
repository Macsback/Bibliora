import 'dart:convert';
import 'package:bibliora/service/config_manager.dart';
import 'package:http/http.dart' as http;
import 'package:bibliora/models/book.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:pubnub/pubnub.dart';

class LocateBookScreen extends StatefulWidget {
  const LocateBookScreen({super.key});

  @override
  LocateBookScreenState createState() => LocateBookScreenState();
}

class LocateBookScreenState extends State<LocateBookScreen> {
  late List<Book> books;
  late List<String> filteredBooks;

  TextEditingController searchController = TextEditingController();

  String status = "Idle";
  late PubNub pubnub;
  late Subscription subscription;

  // Fetch books from Backend
  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).userID;
    _fetchUserBooks(userId);

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
      print('Received message: ${message.content}');
      setState(() {
        status = message.content.toString();
      });
    });
  }

  // Function to fetch books
  Future<void> _fetchUserBooks(int userId) async {
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
      final response = await http.post(
        Uri.parse('$backendUrl/trigger'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status code: ${response.statusCode}');
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
          status = "Your Book was found. Congratulations!";
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
          color: Colors.white,
        ),
        title: Text(
          'Locate your Book',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1F2020),
      ),
      body: Container(
        width: double.infinity,
        color: Color(0xFF1F2020),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 90),
            Icon(
              Icons.book_outlined,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Find your favorite books easily!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Tooltip(
                  message:
                      "Press 'Locate Book' to light up an \nLED and trigger a small vibration \nto show the book's location.",
                  textStyle: TextStyle(fontSize: 16, color: Colors.white),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Icon(
                    Icons.help_outline,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            // DropdownSearch to search for user books
            SizedBox(
              width: 350,
              child: DropdownSearch<String>(
                dropdownBuilder: (context, selectedItem) {
                  return Text(
                    selectedItem ?? "",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  );
                },

                items: (filter, infiniteScrollProps) {
                  filterBooks(filter);
                  return filteredBooks;
                },
                filterFn: (item, search) {
                  return item.toLowerCase().contains(search.toLowerCase());
                },
                suffixProps: DropdownSuffixProps(
                  dropdownButtonProps: DropdownButtonProps(
                    iconClosed: Icon(Icons.keyboard_arrow_down),
                    color: Colors.white,
                    iconOpened: Icon(
                      Icons.keyboard_arrow_up,
                      color: Colors.white,
                    ),
                  ),
                ),
                decoratorProps: DropDownDecoratorProps(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 20),
                    filled: true,
                    fillColor: Color(0xFFD76004),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    hintText: 'Search for a book...',
                    hintStyle: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                // Book Items
                popupProps: PopupProps.menu(
                  searchDelay: Duration(microseconds: 200),
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      hintText: 'Search books...',
                      hintStyle: TextStyle(fontSize: 18, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      contentPadding: EdgeInsets.all(12),
                      filled: true,
                      fillColor: Colors.white24,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                    ),
                    cursorColor: Colors.white24,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  itemBuilder: (context, item, isDisabled, isSelected) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  constraints: BoxConstraints(maxHeight: 250),
                  menuProps: MenuProps(
                    backgroundColor: Color(0xFF4c4d4d),
                    margin: EdgeInsets.only(top: 12),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  scrollbarProps: ScrollbarProps(trackVisibility: true),
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: triggerAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF089DA1),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Locate your Book',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              status,
              style: TextStyle(color: Colors.white, fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}
