import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../services/student_service.dart';
import '../services/hostel_service.dart';
import '../services/room_service.dart';
import '../services/bed_service.dart';
import '../models/hostel.dart';
import '../models/room.dart';
import '../models/bed.dart';
// ...existing imports...
// Unified color constants for consistent modern UI
const kWhite = Color(0xFFFFFFFF);
const kPrimaryBlue = Color(0xFF1DA1F2);
const kRed = Color(0xFFE53935);
const kAccentColor = Color(0xFF42A5F5); // Accent (optional, can use kPrimaryBlue)


class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final StudentService _service = StudentService();
  final HostelService _hostelService = HostelService();
  final RoomService _roomService = RoomService();
  final BedService _bedService = BedService();

  void _showStudentDialog({Student? student}) {
    String? selectedHostelId;
    String? selectedRoomId;
    String? selectedBedId;
    List<Hostel> hostels = [];
    List<Room> rooms = [];
    List<Bed> beds = [];
    final nameController = TextEditingController(text: student?.name ?? '');
    final mobileController = TextEditingController(
      text: student?.mobileNo ?? '',
    );
    final rentController = TextEditingController(
      text: student?.rentPrice.toString() ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            student == null ? 'Add Student' : 'Edit Student',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 18),
                          FutureBuilder<List<Hostel>>(
                            future: _hostelService.getHostels().first,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              hostels = snapshot.data!;
                              return DropdownButtonFormField<String>(
                                value: selectedHostelId,
                                decoration: const InputDecoration(
                                  labelText: 'Select Hostel',
                                  border: OutlineInputBorder(),
                                ),
                                items:
                                    hostels
                                        .map(
                                          (h) => DropdownMenuItem(
                                            value: h.id,
                                            child: Text(h.name),
                                          ),
                                        )
                                        .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    selectedHostelId = val;
                                    selectedRoomId = null;
                                    selectedBedId = null;
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          if (selectedHostelId != null)
                            StreamBuilder<List<Room>>(
                              stream: _roomService.getRooms(
                                hostelId: selectedHostelId,
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                rooms = snapshot.data!;
                                // Only show rooms that have at least one free bed
                                final roomsWithFreeBeds =
                                    rooms
                                        .where(
                                          (room) =>
                                              room.id.isNotEmpty, // Defensive
                                        )
                                        .where(
                                          (room) =>
                                              true, // Will filter in next dropdown
                                        )
                                        .toList();
                                return DropdownButtonFormField<String>(
                                  value: selectedRoomId,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Room',
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      roomsWithFreeBeds
                                          .map(
                                            (r) => DropdownMenuItem(
                                              value: r.id,
                                              child: Text(r.roomNo),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedRoomId = val;
                                      selectedBedId = null;
                                    });
                                  },
                                );
                              },
                            ),
                          const SizedBox(height: 12),
                          if (selectedRoomId != null)
                            StreamBuilder<List<Bed>>(
                              stream: _bedService.getBedsForRoom(
                                selectedRoomId!,
                              ),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }
                                final allBeds = snapshot.data!;
                                beds =
                                    allBeds
                                        .where((b) => b.occupiedBy == null)
                                        .toList();
                                // If no free beds, don't show this room in the previous dropdown
                                if (beds.isEmpty) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    setState(() {
                                      selectedRoomId = null;
                                    });
                                  });
                                  return const SizedBox();
                                }
                                return DropdownButtonFormField<String>(
                                  value: selectedBedId,
                                  decoration: const InputDecoration(
                                    labelText: 'Select Bed',
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      beds.map((b) {
                                        final bedNo =
                                            allBeds.indexWhere(
                                              (ab) => ab.id == b.id,
                                            ) +
                                            1;
                                        return DropdownMenuItem(
                                          value: b.id,
                                          child: Text('Bed $bedNo'),
                                        );
                                      }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      selectedBedId = val;
                                    });
                                  },
                                );
                              },
                            ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: mobileController,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                              prefixIcon: Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: rentController,
                            decoration: const InputDecoration(
                              labelText: 'Rent Price',
                              prefixIcon: Icon(Icons.attach_money_outlined),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kAccentColor,
                                  foregroundColor: Colors.white,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  if (selectedHostelId == null ||
                                      selectedRoomId == null ||
                                      selectedBedId == null) {
                                    return;
                                  }
                                  try {
                                    final studentData = Student(
                                      id: student?.id ?? '',
                                      name: nameController.text,
                                      mobileNo: mobileController.text,
                                      hostelId: selectedHostelId!,
                                      roomId: selectedRoomId!,
                                      bedId: selectedBedId!,
                                      rentPrice:
                                          int.tryParse(rentController.text) ??
                                          0,
                                      rentStatus: 'unpaid',
                                      joiningDate: DateTime.now(),
                                    );
                                    DocumentReference docRef = await _service
                                        .addStudentWithReturn(studentData);
                                    // Wait a bit to ensure Firestore sync
                                    await Future.delayed(
                                      Duration(milliseconds: 300),
                                    );
                                    // Mark bed as occupied
                                    await _bedService.updateBed(
                                      Bed(
                                        id: selectedBedId!,
                                        hostelId: selectedHostelId!,
                                        roomId: selectedRoomId!,
                                        occupiedBy: docRef.id,
                                      ),
                                    );
                                    if (mounted) Navigator.pop(context);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error saving student:  {e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: Text(student == null ? 'Add' : 'Update'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        title: const Text(
          'Students',
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: kWhite,
      body: StreamBuilder<List<Student>>(
        stream: _service.getStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return const Center(child: Text('No students found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final student = students[i];
              return Card(
                color: kWhite,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kPrimaryBlue.withOpacity(0.1),
                    child: Icon(Icons.person, color: kPrimaryBlue),
                  ),
                  title: Text(
                    student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mobile: ${student.mobileNo}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      FutureBuilder<Hostel?>(
                        future: _hostelService.getHostels().first.then(
                          (list) => list.firstWhere(
                            (h) => h.id == student.hostelId,
                            orElse:
                                () => Hostel(
                                  id: '',
                                  name: 'Unknown',
                                  address: '',
                                ),
                          ),
                        ),
                        builder:
                            (context, snap) => Text(
                              'Hostel: ${snap.data?.name ?? '...'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                      ),
                      FutureBuilder<Room?>(
                        future: _roomService.getRooms().first.then(
                          (list) => list.firstWhere(
                            (r) => r.id == student.roomId,
                            orElse:
                                () => Room(
                                  id: '',
                                  hostelId: '',
                                  roomNo: 'Unknown',
                                  totalBeds: 0,
                                  occupied: false,
                                ),
                          ),
                        ),
                        builder:
                            (context, snap) => Text(
                              'Room: ${snap.data?.roomNo ?? '...'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                      ),
                      FutureBuilder<List<Bed>>(
                        future:
                            _bedService.getBedsForRoom(student.roomId).first,
                        builder: (context, snap) {
                          final beds = snap.data ?? [];
                          final idx = beds.indexWhere(
                            (b) => b.id == student.bedId,
                          );
                          return Text(
                            'Bed: ${idx >= 0 ? idx + 1 : '...'}',
                            style: const TextStyle(fontSize: 14),
                          );
                        },
                      ),
                      Text(
                        'Rent: PKR ${student.rentPrice}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Rent Status: ${student.rentStatus}',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              student.rentStatus == 'paid'
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: kPrimaryBlue),
                        onPressed: () => _showStudentDialog(student: student),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: kRed),
                        onPressed:
                            () => _service.deleteStudent(
                              student.id,
                              bedId: student.bedId,
                              roomId: student.roomId,
                              hostelId: student.hostelId,
                            ),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStudentDialog(),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Student',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
