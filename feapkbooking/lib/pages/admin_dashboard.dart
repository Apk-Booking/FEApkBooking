// lib/pages/admin_dashboard.dart

import 'package:feapkbooking/pages/booking_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/summary_card.dart'; 

// Definisikan warna di sini
const Color plnBlue = Color(0xFF0D47A1);
const Color plnGreen = Color(0xFF388E3C);
const Color plnOrange = Color(0xFFF57C00);
const Color plnRed = Color(0xFFD32F2F);
const Color plnStatusRed = Color(0xFFC62828);

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.disetujui: return plnGreen;
      case BookingStatus.ditolak: return plnStatusRed;
      case BookingStatus.menunggu: default: return plnOrange;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.disetujui: return 'Disetujui';
      case BookingStatus.ditolak: return 'Ditolak';
      case BookingStatus.menunggu: default: return 'Menunggu';
    }
  }

  Future<void> _showDeleteConfirmDialog(
      BuildContext context, Booking booking) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Booking'),
          content: Text(
              'Anda yakin ingin menghapus booking atas nama ${booking.namaPegawai}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () {
                Provider.of<BookingProvider>(context, listen: false)
                    .deleteBooking(booking.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.logout, size: 16),
              label: const Text('Logout'),
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: plnRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          
          if (bookingProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allBookings = bookingProvider.allBookings;
          final int totalBooking = allBookings.length;
          final int disetujui = allBookings
              .where((b) => b.status == BookingStatus.disetujui)
              .length;
          final int menunggu = allBookings
              .where((b) => b.status == BookingStatus.menunggu)
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'Kelola Booking Ruang Rapat',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8), 
                    
                    ElevatedButton(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(
                            // --- PANGGILAN YANG BENAR (TANPA PARAMETER) ---
                            builder: (context) => const BookingFormScreen(),
                          ),
                        );
                      },
                      child: const Icon(Icons.add, size: 24),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                
                SummaryCard(
                  title: 'Total Booking',
                  count: totalBooking.toString(),
                  backgroundColor: plnBlue,
                  icon: Icons.book_online, 
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  title: 'Disetujui',
                  count: disetujui.toString(),
                  backgroundColor: plnGreen,
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  title: 'Menunggu',
                  count: menunggu.toString(),
                  backgroundColor: plnOrange,
                  icon: Icons.hourglass_top_outlined,
                ),
                
                const SizedBox(height: 24),
                const Text(
                  'Semua Booking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (allBookings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Center(
                      child: Text(
                        'Belum ada booking.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    itemCount: allBookings.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final booking = allBookings[index];
                      return _buildAdminBookingTile(context, booking);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Widget list interaktif
  Widget _buildAdminBookingTile(BuildContext context, Booking booking) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // --- PANGGILAN YANG BENAR (DENGAN PARAMETER) ---
              builder: (context) => BookingFormScreen(existingBooking: booking),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.namaPegawai,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      booking.divisi,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      booking.namaRuangan,
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${DateFormat('dd/MM/yy').format(booking.tanggal)}  (${booking.waktuMulai}-${booking.waktuSelesai})',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(_getStatusText(booking.status)),
                backgroundColor: _getStatusColor(booking.status),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 22),
                color: Colors.red[700],
                onPressed: () {
                  _showDeleteConfirmDialog(context, booking);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}