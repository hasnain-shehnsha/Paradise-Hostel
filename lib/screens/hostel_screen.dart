import 'package:flutter/material.dart';
import '../models/hostel.dart';
import '../services/hostel_service.dart';

// Color constants for consistent modern UI
const kWhite = Color(0xFFFFFFFF);
const kPrimaryBlue = Color(0xFF1DA1F2);
const kRed = Color(0xFFE53935);
const kAccentColor = Color(0xFF42A5F5); // Adjust as needed for your accent

class HostelScreen extends StatefulWidget {
  const HostelScreen({super.key});

  @override
  State<HostelScreen> createState() => _HostelScreenState();
}

class _HostelScreenState extends State<HostelScreen> {
  final HostelService _service = HostelService();

  void _showHostelDialog({Hostel? hostel}) {
    final nameController = TextEditingController(text: hostel?.name ?? '');
    final addressController = TextEditingController(
      text: hostel?.address ?? '',
    );
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hostel == null ? 'Add Hostel' : 'Edit Hostel',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.apartment_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                          final hostelData = Hostel(
                            id: hostel?.id ?? '',
                            name: nameController.text,
                            address: addressController.text,
                          );
                          if (hostel == null) {
                            await _service.addHostel(hostelData);
                          } else {
                            await _service.updateHostel(hostelData);
                          }
                          if (mounted) Navigator.pop(context);
                        },
                        child: Text(hostel == null ? 'Add' : 'Update'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        title: const Text(
          'Hostels',
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: StreamBuilder<List<Hostel>>(
            stream: _service.getHostels(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final hostels = snapshot.data ?? [];
              if (hostels.isEmpty) {
                return const Center(child: Text('No hostels found.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 0,
                ),
                itemCount: hostels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final hostel = hostels[i];
                  return Card(
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          color: kPrimaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.apartment, color: kPrimaryBlue),
                      ),
                      title: Text(
                        hostel.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        hostel.address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      isThreeLine: false,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: kPrimaryBlue),
                            onPressed: () => _showHostelDialog(hostel: hostel),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: kRed),
                            onPressed: () => _service.deleteHostel(hostel.id),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showHostelDialog(),
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Hostel',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
