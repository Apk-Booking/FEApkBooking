// lib/widgets/booking_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';

// Definisi Warna PLN
const Color plnGreen = Color(0xFF388E3C);
const Color plnOrange = Color(0xFFF57C00);
const Color plnRed = Color(0xFFD32F2F);
const Color plnBlue = Color(0xFF0D47A1);

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.disetujui: return plnGreen;
      case BookingStatus.ditolak: return plnRed;
      default: return plnOrange;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.disetujui: return 'Disetujui';
      case BookingStatus.ditolak: return 'Ditolak (Penuh)';
      default: return 'Menunggu Konfirmasi';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: NAMA RUANGAN & STATUS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking.namaRuangan,
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 11, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
            
            // --- PESAN ERROR (JIKA DITOLAK) ---
            if (booking.status == BookingStatus.ditolak) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: plnRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: plnRed.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 18, color: plnRed),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Mohon maaf, slot waktu tersebut sudah penuh. Silakan pilih waktu lain.",
                        style: TextStyle(color: plnRed, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 24, thickness: 1),

            // --- DETAIL INFORMASI ---
            
            // 1. TAMPILKAN NAMA PEGAWAI DI SINI
            _rowInfo(Icons.person, booking.namaPegawai, isBold: true), 
            
            const SizedBox(height: 6), // Jarak dikit
            
            // 2. TANGGAL
            _rowInfo(Icons.calendar_today_outlined, DateFormat('dd MMMM yyyy').format(booking.tanggal)),
            
            // 3. JAM
            _rowInfo(Icons.access_time, '${booking.waktuMulai} - ${booking.waktuSelesai} WIB'),
            
            // 4. DIVISI
            _rowInfo(Icons.corporate_fare_outlined, booking.divisi),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Baris Detail
  Widget _rowInfo(IconData icon, String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]), // Icon abu-abu
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text, 
              style: TextStyle(
                fontSize: 14, 
                color: Colors.black87,
                // Jika nama pegawai (isBold=true), kita tebalkan sedikit
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}