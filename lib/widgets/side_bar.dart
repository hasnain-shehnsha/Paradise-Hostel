import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/hostel_screen.dart';
import '../screens/room_screen.dart';
import '../screens/student_screen.dart';
import '../screens/rent_screen.dart';
import '../screens/maintenance_screen.dart';

const kPrimaryBlue = Color(0xFF1DA1F2);
const kRed = Color(0xFFFF6B6B);

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: kPrimaryBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.apartment, color: Colors.white, size: 40),
                SizedBox(height: 12),
                Text(
                  'Paradise Hostel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'admin@hostel.com',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          _DrawerButton(
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
          _DrawerButton(
            icon: Icons.home_work,
            label: 'Hostels',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HostelScreen()),
              );
            },
          ),
          _DrawerButton(
            icon: Icons.meeting_room,
            label: 'Rooms',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RoomScreen()),
              );
            },
          ),
          _DrawerButton(
            icon: Icons.people,
            label: 'Students',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentScreen()),
              );
            },
          ),
          _DrawerButton(
            icon: Icons.attach_money,
            label: 'Rent',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RentScreen()),
              );
            },
          ),
          _DrawerButton(
            icon: Icons.build,
            label: 'Maintenance',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
              );
            },
          ),
          const Divider(),
          _DrawerButton(
            icon: Icons.logout,
            label: 'Logout',
            iconColor: kRed,
            textColor: kRed,
            onTap: () {
              Navigator.of(context).pop();
              // Add your logout logic here
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerButton extends StatelessWidget {
  const _DrawerButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? kPrimaryBlue),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? kPrimaryBlue,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      hoverColor: kPrimaryBlue.withOpacity(0.08),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}
