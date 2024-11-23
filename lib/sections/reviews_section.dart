import 'package:flutter/material.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        'name': 'John Deo',
        'content':
            'Great website! Very useful and easy to navigate. I was able to find all the books I needed for my project without any hassle. The layout is intuitive, and it makes searching so much easier.',
        'image': 'assets/review_1.png',
        'rating': 4.5,
      },
      {
        'name': 'Jane Smith',
        'content':
            'I found exactly what I was looking for, highly recommend! The filtering options really helped me narrow down my choices, and the site loaded quickly. Overall, an excellent experience!',
        'image': 'assets/review_2.png',
        'rating': 5.0,
      },
      {
        'name': 'Michael Brown',
        'content':
            'Fantastic experience. The layout is beautiful and intuitive. I love how easy it is to navigate between categories and find exactly what I want. The search functionality is top-notch.',
        'image': 'assets/review_3.png',
        'rating': 4.0,
      },
      {
        'name': 'Emily Clark',
        'content':
            'A smooth and seamless experience from start to finish! From the moment I logged in to the moment I found my books, everything worked perfectly. The design is modern and easy on the eyes.',
        'image': 'assets/review_4.png',
        'rating': 4.5,
      },
    ];

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Your Reviews',
              style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: reviews.map((review) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF1F2020),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x60089DA1),
                          blurRadius: 2,
                          spreadRadius: 3,
                        ),
                      ],
                      border: Border.all(
                        color: Color(0x80089DA1),
                        width: 2,
                      ),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  AssetImage(review['image'] as String),
                            ),
                            Icon(Icons.format_quote,
                                size: 90, color: Colors.white),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          review['name'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          review['content'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: List.generate(5, (index) {
                            double rating = review['rating'] as double;
                            if (index < rating) {
                              return Icon(Icons.star,
                                  color: Colors.amber, size: 20);
                            } else if (index < rating + 0.5) {
                              return Icon(Icons.star_half,
                                  color: Colors.amber, size: 20);
                            } else {
                              return Icon(Icons.star_border,
                                  color: Colors.amber, size: 20);
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
