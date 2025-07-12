import 'package:flutter/material.dart';
import '../models/maintenance_request.dart';
import '../services/maintenance_service.dart';
import '../widgets/modern_app_bar.dart';
import '../widgets/modern_card.dart';
import '../screens/dashboard_screen.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final MaintenanceService _service = MaintenanceService();

  void _showRequestDialog({MaintenanceRequest? request}) {
    final studentIdController = TextEditingController(
      text: request?.studentId ?? '',
    );
    final roomIdController = TextEditingController(text: request?.roomId ?? '');
    final issueController = TextEditingController(text: request?.issue ?? '');
    String status = request?.status ?? 'Pending';
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
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
                      request == null ? 'Add Request' : 'Edit Request',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: studentIdController,
                      decoration: InputDecoration(
                        labelText: 'Student ID',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roomIdController,
                      decoration: InputDecoration(
                        labelText: 'Room ID',
                        prefixIcon: Icon(Icons.meeting_room_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: issueController,
                      decoration: InputDecoration(
                        labelText: 'Issue',
                        prefixIcon: Icon(Icons.report_problem_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.info_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'In Progress',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(
                          value: 'Resolved',
                          child: Text('Resolved'),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          status = val ?? 'Pending';
                        });
                      },
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
                            backgroundColor: Colors.deepPurple,
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
                            final req = MaintenanceRequest(
                              id: request?.id ?? '',
                              studentId: studentIdController.text,
                              roomId: roomIdController.text,
                              issue: issueController.text,
                              status: status,
                              date: request?.date ?? DateTime.now(),
                            );
                            if (request == null) {
                              await _service.addRequest(req);
                            } else {
                              await _service.updateRequest(req);
                            }
                            if (mounted) Navigator.pop(context);
                          },
                          child: Text(request == null ? 'Add' : 'Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(title: 'Maintenance'),
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<List<MaintenanceRequest>>(
        stream: _service.getRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return const Center(child: Text('No maintenance requests found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final req = requests[i];
              return ModernCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    child: Icon(Icons.build, color: Colors.deepPurple),
                  ),
                  title: Text(
                    'Room: ${req.roomId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student: ${req.studentId}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Issue: ${req.issue}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Status: ${req.status}',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              req.status == 'Resolved'
                                  ? Colors.green
                                  : (req.status == 'In Progress'
                                      ? Colors.orange
                                      : Colors.red),
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.deepPurple),
                        onPressed: () => _showRequestDialog(request: req),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _service.deleteRequest(req.id),
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
        onPressed: () => _showRequestDialog(),
        backgroundColor: kAccentColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Request',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
