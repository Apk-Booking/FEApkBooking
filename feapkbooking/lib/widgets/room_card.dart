// lib/widgets/room_card.dart

import 'package:flutter/material.dart';
import '../models/room.dart';
import '../pages/booking_form.dart'; // Import form booking

// Definisikan warna
const Color plnBlue = Color(0xFF0D47A1);
const Color plnGreen = Color(0xFF388E3C);

class RoomCard extends StatelessWidget {
  final Room room;
  const RoomCard({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      room.nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Tersedia',
                      style: TextStyle(
                        color: plnGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                    Icons.people_outline, 'Kapasitas: ${room.kapasitas} orang'),
                const SizedBox(height: 4),
                _buildInfoRow(
                    Icons.location_on_outlined, 'Lantai: ${room.lantai}'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: room.fasilitas.map((fasilitas) {
                    return Chip(
                      label: Text(fasilitas),
                      backgroundColor: Colors.grey[200],
                      labelStyle:
                          const TextStyle(fontSize: 10, color: Colors.black54),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingFormScreen(
                      selectedRoomName: room.nama,
                    ),
                  ),
                );
              },
              child: const Text('Book Sekarang'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }
}
