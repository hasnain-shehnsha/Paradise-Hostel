import 'package:flutter/material.dart';
import '../services/bed_service.dart';
import '../models/bed.dart';

class RoomBedStatus extends StatelessWidget {
  final String roomId;
  final int totalBeds;
  const RoomBedStatus({
    super.key,
    required this.roomId,
    required this.totalBeds,
  });

  @override
  Widget build(BuildContext context) {
    final BedService bedService = BedService();
    return StreamBuilder<List<Bed>>(
      stream: bedService.getBedsForRoom(roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final beds = snapshot.data ?? [];
        final occupiedCount = beds.where((b) => b.occupiedBy != null).length;
        final freeCount = beds.length - occupiedCount;
        if (beds.isEmpty) {
          return const Text(
            'No beds found',
            style: TextStyle(fontSize: 13, color: Colors.redAccent),
          );
        }
        if (occupiedCount == beds.length) {
          return const Text(
            'Occupied',
            style: TextStyle(
              fontSize: 13,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          );
        }
        return Text(
          'Occupied: $occupiedCount, Free: $freeCount',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        );
      },
    );
  }
}
