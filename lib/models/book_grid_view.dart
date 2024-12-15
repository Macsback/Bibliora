import 'package:flutter/material.dart';
import 'package:bibliora/constants/colors.dart';
import 'package:bibliora/models/book.dart';
import 'package:bibliora/models/book_image.dart';

class BooksGridView extends StatelessWidget {
  final List<Book> books;
  final List<double> bookRatings;
  final int itemCount;
  final Function(Book)? removeBook;

  const BooksGridView({
    super.key,
    required this.books,
    required this.bookRatings,
    required this.itemCount,
    this.removeBook,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 30,
        childAspectRatio: 0.75,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        var book = books[index];
        double rating = bookRatings.isNotEmpty ? bookRatings[index] : 0.0;
        return Padding(
          padding: EdgeInsets.only(right: 30, left: 20),
          child: LayoutBuilder(
            builder: (context, raints) {
              return Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1F2020),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x80089DA1),
                      blurRadius: 2,
                      spreadRadius: 3,
                    ),
                  ],
                  border: Border.all(
                    color: Color(0x80089DA1),
                    width: 2,
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BookImage(coverImageUrl: book.coverImageUrl ?? ''),
                    SizedBox(height: 10),
                    Text(
                      book.title ?? 'Unknown Title',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      book.author ?? 'Unknown Author',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    for (var genre in (book.genres ?? []).take(3))
                      Text(
                        genre,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: generateStars(rating),
                    ),
                    SizedBox(height: 10),
                    if (removeBook != null)
                      IconButton(
                        onPressed: () => removeBook!(book),
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  List<Widget> generateStars(double rating) {
    int fullStars = rating.floor();
    double fractionalPart = rating - fullStars;

    List<Widget> stars = [];
    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: Colors.yellow, size: 16));
      } else if (i < fullStars + 1 && fractionalPart > 0) {
        stars.add(Icon(Icons.star_half, color: Colors.yellow, size: 16));
        fractionalPart = 0;
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.yellow, size: 16));
      }
    }
    return stars;
  }
}
