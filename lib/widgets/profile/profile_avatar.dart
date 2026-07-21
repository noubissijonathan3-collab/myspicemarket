import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String email;
  final String phone;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        const SizedBox(height: 20),

        Stack(
          clipBehavior: Clip.none,
          children: [

            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
              imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? const Icon(
                Icons.person,
                size: 80,
                color: Colors.white,
              )
                  : null,
            ),

            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {},

                child: Container(
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: const Color(0xFF006E2F),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),

                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          email,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          phone,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: 180,
          height: 48,

          child: ElevatedButton.icon(
            onPressed: () {},

            icon: const Icon(Icons.edit),

            label: const Text(
              "Edit Profile",
            ),

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8BE68A),
              foregroundColor: const Color(0xFF006E2F),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}