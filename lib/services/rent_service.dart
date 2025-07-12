import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rent.dart';

class RentService {
  final _rents = FirebaseFirestore.instance.collection('rents');

  Stream<List<Rent>> getRents() {
    return _rents.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Rent.fromMap(doc.data(), doc.id)).toList(),
    );
  }

  Future<void> addRent(Rent rent) async {
    await _rents.add(rent.toMap());
  }

  Future<void> updateRent(Rent rent) async {
    await _rents.doc(rent.id).update(rent.toMap());
  }

  Future<void> deleteRent(String id) async {
    await _rents.doc(id).delete();
  }
}
