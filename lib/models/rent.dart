class Rent {
  final String id;
  final String studentId;
  final String roomId;
  final int amount;
  final String month;
  final bool paid;

  Rent({
    required this.id,
    required this.studentId,
    required this.roomId,
    required this.amount,
    required this.month,
    required this.paid,
  });

  factory Rent.fromMap(Map<String, dynamic> data, String documentId) {
    return Rent(
      id: documentId,
      studentId: data['studentId'] ?? '',
      roomId: data['roomId'] ?? '',
      amount: data['amount'] ?? 0,
      month: data['month'] ?? '',
      paid: data['paid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'roomId': roomId,
      'amount': amount,
      'month': month,
      'paid': paid,
    };
  }
}
