import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/room_service.dart';
import '../services/hostel_service.dart';
import '../services/bed_service.dart';
import '../models/hostel.dart';
import 'bed_list_screen.dart';
import '../widgets/room_bed_status.dart';
import '../models/bed.dart';
// ...existing imports...
// Unified color constants for consistent modern UI
const kWhite = Color(0xFFFFFFFF);
const kPrimaryBlue = Color(0xFF1DA1F2);
const kRed = Color(0xFFE53935);
const kAccentColor = Color(0xFF42A5F5); // Accent (optional, can use kPrimaryBlue)


class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  String searchQuery = '';
  final RoomService _service = RoomService();
  final HostelService _hostelService = HostelService();
  final BedService _bedService = BedService();
  String? selectedHostelId;
  String? selectedHostelName;

  void _showRoomDialog({Room? room}) async {
    final roomNoController = TextEditingController(text: room?.roomNo ?? '');
    final totalBedsController = TextEditingController(
      text: room?.totalBeds.toString() ?? '',
    );

    // By default, new rooms are free (not occupied)
    bool occupied = room?.occupied ?? false;
    await showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: StatefulBuilder(
                builder:
                    (context, setStateDialog) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          room == null ? 'Add Room' : 'Edit Room',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: roomNoController,
                          decoration: InputDecoration(
                            labelText: 'Room No',
                            prefixIcon: Icon(Icons.meeting_room_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: totalBedsController,
                          decoration: InputDecoration(
                            labelText: 'Total Beds',
                            prefixIcon: Icon(Icons.bed_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          title: const Text('Occupied'),
                          value: occupied,
                          onChanged:
                              room == null
                                  ? null // Disable for new rooms
                                  : (val) {
                                    setStateDialog(() {
                                      occupied = val ?? false;
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
                                if (selectedHostelId == null) return;
                                final roomData = Room(
                                  id: room?.id ?? '',
                                  hostelId: selectedHostelId!,
                                  roomNo: roomNoController.text,
                                  totalBeds:
                                      int.tryParse(totalBedsController.text) ??
                                      0,
                                  occupied: occupied,
                                );
                                if (room == null) {
                                  final docRef = await _service
                                      .addRoomWithReturn(roomData);
                                  // Add beds for this room
                                  await _bedService.addBedsForRoom(
                                    hostelId: selectedHostelId!,
                                    roomId: docRef.id,
                                    count:
                                        int.tryParse(
                                          totalBedsController.text,
                                        ) ??
                                        0,
                                  );
                                } else {
                                  await _service.updateRoom(roomData);
                                }
                                if (mounted) Navigator.pop(context);
                              },
                              child: Text(room == null ? 'Add' : 'Update'),
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
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        title: const Text(
          'Rooms',
          style: TextStyle(
            color: kWhite,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      backgroundColor: kWhite,
      body:
          selectedHostelId == null
              ? FutureBuilder<List<Hostel>>(
                future: _hostelService.getHostels().first,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final hostels = snapshot.data ?? [];
                  if (hostels.isEmpty) {
                    return const Center(child: Text('No hostels found.'));
                  }
                  // Search bar for hostels
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search hostels',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              searchQuery = val.trim().toLowerCase();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          itemCount:
                              hostels
                                  .where(
                                    (hostel) => hostel.name
                                        .toLowerCase()
                                        .contains(searchQuery),
                                  )
                                  .length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final filteredHostels =
                                hostels
                                    .where(
                                      (hostel) => hostel.name
                                          .toLowerCase()
                                          .contains(searchQuery),
                                    )
                                    .toList();
                            final hostel = filteredHostels[i];
                            return Card(
                              color: kWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 8,
                                  top: 14,
                                  bottom: 0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hostel.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            hostel.address,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: kPrimaryBlue,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          selectedHostelId = hostel.id;
                                          selectedHostelName = hostel.name;
                                        });
                                      },
                                      tooltip: 'Show Rooms',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: kAccentColor,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedHostelId = null;
                              selectedHostelName = null;
                            });
                          },
                        ),
                        Text(
                          selectedHostelName ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: kAccentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search hostel rooms',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val.trim().toLowerCase();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<Room>>(
                      stream: _service.getRooms(hostelId: selectedHostelId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final rooms =
                            (snapshot.data ?? [])
                                .where(
                                  (room) => room.roomNo.toLowerCase().contains(
                                    searchQuery,
                                  ),
                                )
                                .toList();
                        if (rooms.isEmpty) {
                          return const Center(
                            child: Text('No rooms found for this hostel.'),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          itemCount: rooms.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final room = rooms[i];
                            return Card(
                              color: kWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 8,
                                      top: 14,
                                      bottom: 0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                room.roomNo,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Total beds: ${room.totalBeds}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              RoomBedStatus(
                                                roomId: room.id,
                                                totalBeds: room.totalBeds,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: kPrimaryBlue,
                                              ),
                                              onPressed:
                                                  () => _showRoomDialog(
                                                    room: room,
                                                  ),
                                              tooltip: 'Edit',
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: kRed,
                                              ),
                                              onPressed:
                                                  () => _service.deleteRoom(
                                                    room.id,
                                                  ),
                                              tooltip: 'Delete',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Bottom bar for available beds and details
                                  StreamBuilder<List<Bed>>(
                                    stream: BedService().getBedsForRoom(
                                      room.id,
                                    ),
                                    builder: (context, snapshot) {
                                      final beds = snapshot.data ?? [];
                                      final occupiedCount =
                                          beds
                                              .where(
                                                (b) => b.occupiedBy != null,
                                              )
                                              .length;
                                      final freeCount =
                                          beds.length - occupiedCount;
                                      final isOccupied =
                                          beds.isNotEmpty &&
                                          occupiedCount == beds.length;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: kPrimaryBlue,
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(18),
                                            bottomRight: Radius.circular(18),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            isOccupied
                                                ? const Text(
                                                  'Occupied',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                                : Text(
                                                  'Available Beds: $freeCount',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (_) => BedListScreen(
                                                          roomId: room.id,
                                                          hostelId:
                                                              room.hostelId,
                                                          roomNo: room.roomNo,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Row(
                                                children: const [
                                                  Text(
                                                    'details',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      floatingActionButton:
          selectedHostelId == null
              ? null
              : FloatingActionButton.extended(
                onPressed: () => _showRoomDialog(),
                backgroundColor: kPrimaryBlue,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Room',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
    );
  }
}
