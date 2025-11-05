// lib/pages/user_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/booking_card.dart';

// Ambil warna
const Color plnYellow = Color(0xFFF9A825);
const Color plnRed = Color(0xFFD32F2F);
const Color plnBlue = Color(0xFF0D47A1);

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Ruang Rapat'),
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

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Text(
                              'Booking Ruang Rapat',
                              style: TextStyle(
                                fontSize: 22, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // --- PERUBAHAN: Tombol Ikon Saja ---
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/booking_form');
                            },
                            child: const Icon(Icons.add, size: 24), // Hanya ikon
                            style: ElevatedButton.styleFrom(
                              backgroundColor: plnYellow, // Warna Kuning
                              foregroundColor: plnBlue, // Ikon Biru
                              minimumSize: const Size(48, 48), // Ukuran tombol
                              padding: EdgeInsets.zero, // Padding minimal
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          // --- BATAS PERUBAHAN ---
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lihat semua jadwal booking ruang rapat di PT PLN',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              if (allBookings.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'Belum ada booking di sistem.\nKlik tombol "+" untuk memulai.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final booking = allBookings[index];
                      return BookingCard(booking: booking);
                    },
                    childCount: allBookings.length,
                  ),
                ),
              
              const SliverToBoxAdapter(
                child: SizedBox(height: 80), // Jarak aman di bawah
              ),
            ],
          );
        },
      ),
    );
  }
}