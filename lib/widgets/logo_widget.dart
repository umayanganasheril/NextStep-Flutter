import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;

  const LogoWidget({super.key, this.size = 120.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 2.5, // Increased multiplier to make the logo larger across all screens
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if the image isn't found yet
          return const Icon(
            Icons.broken_image,
            size: 60,
            color: Colors.grey,
          );
        },
      ),
    );
  }
}
