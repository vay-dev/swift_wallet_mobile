import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final String title;
  final String content;
  final String time;

  const NotificationItem({
    super.key,
    required this.title,
    required this.content,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 8.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors
              .white, // Background color for the notification item
          borderRadius: BorderRadius.circular(
            15.0,
          ), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(
                0,
                5,
              ), // shadow to give it a lift
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for Icon and Time
            Row(
              children: [
                // Replace with your image or icon
                const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  radius: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Notification Content
            Text(
              content,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
