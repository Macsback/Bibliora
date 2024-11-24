import 'package:bibliora/models/book.dart';
import 'package:bibliora/models/search_dropdown.dart';
import 'package:bibliora/sections/reading_list_section.dart';
import 'package:bibliora/service/api_service.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  AddBookScreenState createState() => AddBookScreenState();
}

class AddBookScreenState extends State<AddBookScreen> {
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

  // Filter ISBN
  void filterISBN(String query) {
    List<String> results = books
        .where((book) => (book.isbn?.contains(query) ?? false))
        .map((book) => book.isbn ?? '')
        .toList();
    setState(() {
      filteredISBN = results;
    });
  }

  // Fetch book ISBN
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

  // Filter Author
  void filterAuthors(String query) {
    List<String> results = books
        .where((book) =>
            (book.author?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .map((book) => book.author ?? '')
        .toList();
    setState(() {
      filteredAuthors = results;
    });
  }

  void filterTitles(String query) {
    List<String> results = books
        .where((book) =>
            (book.title?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .map((book) => book.title ?? '')
        .toList();
    setState(() {
      filteredTitles = results;
    });
  }

  void filterGenres(String query) {
    List<String> results = books
        .expand((book) => (book.genres ?? []).where(
            (genre) => genre.toLowerCase().contains(query.toLowerCase())))
        .toSet()
        .toList();
    setState(() {
      filteredGenres = results;
    });
  }

  void addBook() async {
    try {
      if (selectedISBN != null &&
          selectedTitle != null &&
          selectedAuthor != null &&
          selectedGenre != null) {
        int userId = Provider.of<UserProvider>(context, listen: false).userID;

        await ApiService().addBook(
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
            content: Text('Successfully added the book to your reading list'),
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
        const SnackBar(content: Text('Failed to add book')),
      );
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

  void _refreshReadingList() {
    _readingListKey.currentState?.refreshReadingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2020),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF1F2020),
        title: const Text(
          'Add Books Page',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReadingList,
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
                color: const Color(0xFF1F2020),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Add a New Book",
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // ISBN
                      SearchDropdown(
                        filterItems: (filter) {
                          filterISBN(filter);
                          return filteredISBN;
                        },
                        fillColor: Color(0xFF4c4d4d),
                        onItemSelected: (selectedValue) {
                          selectedItem(selectedValue, 'isbn');
                        },
                        hintText: 'Search ISBN...',
                      ),
                      SizedBox(height: 20),
                      // Title
                      SearchDropdown(
                        fillColor: Color(0xFF4c4d4d),
                        filterItems: (filter) {
                          filterTitles(filter);
                          return filteredTitles;
                        },
                        onItemSelected: (selectedValue) {
                          selectedItem(selectedValue, 'title');
                        },
                        hintText: 'Search Title...',
                      ),
                      SizedBox(height: 20),
                      // Author
                      SearchDropdown(
                        fillColor: Color(0xFF4c4d4d),
                        filterItems: (filter) {
                          filterAuthors(filter);
                          return filteredAuthors;
                        },
                        onItemSelected: (selectedValue) {
                          selectedItem(selectedValue, 'author');
                        },
                        hintText: 'Search Author...',
                      ),
                      SizedBox(height: 20),
                      // Genre
                      SearchDropdown(
                        fillColor: Color(0xFF4c4d4d),
                        filterItems: (filter) {
                          filterGenres(filter);
                          return filteredGenres;
                        },
                        onItemSelected: (selectedValue) {
                          selectedItem(selectedValue, 'genre');
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
                            const Text(
                              "Format: ",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
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
                                        activeColor: Colors.white,
                                      ),
                                      const Text(
                                        "Physical",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
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
                                        activeColor: Colors.white,
                                      ),
                                      const Text(
                                        "Digital",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
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
                        onPressed: addBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF089DA1),
                          minimumSize: const Size(double.infinity, 56),
                        ),
                        child: const Text(
                          "Add Book",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ReadingListSection(
                key: _readingListKey,
                onRefresh: _refreshReadingList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
