// lib/widgets/booking_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';

// Ambil warna dari main.dart (atau definisikan ulang di sini)
const Color plnStatusGreen = Color(0xFF2E7D32);
const Color plnStatusOrange = Color(0xFFEF6C00);
const Color plnStatusRed = Color(0xFFC62828); // Merah (Ditolak)
const Color plnBlue = Color(0xFF005EA0);

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.disetujui:
        return plnStatusGreen;
      case BookingStatus.ditolak:
        return plnStatusRed;
      case BookingStatus.menunggu:
      default:
        return plnStatusOrange;
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
    // Card ini akan otomatis mengambil tema (putih, rounded) dari main.dart
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                // Chip ini akan mengambil tema dari main.dart
                Chip(
                  label: Text(_getStatusText(booking.status)),
                  backgroundColor: _getStatusColor(booking.status),
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
          Icon(icon, color: plnBlue, size: 20), // Gunakan plnBlue
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