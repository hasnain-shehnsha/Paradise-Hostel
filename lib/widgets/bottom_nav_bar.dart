import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart'; // for color constants

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: kAccentColor,
          unselectedItemColor: kSubtitleColor,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          showUnselectedLabels: true,
          currentIndex: currentIndex,
          onTap: onTap,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_work),
              label: 'Hostels',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room),
              label: 'Rooms',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Students',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Rent',
            ),
            
          ],
        ),
      ),
    );
  }
}
