import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../services/bed_service.dart';
import '../models/bed.dart';

class StudentService {
  final _students = FirebaseFirestore.instance.collection('students');
  final BedService _bedService = BedService();

  Stream<List<Student>> getStudents() {
    return _students.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => Student.fromMap(doc.data(), doc.id))
              .toList(),
    );
  }

  Future<DocumentReference> addStudentWithReturn(Student student) async {
    return await _students.add(student.toMap());
  }

  Future<void> addStudent(Student student) async {
    await _students.add(student.toMap());
  }

  Future<void> updateStudent(Student student) async {
    await _students.doc(student.id).update(student.toMap());
  }

  Future<void> deleteStudent(
    String id, {
    String? bedId,
    String? roomId,
    String? hostelId,
  }) async {
    final _rents = FirebaseFirestore.instance.collection('rents');
    // Delete all rents for this student
    final rentsSnap = await _rents.where('studentId', isEqualTo: id).get();
    for (final rentDoc in rentsSnap.docs) {
      await rentDoc.reference.delete();
    }
    await _students.doc(id).delete();
    // Free the bed if info provided
    if (bedId != null && roomId != null && hostelId != null) {
      await _bedService.updateBed(
        Bed(id: bedId, hostelId: hostelId, roomId: roomId, occupiedBy: null),
      );
    }
  }

  Future<void> resetAllRentsToUnpaidIfMonthPassed() async {
    final now = DateTime.now();
    final studentsSnap = await _students.get();
    for (final doc in studentsSnap.docs) {
      final data = doc.data();
      final joiningDate =
          data['joiningDate'] != null
              ? DateTime.tryParse(data['joiningDate'])
              : null;
      if (joiningDate == null) {
        await doc.reference.update({'rentStatus': 'unpaid'});
        continue;
      }
      // If month or year has changed and today is the same day or after joiningDate.day
      final isNewMonth =
          now.year > joiningDate.year || now.month > joiningDate.month;
      final isResetDay = now.day >= joiningDate.day;
      if (isNewMonth && isResetDay) {
        await doc.reference.update({'rentStatus': 'unpaid'});
      }
    }
  }
}
