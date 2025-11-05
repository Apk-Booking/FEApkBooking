import 'package:feapkbooking/pages/booking_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.disetujui: return Colors.green;
      case BookingStatus.ditolak: return Colors.red;
      case BookingStatus.menunggu: default: return Colors.orange;
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
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
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Tambah Booking Baru',
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingFormScreen(existingBooking: null),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
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
                const Text(
                  'Kelola Booking Ruang Rapat',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total Booking',
                        totalBooking.toString(),
                        Colors.blue[800]!,
                        Icons.book_online,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Disetujui',
                        disetujui.toString(),
                        Colors.green[600]!,
                        Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Menunggu',
                        menunggu.toString(),
                        Colors.orange[700]!,
                        Icons.hourglass_top_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Semua Booking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // --- INI PERBAIKANNYA ---
                // Bungkus dengan SingleChildScrollView untuk scrolling horizontal
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // Beri lebar minimal selebar layar
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 32, // (lebar layar - padding)
                    ),
                    child: DataTable(
                      columnSpacing: 20, // Beri jarak antar kolom
                      horizontalMargin: 12,
                      columns: const [
                        DataColumn(label: Text('NAMA', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('RUANGAN', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('AKSI', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: allBookings.map((booking) {
                        return DataRow(
                          cells: [
                            DataCell(Text(booking.namaPegawai)),
                            DataCell(Text(booking.namaRuangan)),
                            DataCell(
                              Chip(
                                label: Text(
                                  _getStatusText(booking.status),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                                backgroundColor: _getStatusColor(booking.status),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 0),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    color: Colors.blue[700],
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookingFormScreen(
                                            existingBooking: booking,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    color: Colors.red[700],
                                    onPressed: () {
                                      _showDeleteConfirmDialog(context, booking);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // --- BATAS PERBAIKAN ---
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String count, Color color, IconData icon) {
    return Card(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}