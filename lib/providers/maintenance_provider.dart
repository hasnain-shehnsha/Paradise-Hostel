import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Streams the count of active maintenance requests (status == 'active') from Firestore.
final maintenanceStatsProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance
      .collection('maintenance_requests')
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map((snapshot) => snapshot.size);
});
