import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomService {
  final _rooms = FirebaseFirestore.instance.collection('rooms');

  Stream<List<Room>> getRooms({String? hostelId}) {
    Query<Map<String, dynamic>> query = _rooms;
    if (hostelId != null) {
      query = query.where('hostelId', isEqualTo: hostelId);
    }
    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Room.fromMap(doc.data(), doc.id)).toList(),
    );
  }

  Future<void> addRoom(Room room) async {
    await _rooms.add(room.toMap());
  }

  Future<DocumentReference> addRoomWithReturn(Room room) async {
    return await _rooms.add(room.toMap());
  }

  Future<void> updateRoom(Room room) async {
    await _rooms.doc(room.id).update(room.toMap());
  }

  Future<void> deleteRoom(String id) async {
    final _beds = FirebaseFirestore.instance.collection('beds');
    final _students = FirebaseFirestore.instance.collection('students');
    final _rents = FirebaseFirestore.instance.collection('rents');

    // Delete all beds in this room
    final bedsSnap = await _beds.where('roomId', isEqualTo: id).get();
    for (final bedDoc in bedsSnap.docs) {
      await bedDoc.reference.delete();
    }
    // Delete all students in this room
    final studentsSnap = await _students.where('roomId', isEqualTo: id).get();
    for (final studentDoc in studentsSnap.docs) {
      // Delete all rents for this student
      final rentsSnap =
          await _rents.where('studentId', isEqualTo: studentDoc.id).get();
      for (final rentDoc in rentsSnap.docs) {
        await rentDoc.reference.delete();
      }
      await studentDoc.reference.delete();
    }
    // Delete all rents for this room
    final rentsForRoomSnap = await _rents.where('roomId', isEqualTo: id).get();
    for (final rentDoc in rentsForRoomSnap.docs) {
      await rentDoc.reference.delete();
    }
    // Delete the room itself
    await _rooms.doc(id).delete();
  }
}
