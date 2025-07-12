class Hostel {
  final String id;
  final String name;
  final String address;

  Hostel({required this.id, required this.name, required this.address});

  factory Hostel.fromMap(Map<String, dynamic> data, String documentId) {
    return Hostel(
      id: documentId,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'address': address};
  }
}
