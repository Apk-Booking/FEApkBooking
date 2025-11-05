// lib/widgets/booking_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.disetujui:
        return Colors.green[600]!;
      case BookingStatus.ditolak:
        return Colors.red[600]!;
      case BookingStatus.menunggu:
      default:
        return Colors.orange[700]!;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.disetujui:
        return 'Disetujui';
      case BookingStatus.ditolak:
        return 'Ditolak';
      case BookingStatus.menunggu:
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.namaRuangan,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'ID Booking: ${booking.id}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Divider(height: 24),
            _buildDetailRow(
                Icons.person_outline, 'Nama Pegawai', booking.namaPegawai),
            _buildDetailRow(
                Icons.corporate_fare_outlined, 'Divisi', booking.divisi),
            _buildDetailRow(
                Icons.calendar_today_outlined,
                'Tanggal',
                DateFormat('EEEE, dd MMMM yyyy').format(booking.tanggal)),
            _buildDetailRow(Icons.access_time_outlined, 'Waktu',
                '${booking.waktuMulai} - ${booking.waktuSelesai}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF005EA0), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }
}