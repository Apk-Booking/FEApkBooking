import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleListTab extends StatelessWidget {
  final List<dynamic> booking;
  final bool isLoading;

  const ScheduleListTab({
    super.key,
    required this.booking,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (booking.isEmpty) {
      return const Center(child: Text('Belum ada jadwal booking'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: booking.length,
      itemBuilder: (context, index) {
        final item = booking[index];

        // ================= FORMAT TANGGAL =================
        String tanggalFormatted = '-';
        if (item['Tanggal'] != null) {
          final date = DateTime.parse(item['Tanggal']).toLocal();
          tanggalFormatted = DateFormat('dd MMM yyyy').format(date);
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.meeting_room, color: Colors.blue),
            title: Text(
              item['Ruangan'] ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Tanggal  : $tanggalFormatted'),
                Text('Waktu    : ${item['Waktu'] ?? '-'}'),
                Text('Unit     : ${item['Unit'] ?? '-'}'),
                Text('Pemohon  : ${item['namapeminjam'] ?? '-'}'),
                Text('Hidangan : ${item['hidangan'] ?? '-'}'), // ✅ TAMBAHAN
              ],
            ),
          ),
        );
      },
    );
  }
}
