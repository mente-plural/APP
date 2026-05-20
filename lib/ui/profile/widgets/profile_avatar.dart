import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final String email;
  final double radius;
  final bool isEditing;
  final bool isUploading;
  final VoidCallback? onEditTap;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    required this.name,
    required this.email,
    this.radius = 40,
    this.isEditing = false,
    this.isUploading = false,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = (name.isNotEmpty)
        ? name[0].toUpperCase()
        : (email.isNotEmpty ? email[0].toUpperCase() : '?');

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: theme.colorScheme.primary,
          backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
              ? NetworkImage(photoUrl!)
              : null,
          child: (photoUrl == null || photoUrl!.isEmpty)
              ? Text(
                  initials,
                  style: TextStyle(
                    fontSize: radius * 0.8,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : null,
        ),
        if (isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: isUploading ? null : onEditTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                ),
                child: isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
