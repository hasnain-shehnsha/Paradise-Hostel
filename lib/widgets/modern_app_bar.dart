import 'package:flutter/material.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const ModernAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6D5DF6), Color(0xFF46C2CB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x336D5DF6),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.apartment, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
