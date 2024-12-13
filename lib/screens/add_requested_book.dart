import 'package:bibliora/constants/colors.dart';
import 'package:bibliora/screens/home_screen.dart';
import 'package:bibliora/sections/recommendation_section.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  AddBookScreenState createState() => AddBookScreenState();
}

class AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();

  String selectedFormat = "physical";

  final GlobalKey<RecommendationSectionState> bookListKey = GlobalKey();

  String? _titleError;
  String? _authorError;
  String? _genreError;
  String? _isbnError;

  bool _validateInputs() {
    bool isValid = true;

    setState(() {
      _titleError = _titleController.text.isEmpty ? 'Title is required' : null;
      _authorError =
          _authorController.text.isEmpty ? 'Author is required' : null;
      _genreError = _genreController.text.isEmpty ? 'Genre is required' : null;
      _isbnError = _isbnController.text.isEmpty ? 'ISBN is required' : null;
    });

    // Check if ISBN contains exactly 13 digits
    String isbn = _isbnController.text.trim();
    if (isbn.isNotEmpty) {
      if (isbn.length != 13) {
        setState(() {
          _isbnError = 'ISBN must be exactly 13 digits';
        });
        isValid = false;
      }
    }

    return isValid;
  }

  void _addBook() async {
    try {
      if (_validateInputs()) {
        final String title = _titleController.text.trim();
        final String author = _authorController.text.trim();
        final String genre = _genreController.text.trim();
        final String isbn = _isbnController.text.trim();
        final String format = selectedFormat;

        ApiService().addBook(
          title: title,
          author: author,
          genre: genre,
          isbn: isbn,
          format: format,
        );

        // Clear the fields after request is completed
        _titleController.clear();
        _authorController.clear();
        _genreController.clear();
        _isbnController.clear();

        // Reset error messages
        setState(() {
          _titleError = null;
          _authorError = null;
          _genreError = null;
          _isbnError = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully added the book'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add book')),
      );
    }
  }

  void refreshBookList() {
    bookListKey.currentState?.refreshBookList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
          ),
          IconButton(onPressed: refreshBookList, icon: Icon(Icons.refresh))
        ],
        backgroundColor: backgroundColor,
        title: Text(
          'Add new Book',
          style: TextStyle(color: white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                color: backgroundColor,
                elevation: 5,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Add a New Book",
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Title
                      TextField(
                        controller: _titleController,
                        style: TextStyle(color: white),
                        cursorColor: white,
                        decoration: InputDecoration(
                          labelText: "Title",
                          labelStyle: TextStyle(color: white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: white),
                          ),
                        ),
                      ),
                      if (_titleError != null)
                        Text(
                          _titleError!,
                          style: TextStyle(color: red),
                        ),
                      SizedBox(height: 16),

                      // Author
                      TextField(
                        controller: _authorController,
                        style: TextStyle(color: white),
                        cursorColor: white,
                        decoration: InputDecoration(
                          labelText: "Author",
                          labelStyle: TextStyle(color: white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: white),
                          ),
                        ),
                      ),
                      if (_authorError != null)
                        Text(
                          _authorError!,
                          style: TextStyle(color: red),
                        ),
                      SizedBox(height: 16),

                      // Genre
                      TextField(
                        controller: _genreController,
                        style: TextStyle(color: white),
                        cursorColor: white,
                        decoration: InputDecoration(
                          labelText: "Genre",
                          labelStyle: TextStyle(color: white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: white),
                          ),
                        ),
                      ),
                      if (_genreError != null)
                        Text(
                          _genreError!,
                          style: TextStyle(color: red),
                        ),
                      SizedBox(height: 16),

                      // ISBN
                      TextField(
                        controller: _isbnController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        style: TextStyle(color: white),
                        cursorColor: white,
                        decoration: InputDecoration(
                          labelText: "ISBN",
                          labelStyle: TextStyle(color: white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: white),
                          ),
                        ),
                      ),
                      if (_isbnError != null)
                        Text(
                          _isbnError!,
                          style: TextStyle(color: red),
                        ),
                      SizedBox(height: 16),

                      // Format
                      SizedBox(
                        height: 56,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Format: ",
                              style: TextStyle(
                                fontSize: 16,
                                color: white,
                              ),
                            ),
                            SizedBox(width: 16),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedFormat = "physical";
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: "physical",
                                        groupValue: selectedFormat,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedFormat = value!;
                                          });
                                        },
                                        activeColor: white,
                                      ),
                                      Text(
                                        "Physical",
                                        style: TextStyle(
                                          color: white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedFormat = "digital";
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Radio<String>(
                                        value: "digital",
                                        groupValue: selectedFormat,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedFormat = value!;
                                          });
                                        },
                                        activeColor: white,
                                      ),
                                      Text(
                                        "Digital",
                                        style: TextStyle(
                                          color: white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Add Book Button
                      ElevatedButton(
                        onPressed: _addBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          minimumSize: Size(double.infinity, 56),
                        ),
                        child: Text(
                          "Add Book",
                          style: TextStyle(color: white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RecommendationSection(
                key: bookListKey,
                onRefresh: refreshBookList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
