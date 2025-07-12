import 'package:flutter/material.dart';
import '../services/bed_service.dart';
import '../models/bed.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



const kPrimaryBlue = Color(0xFF1DA1F2);
const kRed = Color(0xFFE53935);
const kWhite = Color(0xFFFFFFFF);


class BedListScreen extends StatelessWidget {
  final String roomId;
  final String hostelId;
  final String roomNo;
  const BedListScreen({
    super.key,
    required this.roomId,
    required this.hostelId,
    required this.roomNo,
  });

  @override
  Widget build(BuildContext context) {
    final BedService bedService = BedService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        title: const Text(
          'Beds',
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: kWhite),
      ),
      backgroundColor: kWhite,
      body: StreamBuilder<List<Bed>>(
        stream: bedService.getBedsForRoom(roomId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final beds = snapshot.data ?? [];
          if (beds.isEmpty) {
            return const Center(child: Text('No beds found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: beds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final bed = beds[i];
              return Card(
                color: kWhite,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: bed.occupiedBy == null
                              ? Colors.green.withOpacity(0.12)
                              : kRed.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          bed.occupiedBy == null ? Icons.bed_outlined : Icons.person,
                          color: bed.occupiedBy == null ? Colors.green : kRed,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bed ${i + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            bed.occupiedBy == null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Free',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('students')
                                        .doc(bed.occupiedBy)
                                        .get(),
                                    builder: (context, snap) {
                                      if (!snap.hasData || !snap.data!.exists) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: kRed.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Occupied',
                                            style: TextStyle(
                                              color: kRed,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        );
                                      }
                                      final data = snap.data!.data() as Map<String, dynamic>;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: kRed.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Occupied by: ${data['name'] ?? 'Unknown'}',
                                          style: const TextStyle(
                                            color: kRed,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    },
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
        },
      ),
    );
  }
}
