import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hostel.dart';

class HostelService {
  final _hostels = FirebaseFirestore.instance.collection('hostels');
  final _rooms = FirebaseFirestore.instance.collection('rooms');

  Stream<List<Hostel>> getHostels() {
    return _hostels.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => Hostel.fromMap(doc.data(), doc.id))
              .toList(),
    );
  }

  Future<void> addHostel(Hostel hostel) async {
    await _hostels.add(hostel.toMap());
  }

  Future<void> updateHostel(Hostel hostel) async {
    await _hostels.doc(hostel.id).update(hostel.toMap());
  }

  Future<void> deleteHostel(String id) async {
    final _beds = FirebaseFirestore.instance.collection('beds');
    final _students = FirebaseFirestore.instance.collection('students');
    final _rents = FirebaseFirestore.instance.collection('rents');

    // Delete all rooms related to this hostel
    final roomsSnap = await _rooms.where('hostelId', isEqualTo: id).get();
    for (final roomDoc in roomsSnap.docs) {
      final roomId = roomDoc.id;
      // Delete all beds in this room
      final bedsSnap = await _beds.where('roomId', isEqualTo: roomId).get();
      for (final bedDoc in bedsSnap.docs) {
        await bedDoc.reference.delete();
      }
      // Delete all students in this room
      final studentsSnap =
          await _students.where('roomId', isEqualTo: roomId).get();
      for (final studentDoc in studentsSnap.docs) {
        // Delete all rents for this student
        final rentsSnap =
            await _rents.where('studentId', isEqualTo: studentDoc.id).get();
        for (final rentDoc in rentsSnap.docs) {
          await rentDoc.reference.delete();
        }
        await studentDoc.reference.delete();
      }
      // Delete all rents for this room (in case any left)
      final rentsForRoomSnap =
          await _rents.where('roomId', isEqualTo: roomId).get();
      for (final rentDoc in rentsForRoomSnap.docs) {
        await rentDoc.reference.delete();
      }
      // Delete the room itself
      await roomDoc.reference.delete();
    }
    // Delete all students directly under this hostel (not in any room)
    final studentsSnap = await _students.where('hostelId', isEqualTo: id).get();
    for (final studentDoc in studentsSnap.docs) {
      // Delete all rents for this student
      final rentsSnap =
          await _rents.where('studentId', isEqualTo: studentDoc.id).get();
      for (final rentDoc in rentsSnap.docs) {
        await rentDoc.reference.delete();
      }
      await studentDoc.reference.delete();
    }
    // Delete all beds directly under this hostel (not in any room)
    final bedsSnap = await _beds.where('hostelId', isEqualTo: id).get();
    for (final bedDoc in bedsSnap.docs) {
      await bedDoc.reference.delete();
    }
    // Delete all rents directly under this hostel (not in any room/student)
    final rentsSnap = await _rents.where('roomId', isEqualTo: id).get();
    for (final rentDoc in rentsSnap.docs) {
      await rentDoc.reference.delete();
    }
    // Now delete the hostel
    await _hostels.doc(id).delete();
  }
}
