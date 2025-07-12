import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bed.dart';

class BedService {
  final _beds = FirebaseFirestore.instance.collection('beds');

  Stream<List<Bed>> getBedsForRoom(String roomId) {
    return _beds
        .where('roomId', isEqualTo: roomId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Bed.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  Future<void> addBed(Bed bed) async {
    await _beds.add(bed.toMap());
  }

  Future<void> updateBed(Bed bed) async {
    await _beds.doc(bed.id).update(bed.toMap());
  }

  Future<void> deleteBed(String id) async {
    await _beds.doc(id).delete();
  }

  Future<void> addBedsForRoom({
    required String hostelId,
    required String roomId,
    required int count,
  }) async {
    for (int i = 0; i < count; i++) {
      await addBed(
        Bed(id: '', hostelId: hostelId, roomId: roomId, occupiedBy: null),
      );
    }
  }
}
