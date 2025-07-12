import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paradise_hostel/screens/dashboard_screen.dart';
import 'hostel_screen.dart';
import 'room_screen.dart';
import 'student_screen.dart';
import 'rent_screen.dart';
import 'maintenance_screen.dart';
import '../widgets/side_bar.dart';

const kPrimaryBlue = Color(0xFF1DA1F2);
const kLightBlue = Color(0xFF4FC3F7);
const kRed = Color(0xFFFF6B6B);
const kWhite = Colors.white;

class HomePage extends StatefulWidget {
  // Unified color constants for consistent modern UI
  // const kWhite = Color(0xFFFFFFFF);
  // const kPrimaryBlue = Color(0xFF1565C0);
  // const kRed = Color(0xFFE53935);
  // const kAccentColor = Color(0xFF42A5F5); // Accent (optional, can use kPrimaryBlue)

  // ...existing code...
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: kWhite),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: const Text(
          'Paradise Hostel',
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: kWhite),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'This feature is coming soon!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: kPrimaryBlue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const SideBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text('👋', style: TextStyle(fontSize: 28)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome back to',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Hostel managment app',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text(
                    'DashBoard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.stacked_line_chart,
                      color: kPrimaryBlue,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // Details Card (static options, dynamic values)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimaryBlue, kLightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const _DetailsRow(),
              ),
              const SizedBox(height: 24),
              // Rent Card
              const _RentCard(),
              const SizedBox(height: 24),
              const Text(
                'More features',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              // More Details Buttons (static, with navigation)
              _MoreDetailsGrid(
                onTapList: [
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoomScreen()),
                  ), // Free Rooms
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HostelScreen()),
                  ), // Add Hostel
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoomScreen()),
                  ), // Add Rooms
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RoomScreen()),
                  ), // Remove Bed
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentScreen()),
                  ), // Add Students
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RentScreen()),
                  ), // Payments
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MaintenanceScreen(),
                    ),
                  ), // Maintainence
                  () {}, // Upload Docs (implement as needed)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// ...existing code...

// --- Details Row and Detail Circles ---
class _DetailsRow extends StatelessWidget {
  const _DetailsRow();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _TotalHostelsDetail(),
        _TotalStudentsDetail(),
        _TotalRoomsDetail(),
        _TotalBedsDetail(),
      ],
    );
  }
}

class _TotalHostelsDetail extends StatelessWidget {
  const _TotalHostelsDetail();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('hostels').snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _DetailCircle(value: '$count', label: 'Total Hostels');
      },
    );
  }
}

class _TotalStudentsDetail extends StatelessWidget {
  const _TotalStudentsDetail();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('students').snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _DetailCircle(value: '$count', label: 'Total Students');
      },
    );
  }
}

class _TotalRoomsDetail extends StatelessWidget {
  const _TotalRoomsDetail();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _DetailCircle(value: '$count', label: 'Total Rooms');
      },
    );
  }
}

class _TotalBedsDetail extends StatelessWidget {
  const _TotalBedsDetail();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('beds').snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return _DetailCircle(value: '$count', label: 'Total Beds');
      },
    );
  }
}

class _DetailCircle extends StatelessWidget {
  final String value;
  final String label;
  const _DetailCircle({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            value,
            style: const TextStyle(
              color: kWhite,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: kWhite, fontSize: 12)),
      ],
    );
  }
}

class _MoreDetailsGrid extends StatelessWidget {
  final List<VoidCallback> onTapList;
  const _MoreDetailsGrid({required this.onTapList});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
      builder: (context, roomSnap) {
        int freeRooms = 0;
        if (roomSnap.hasData) {
          final rooms = roomSnap.data!.docs;
          // You may want to use beds collection for more accurate free rooms, but here we just count rooms with a 'status' or similar
          freeRooms =
              rooms.where((room) {
                // If you have a 'status' or 'isFree' field, use it. Otherwise, count all rooms.
                final data = room.data() as Map<String, dynamic>;
                return data['isFree'] == true ||
                    data['status'] == 'free' ||
                    data['occupied'] == false ||
                    data['occupiedBy'] == null ||
                    data['occupiedBy'] == '';
              }).length;
        }
        final options = [
          {
            'label': 'Free Rooms',
            'icon': Icons.meeting_room,
            'color': kRed,
            'value': freeRooms > 0 ? freeRooms.toString() : '',
          },
          {
            'label': 'Add Hostel',
            'icon': Icons.apartment,
            'color': kPrimaryBlue,
            'value': '',
          },
          {
            'label': 'Rooms',
            'icon': Icons.meeting_room_outlined,
            'color': kPrimaryBlue,
            'value': '',
          },
          {
            'label': 'Beds',
            'icon': Icons.bed,
            'color': kPrimaryBlue,
            'value': '',
          },
          {
            'label': 'Students',
            'icon': Icons.person_add,
            'color': kPrimaryBlue,
            'value': '',
          },
          {
            'label': 'Payments',
            'icon': Icons.payments,
            'color': kPrimaryBlue,
            'value': '',
          },
          {
            'label': 'Maintainence',
            'icon': Icons.build,
            'color': kPrimaryBlue,
            'value': '',
          },
          {
            'label': 'Upload Docs',
            'icon': Icons.file_upload,
            'color': kPrimaryBlue,
            'value': '',
          },
        ];
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 2.7,
          children: [
            for (int i = 0; i < options.length; i++)
              _MoreDetailButton(
                label: options[i]['label'] as String,
                icon: options[i]['icon'] as IconData,
                color: options[i]['color'] as Color,
                value: (options[i]['value'] ?? '').toString(),
                onTap:
                    i == 6 || i == 7
                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'This feature is coming soon!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: kPrimaryBlue,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                        : onTapList[i],
                labelColor: kPrimaryBlue,
              ),
          ],
        );
      },
    );
  }
}

class _MoreDetailButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String value;
  final VoidCallback onTap;
  final Color labelColor;
  const _MoreDetailButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onTap,
    this.labelColor = kPrimaryBlue,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: const Color.fromARGB(255, 255, 255, 255),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: kPrimaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 57, 3),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              const Icon(Icons.chevron_right, color: kPrimaryBlue, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Rent Card Widget ---
class _RentCard extends StatelessWidget {
  const _RentCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('students').snapshots(),
      builder: (context, studentSnap) {
        int unpaidBill = 0;
        int collectedAmount = 0;
        if (studentSnap.hasData) {
          final students = studentSnap.data!.docs;
          for (var doc in students) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['rentStatus'] == 'paid') {
              collectedAmount += (data['rentPrice'] ?? 0) as int;
            } else {
              unpaidBill += (data['rentPrice'] ?? 0) as int;
            }
          }
        }
        return Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: kPrimaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.vpn_key,
                        color: kPrimaryBlue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Rent',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RentScreen()),
                        );
                      },
                      child: const Text(
                        'See more',
                        style: TextStyle(
                          color: kPrimaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unpaid Bill',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'RS: ',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                unpaidBill.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Not collected yet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Collected Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Text(
                            'RS: ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            collectedAmount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
