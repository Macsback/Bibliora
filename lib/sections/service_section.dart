import 'package:flutter/material.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'icon': Icons.local_shipping,
        'title': 'Create Reading Lists',
        'description': 'Organize your favorite books into personalized lists.',
      },
      {
        'icon': Icons.headset,
        'title': 'Join Bookclubs',
        'description': 'Participate in book discussions with others.',
      },
      {
        'icon': Icons.label,
        'title': 'Tailored Experience',
        'description': 'Get book recommendations based on your preferences.',
      },
      {
        'icon': Icons.lock,
        'title': 'No Hassle',
        'description': 'Easy setup with no extra steps needed.',
      },
    ];

    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: services.map((service) {
          return Container(
            width: 250,
            decoration: BoxDecoration(
              color: Color(0xFF1F2020),
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
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  service['icon'] as IconData,
                  size: 40,
                  color: Color(0xFF089DA1),
                ),
                SizedBox(height: 10),
                Text(
                  service['title'] as String,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  service['description'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
