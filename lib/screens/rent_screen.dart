import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/student_service.dart';

// Unified color constants for consistent modern UI
const kWhite = Color(0xFFFFFFFF);
const kPrimaryBlue = Color(0xFF1DA1F2);
const kRed = Color(0xFFE53935);
const kAccentColor = Color(
  0xFF42A5F5,
); // Accent (optional, can use kPrimaryBlue)

class RentScreen extends StatefulWidget {
  const RentScreen({super.key});

  @override
  State<RentScreen> createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  final StudentService _studentService = StudentService();
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        title: const Text(
          'Rent',
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: kWhite,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged:
                  (val) => setState(() => _search = val.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _studentService.getStudents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final students =
                    snapshot.data!
                        .where((s) => (s.name).toLowerCase().contains(_search))
                        .toList();
                if (students.isEmpty) {
                  return const Center(child: Text('No students found.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final s = students[i];
                    return Card(
                      color: kWhite,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(
                          s.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mobile: ${s.mobileNo}'),
                            Text('Rent: PKR ${s.rentPrice}'),
                            Text(
                              'Status: ${s.rentStatus}',
                              style: TextStyle(
                                color:
                                    s.rentStatus == 'paid'
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: kPrimaryBlue,
                        ),
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: const Text('Receive Payment'),
                                  content: Text(
                                    'Mark rent as paid for ${s.name}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            await _studentService.updateStudent(
                              s.copyWith(rentStatus: 'paid'),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Payment received for ${s.name}',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
