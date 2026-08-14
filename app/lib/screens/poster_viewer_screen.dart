import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PosterViewerScreen extends StatelessWidget {
  const PosterViewerScreen({super.key, required this.imageUrl, required this.title});

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (_, _) => const CircularProgressIndicator(color: Colors.white),
            errorWidget: (_, _, _) => const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.white54,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
