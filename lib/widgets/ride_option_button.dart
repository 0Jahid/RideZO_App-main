import 'package:flutter/material.dart';

class RideOptionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final String backgroundImage;
  final VoidCallback onTap;

  const RideOptionButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.backgroundImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                child: Image.asset(
                  backgroundImage,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        title == 'Create Ride'
                            ? Icons.directions_car
                            : Icons.people,
                        size: 70,
                        color:
                            title == 'Create Ride'
                                ? Color(0xFF4A6741)
                                : Color(0xFFD4A574),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// historical-touch: 2025-06-28T14:45:00 by 0Jahid
