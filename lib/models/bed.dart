class Bed {
  final String id;
  final String hostelId;
  final String roomId;
  final String? occupiedBy; // student id if occupied, else null

  Bed({
    required this.id,
    required this.hostelId,
    required this.roomId,
    this.occupiedBy,
  });

  factory Bed.fromMap(Map<String, dynamic> data, String documentId) {
    return Bed(
      id: documentId,
      hostelId: data['hostelId'] ?? '',
      roomId: data['roomId'] ?? '',
      occupiedBy: data['occupiedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'hostelId': hostelId, 'roomId': roomId, 'occupiedBy': occupiedBy};
  }
}
