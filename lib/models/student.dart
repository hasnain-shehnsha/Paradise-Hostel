class Student {
  final String id;
  final String name;
  final String mobileNo;
  final String hostelId;
  final String roomId;
  final String bedId;
  final int rentPrice;
  final String rentStatus; // 'paid' or 'unpaid'
  final DateTime joiningDate;

  Student({
    required this.id,
    required this.name,
    required this.mobileNo,
    required this.hostelId,
    required this.roomId,
    required this.bedId,
    required this.rentPrice,
    this.rentStatus = 'unpaid',
    required this.joiningDate,
  });

  factory Student.fromMap(Map<String, dynamic> data, String documentId) {
    return Student(
      id: documentId,
      name: data['name'] ?? '',
      mobileNo: data['mobileNo'] ?? '',
      hostelId: data['hostelId'] ?? '',
      roomId: data['roomId'] ?? '',
      bedId: data['bedId'] ?? '',
      rentPrice: data['rentPrice'] ?? 0,
      rentStatus: data['rentStatus'] ?? 'unpaid',
      joiningDate:
          data['joiningDate'] != null
              ? DateTime.tryParse(data['joiningDate']) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobileNo': mobileNo,
      'hostelId': hostelId,
      'roomId': roomId,
      'bedId': bedId,
      'rentPrice': rentPrice,
      'rentStatus': rentStatus,
      'joiningDate': joiningDate.toIso8601String(),
    };
  }

  Student copyWith({
    String? id,
    String? name,
    String? mobileNo,
    String? hostelId,
    String? roomId,
    String? bedId,
    int? rentPrice,
    String? rentStatus,
    DateTime? joiningDate,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNo: mobileNo ?? this.mobileNo,
      hostelId: hostelId ?? this.hostelId,
      roomId: roomId ?? this.roomId,
      bedId: bedId ?? this.bedId,
      rentPrice: rentPrice ?? this.rentPrice,
      rentStatus: rentStatus ?? this.rentStatus,
      joiningDate: joiningDate ?? this.joiningDate,
    );
  }
}
