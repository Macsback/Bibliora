import 'package:bibliora/service/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class BookImage extends StatelessWidget {
  final String coverImageUrl;

  const BookImage({super.key, required this.coverImageUrl});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: ApiService.fetchImageFromBackend(coverImageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Icon(Icons.broken_image, size: 50, color: Colors.red),
            ),
          );
        } else {
          return Image.memory(
            snapshot.data!,
            height: 200,
            fit: BoxFit.contain,
          );
        }
      },
    );
  }
}
