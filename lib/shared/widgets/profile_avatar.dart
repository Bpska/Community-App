import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showOnlineStatus;
  final bool isOnline;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 50,
    this.showOnlineStatus = false,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImage(imageUrl!)
              : null,
          child: imageUrl == null || imageUrl!.isEmpty
              ? Icon(
                  Icons.person,
                  size: size / 2,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
        ),
        if (showOnlineStatus)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size / 5,
              height: size / 5,
              decoration: BoxDecoration(
                color: isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
