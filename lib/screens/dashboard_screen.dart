import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import 'hostel_screen.dart';
import 'room_screen.dart';
import 'student_screen.dart';
import 'rent_screen.dart';
import 'maintenance_screen.dart';
import '../providers/maintenance_provider.dart';
import '../providers/dashboard_analytics_provider.dart';


const kWhite = Color(0xFFF8F9FC);
const kCardColor = Color(0xFFFFFFFF);
const kAccentColor = Color(0xFF1DA1F2); // Primary blue
const kTitleColor = Color(0xFF111827);
const kSubtitleColor = Color(0xFF6B7280);
const kSuccessColor = Color(0xFF10B981); // Green
const kWarningColor = Color(0xFFF59E0B); // Yellow
const kDangerColor = Color(0xFFEF4444); // Red

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kAccentColor,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DashboardMainContent(),
        ),
      ),
    );
  }
}

class DashboardMainContent extends StatelessWidget {
  const DashboardMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final maxWidth = 900.0;
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Admin!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: kTitleColor,
                  ),
                ),
                const SizedBox(height: 28),
                // Stats Cards Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = constraints.maxWidth > 700 ? 3 : 1;
                    return GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 1.7,
                      ),
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('hostels')
                                  .snapshots(),
                          builder: (context, hostelSnap) {
                            final hostelCount =
                                hostelSnap.data?.docs.length ?? 0;
                            return _DashboardCard(
                              title: 'Total Hostels',
                              value: '$hostelCount',
                              icon: Icons.home_work,
                              iconColor: kAccentColor,
                            );
                          },
                        ),
                        // --- Total Free Rooms Card ---
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('rooms')
                                  .snapshots(),
                          builder: (context, roomSnap) {
                            if (!roomSnap.hasData) {
                              return _DashboardCard(
                                title: 'Total Free Rooms',
                                value: '...',
                                icon: Icons.meeting_room,
                                iconColor: kAccentColor,
                              );
                            }
                            final rooms = roomSnap.data!.docs;
                            return StreamBuilder<QuerySnapshot>(
                              stream:
                                  FirebaseFirestore.instance
                                      .collection('beds')
                                      .snapshots(),
                              builder: (context, bedSnap) {
                                if (!bedSnap.hasData) {
                                  return _DashboardCard(
                                    title: 'Total Free Rooms',
                                    value: '...',
                                    icon: Icons.meeting_room,
                                    iconColor: kAccentColor,
                                  );
                                }
                                final beds = bedSnap.data!.docs;
                                int freeRoomCount = 0;
                                int freeBedCount = 0;
                                for (var room in rooms) {
                                  final roomId = room.id;
                                  final bedsForRoom =
                                      beds
                                          .where((b) => b['roomId'] == roomId)
                                          .toList();
                                  if (bedsForRoom.isEmpty) continue;
                                  final hasFreeBed = bedsForRoom.any(
                                    (b) =>
                                        b['occupiedBy'] == null ||
                                        b['occupiedBy'] == '',
                                  );
                                  if (hasFreeBed) freeRoomCount++;
                                }
                                freeBedCount =
                                    beds
                                        .where(
                                          (b) =>
                                              b['occupiedBy'] == null ||
                                              b['occupiedBy'] == '',
                                        )
                                        .length;
                                return _DashboardCard(
                                  title: 'Total Free Rooms',
                                  value: '$freeRoomCount',
                                  icon: Icons.meeting_room,
                                  iconColor: kAccentColor,
                                  subtitle: 'Total Free Beds: $freeBedCount',
                                );
                              },
                            );
                          },
                        ),
                        // --- Total Students Card ---
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('students')
                                  .snapshots(),
                          builder: (context, studentSnap) {
                            final studentCount =
                                studentSnap.data?.docs.length ?? 0;
                            return _DashboardCard(
                              title: 'Total Students',
                              value: '$studentCount',
                              icon: Icons.people,
                              iconColor: kAccentColor,
                            );
                          },
                        ),
                        // --- Total Paid (Collected) from Students ---
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('students')
                                  .snapshots(),
                          builder: (context, studentSnap) {
                            final students = studentSnap.data?.docs ?? [];
                            int totalPaid = 0;
                            for (var doc in students) {
                              final data = doc.data() as Map<String, dynamic>;
                              if (data['rentStatus'] == 'paid') {
                                totalPaid += (data['rentPrice'] ?? 0) as int;
                              }
                            }
                            return _DashboardCard(
                              title: 'Total Collected',
                              value: 'PKR $totalPaid',
                              icon: Icons.check_circle,
                              iconColor: kSuccessColor,
                              status: 'Paid',
                            );
                          },
                        ),
                        // --- Total Unpaid from Students ---
                        StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('students')
                                  .snapshots(),
                          builder: (context, studentSnap) {
                            final students = studentSnap.data?.docs ?? [];
                            int totalUnpaid = 0;
                            for (var doc in students) {
                              final data = doc.data() as Map<String, dynamic>;
                              if (data['rentStatus'] != 'paid') {
                                totalUnpaid += (data['rentPrice'] ?? 0) as int;
                              }
                            }
                            return _DashboardCard(
                              title: 'Total Unpaid',
                              value: 'PKR $totalUnpaid',
                              icon: Icons.error_outline,
                              iconColor: kDangerColor,
                              status: 'Unpaid',
                            );
                          },
                        ),
                        Consumer(
                          builder: (context, ref, _) {
                            final asyncCount = ref.watch(
                              maintenanceStatsProvider,
                            );
                            return asyncCount.when(
                              data:
                                  (activeCount) => _DashboardCard(
                                    title: 'Active Maintenance',
                                    value: '$activeCount',
                                    icon: Icons.build,
                                    iconColor: kWarningColor,
                                    status: 'Active',
                                  ),
                              loading:
                                  () => _DashboardCard(
                                    title: 'Active Maintenance',
                                    value: '...',
                                    icon: Icons.build,
                                    iconColor: kWarningColor,
                                  ),
                              error:
                                  (e, _) => _DashboardCard(
                                    title: 'Active Maintenance',
                                    value: 'Err',
                                    icon: Icons.build,
                                    iconColor: kWarningColor,
                                  ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 36),
                // Room Occupancy Chart
                ModernChartCard(
                  title: 'Room Occupancy',
                  icon: Icons.bar_chart,
                  child: SizedBox(
                    height: 200,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final asyncOcc = ref.watch(roomOccupancyProvider);
                        return asyncOcc.when(
                          data: (roomMap) {
                            final rooms = roomMap.keys.toList();
                            return BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                barGroups: [
                                  for (int i = 0; i < rooms.length; i++)
                                    BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: roomMap[rooms[i]]!.toDouble(),
                                          color: kAccentColor,
                                        ),
                                      ],
                                    ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx >= 0 && idx < rooms.length) {
                                          return Text(
                                            rooms[idx],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: kSubtitleColor,
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                              ),
                            );
                          },
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          error:
                              (e, _) => Center(
                                child: Text(
                                  'Error: $e',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                // Student Occupancy Chart
                ModernChartCard(
                  title: 'Student Occupancy',
                  icon: Icons.pie_chart,
                  child: SizedBox(
                    height: 180,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final asyncOcc = ref.watch(studentOccupancyProvider);
                        return asyncOcc.when(
                          data: (tuple) {
                            final occupied = tuple.$1;
                            final vacant = tuple.$2;
                            return PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    value: occupied.toDouble(),
                                    color: kAccentColor,
                                    title: 'Occupied',
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: vacant.toDouble(),
                                    color: kSubtitleColor,
                                    title: 'Vacant',
                                    titleStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                sectionsSpace: 2,
                                centerSpaceRadius: 30,
                              ),
                            );
                          },
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          error:
                              (e, _) => Center(
                                child: Text(
                                  'Error: $e',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                // Monthly Income Chart
                ModernChartCard(
                  title: 'Monthly Income',
                  icon: Icons.stacked_bar_chart,
                  child: SizedBox(
                    height: 200,
                    child: Consumer(
                      builder: (context, ref, _) {
                        final asyncInc = ref.watch(monthlyIncomeProvider);
                        return asyncInc.when(
                          data: (incMap) {
                            final months = incMap.keys.toList();
                            return BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                barGroups: [
                                  for (int i = 0; i < months.length; i++)
                                    BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: incMap[months[i]]!.toDouble(),
                                          color: kSuccessColor,
                                        ),
                                      ],
                                    ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: true),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx >= 0 && idx < months.length) {
                                          return Text(
                                            months[idx],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: kSubtitleColor,
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                              ),
                            );
                          },
                          loading:
                              () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                          error:
                              (e, _) => Center(
                                child: Text(
                                  'Error: $e',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String subtitle;
  final String? status;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = kAccentColor,
    this.subtitle = '',
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    status!,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kTitleColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontSize: 15, color: kSubtitleColor),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: kSubtitleColor),
            ),
          ],
        ],
      ),
    );
  }
}

class ModernChartCard extends StatelessWidget {
  final Widget child;
  final String title;
  final IconData icon;
  final Color? iconColor;

  const ModernChartCard({
    super.key,
    required this.child,
    required this.title,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor ?? kAccentColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: kTitleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ],
    );
  }
}
