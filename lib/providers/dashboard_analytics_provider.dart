import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

/// Provider for room occupancy: returns a map of room names to student count.
final roomOccupancyProvider = StreamProvider<Map<String, int>>((ref) {
  final roomsStream =
      FirebaseFirestore.instance.collection('rooms').snapshots();
  final studentsStream =
      FirebaseFirestore.instance.collection('students').snapshots();
  return CombineLatestStream.combine2<
    QuerySnapshot,
    QuerySnapshot,
    Map<String, int>
  >(roomsStream, studentsStream, (roomsSnap, studentsSnap) {
    final Map<String, int> occupancy = {};
    for (var room in roomsSnap.docs) {
      final roomId = room.id;
      final roomData = room.data() as Map<String, dynamic>?;
      final roomName = roomData?['name'] ?? roomId;
      final count =
          studentsSnap.docs.where((s) {
            final sData = s.data();
            if (sData is Map<String, dynamic>) {
              return sData['roomId'] == roomId;
            }
            return false;
          }).length;
      occupancy[roomName] = count;
    }
    return occupancy;
  });
});

/// Provider for student occupancy: returns a tuple (occupied, vacant)
final studentOccupancyProvider = StreamProvider<(int, int)>((ref) {
  final roomsStream =
      FirebaseFirestore.instance.collection('rooms').snapshots();
  final studentsStream =
      FirebaseFirestore.instance.collection('students').snapshots();
  return CombineLatestStream.combine2<QuerySnapshot, QuerySnapshot, (int, int)>(
    roomsStream,
    studentsStream,
    (roomsSnap, studentsSnap) {
      int totalBeds = 0;
      for (var room in roomsSnap.docs) {
        final roomData = room.data();
        int beds = 0;
        if (roomData is Map<String, dynamic> && roomData['beds'] != null) {
          beds =
              roomData['beds'] is int
                  ? roomData['beds']
                  : (roomData['beds'] as num).toInt();
        }
        totalBeds += beds;
      }
      final occupied = studentsSnap.docs.length;
      final vacant = totalBeds - occupied;
      return (occupied, vacant);
    },
  );
});

/// Provider for monthly income: returns a map of month (e.g. 'Jan') to total collected
final monthlyIncomeProvider = StreamProvider<Map<String, int>>((ref) {
  final rentsStream =
      FirebaseFirestore.instance.collection('rents').snapshots();
  return rentsStream.map((rentsSnap) {
    final Map<String, int> income = {};
    for (var doc in rentsSnap.docs) {
      final data = doc.data();
      if (data['paid'] == true && data['month'] != null) {
        // Standardize month to short format (e.g. Jan, Feb, ...)
        String month = data['month'].toString();
        if (month.length > 3) month = month.substring(0, 3);
        final amount =
            data['amount'] is int
                ? data['amount']
                : (data['amount'] as num).toInt();
        income[month] = ((income[month] ?? 0) + amount).toInt();
      }
    }
    return income;
  });
});
