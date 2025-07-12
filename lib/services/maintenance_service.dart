import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maintenance_request.dart';

class MaintenanceService {
  final _requests = FirebaseFirestore.instance.collection(
    'maintenance_requests',
  );

  Stream<List<MaintenanceRequest>> getRequests() {
    return _requests.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => MaintenanceRequest.fromMap(doc.data(), doc.id))
              .toList(),
    );
  }

  Future<void> addRequest(MaintenanceRequest request) async {
    await _requests.add(request.toMap());
  }

  Future<void> updateRequest(MaintenanceRequest request) async {
    await _requests.doc(request.id).update(request.toMap());
  }

  Future<void> deleteRequest(String id) async {
    await _requests.doc(id).delete();
  }
}
