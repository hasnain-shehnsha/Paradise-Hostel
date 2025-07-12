import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1DA1F2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Image.asset('assets/logo.png', height: 100),
            ),
            const SizedBox(height: 32),
            const Text(
              'Paradise Hostel',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
