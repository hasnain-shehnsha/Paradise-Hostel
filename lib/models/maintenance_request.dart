import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceRequest {
  final String id;
  final String studentId;
  final String roomId;
  final String issue;
  final String status; // Pending, In Progress, Resolved
  final DateTime date;

  MaintenanceRequest({
    required this.id,
    required this.studentId,
    required this.roomId,
    required this.issue,
    required this.status,
    required this.date,
  });

  factory MaintenanceRequest.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return MaintenanceRequest(
      id: documentId,
      studentId: data['studentId'] ?? '',
      roomId: data['roomId'] ?? '',
      issue: data['issue'] ?? '',
      status: data['status'] ?? 'Pending',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'roomId': roomId,
      'issue': issue,
      'status': status,
      'date': date,
    };
  }
}
