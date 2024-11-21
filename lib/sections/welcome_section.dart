import 'package:bibliora/screens/add_book_screen.dart';
import 'package:flutter/material.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.only(right: 30, left: 30),
      color: Colors.transparent,
      width: double.infinity,
      height: screenHeight * 0.95,
      child: Stack(
        children: [
          Positioned(
            height: screenHeight * 0.85,
            width: screenWidth,
            child: Transform.scale(
              scale: 1.2,
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  'assets/about.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Main content (Text and Image)
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME TO',
                      style: TextStyle(
                        fontSize: 65,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontFamily: 'SansSerif',
                      ),
                    ),
                    Text(
                      'Bibliora',
                      style: TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF089DA1),
                        fontFamily: 'SansSerif',
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Are you ready to embark on a journey of discovery? With Bibliora, you can track, organize, and dive into your reading adventures with ease. Start building your personal library today, and never lose track of your favorite books again!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white54,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddBookScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF089DA1),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text(
                        'Start Adding Books',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: Image.asset(
                  'assets/table.png',
                  width: screenWidth * 0.75,
                  height: screenHeight * 0.75,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
