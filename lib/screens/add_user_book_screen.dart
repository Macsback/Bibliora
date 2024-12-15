import 'package:bibliora/constants/colors.dart';
import 'package:bibliora/models/book.dart';
import 'package:bibliora/models/search_dropdown.dart';
import 'package:bibliora/screens/add_requested_book.dart';
import 'package:bibliora/sections/reading_list_section.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class AddUserBookScreen extends StatefulWidget {
  const AddUserBookScreen({super.key});

  @override
  AddUserBookScreenState createState() => AddUserBookScreenState();
}

class AddUserBookScreenState extends State<AddUserBookScreen> {
  String? selectedISBN;
  String? selectedTitle;
  String? selectedAuthor;
  String? selectedGenre;

  List<Book> books = [];
  List<String> filteredTitles = [];
  List<String> filteredAuthors = [];
  List<String> filteredGenres = [];
  List<String> filteredISBN = [];

  String selectedFormat = "physical";

  final GlobalKey<ReadingListSectionState> _readingListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  // Fetch book Title and Author
  Future<void> fetchBooks() async {
    try {
      List<Book> fetchedBooks = await ApiService.fetchBooks();
      setState(() {
        books = fetchedBooks;
        filteredTitles = books.map((book) => book.title!).toList();
        filteredAuthors = books.map((book) => book.author!).toList();
        filteredGenres = books
            .expand((book) => book.genres ?? [])
            .toSet()
            .toList()
            .cast<String>();
        filteredISBN = books.map((book) => book.isbn!).toList();
      });
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  // Filter ISBN
  void filterISBN(String query) {
    setState(() {
      List<String> results = books
          .where((book) => (book.isbn?.contains(query) ?? false))
          .map((book) => book.isbn ?? '')
          .toList();
      filteredISBN = results;
    });
  }

  // Filter Author
  void filterAuthors(String query) {
    setState(() {
      List<String> results = books
          .where((book) =>
              (book.author?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .map((book) => book.author ?? '')
          .toList();
      filteredAuthors = results;
    });
  }

  // Filter Title
  void filterTitles(String query) {
    setState(() {
      List<String> results = books
          .where((book) =>
              (book.title?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .map((book) => book.title ?? '')
          .toList();
      filteredTitles = results;
    });
  }

  // Filter Genre
  void filterGenres(String query) {
    setState(() {
      List<String> results = books
          .expand((book) => (book.genres ?? []).where(
              (genre) => genre.toLowerCase().contains(query.toLowerCase())))
          .toSet()
          .toList();
      filteredGenres = results;
    });
  }

  void addUserBook() async {
    try {
      if (selectedISBN != null &&
          selectedTitle != null &&
          selectedAuthor != null &&
          selectedGenre != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        String? userId = userProvider.userID.toString();

        await ApiService().addUserBook(
          userId: userId,
          title: selectedTitle!,
          author: selectedAuthor!,
          genre: selectedGenre!,
          isbn: selectedISBN!,
          format: selectedFormat,
        );

        setState(() {
          selectedISBN = null;
          selectedTitle = null;
          selectedAuthor = null;
          selectedGenre = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully added the book to your collection'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select all fields before adding a book.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book was already added')),
      );
      print(e);
    }
  }

  void selectedItem(String selectedValue, String type) {
    setState(() {
      if (type == 'isbn') {
        selectedISBN = selectedValue;
      } else if (type == 'title') {
        selectedTitle = selectedValue;
      } else if (type == 'author') {
        selectedAuthor = selectedValue;
      } else if (type == 'genre') {
        selectedGenre = selectedValue;
      }
    });
  }

  void refreshReadingList() {
    _readingListKey.currentState?.refreshReadingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: white),
        backgroundColor: backgroundColor,
        title: Text(
          'Add to Reading list',
          style: TextStyle(color: white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshReadingList,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                color: backgroundColor,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                      const SizedBox(height: 16),
                      SearchDropdown(
                        selectedItem: selectedTitle,
                        filterItems: (filter) {
                          filterTitles(filter);
                          return filteredTitles;
                        },
                        fillColor: const Color(0xFF4c4d4d),
                        onItemSelected: (selectedTitle) {
                          setState(() {
                            this.selectedTitle = selectedTitle;
                            Book? selectedBook = books.firstWhereOrNull(
                              (book) => book.title == selectedTitle,
                            ); // Find the matching book
                            selectedISBN = selectedBook?.isbn;
                            selectedAuthor = selectedBook?.author;
                            selectedGenre = selectedBook?.genres?.join(', ');
                          });
                        },
                        hintText: 'Search Title...',
                      ),
                      const SizedBox(height: 16),
                      SearchDropdown(
                        selectedItem: selectedISBN,
                        filterItems: (filter) {
                          filterISBN(filter);
                          return filteredISBN;
                        },
                        fillColor: const Color(0xFF4c4d4d),
                        onItemSelected: (selectedISBN) {
                          setState(() {
                            this.selectedISBN = selectedISBN;
                            Book? selectedBook = books.firstWhereOrNull(
                              (book) => book.isbn == selectedISBN,
                            ); // Find the matching book
                            selectedTitle = selectedBook?.title;
                            selectedAuthor = selectedBook?.author;
                            selectedGenre = selectedBook?.genres?.join(', ');
                          });
                        },
                        hintText: 'Search ISBN...',
                      ),
                      const SizedBox(height: 16),
                      // Author Dropdown
                      SearchDropdown(
                        selectedItem: selectedAuthor,
                        filterItems: (filter) {
                          filterAuthors(filter);
                          return filteredAuthors;
                        },
                        fillColor: Color(0xFF4c4d4d),
                        onItemSelected: (selectedAuthor) {
                          setState(() {
                            this.selectedAuthor = selectedAuthor;
                          });
                        },
                        hintText: 'Search Author...',
                      ),
                      const SizedBox(height: 16),
                      // Genre Dropdown
                      SearchDropdown(
                        selectedItem: selectedGenre,
                        filterItems: (filter) {
                          filterGenres(filter);
                          return filteredGenres;
                        },
                        fillColor: Color(0xFF4c4d4d),
                        onItemSelected: (selectedGenre) {
                          setState(() {
                            this.selectedGenre = selectedGenre;
                          });
                        },
                        hintText: 'Search Genre...',
                      ),
                      SizedBox(height: 16),
                      // Format Selection
                      SizedBox(
                        height: 56,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Format: ",
                              style: TextStyle(fontSize: 18, color: white),
                            ),
                            const SizedBox(width: 20),
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
                                            color: white, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
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
                                            color: white, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Add Book Button
                      ElevatedButton(
                        onPressed: addUserBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: boxShadowColor,
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        child: Text(
                          "Add Book",
                          style: TextStyle(color: white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          text: "Book not found? No problem, ",
                          style: TextStyle(color: white, fontSize: 16),
                          children: [
                            TextSpan(
                              text: "add a new book here.",
                              style: TextStyle(
                                color: boxShadowColor,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddBookScreen()));
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ReadingListSection(
                key: _readingListKey,
                onRefresh: refreshReadingList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
