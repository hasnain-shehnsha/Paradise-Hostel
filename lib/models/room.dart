class Room {
  final String id;
  final String hostelId;
  final String roomNo;
  final int totalBeds;
  final bool occupied;

  Room({
    required this.id,
    required this.hostelId,
    required this.roomNo,
    required this.totalBeds,
    required this.occupied,
  });

  factory Room.fromMap(Map<String, dynamic> data, String documentId) {
    return Room(
      id: documentId,
      hostelId: data['hostelId'] ?? '',
      roomNo: data['roomNo'] ?? '',
      totalBeds: data['totalBeds'] ?? 0,
      occupied: data['occupied'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hostelId': hostelId,
      'roomNo': roomNo,
      'totalBeds': totalBeds,
      'occupied': occupied,
    };
  }
}
