// lib/pages/dashboard/user_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/booking_card.dart';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Pegawai'),
        actions: [
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
          
          final userBookings = bookingProvider.userBookings;

          if (userBookings.isEmpty) {
            return const Center(child: Text('Anda belum memiliki booking.'));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Booking Ruang Rapat Anda',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text('Kelola semua booking ruang rapat Anda di PT PLN'),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = userBookings[index];
                    return BookingCard(booking: booking);
                  },
                  childCount: userBookings.length,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Buka form dalam mode Create (tanpa existingBooking)
          Navigator.pushNamed(context, '/booking_form');
        },
        icon: const Icon(Icons.add),
        label: const Text('Booking Baru'),
        backgroundColor: const Color(0xFFF9A000), // Kuning
        foregroundColor: const Color(0xFF005EA0), // Teks Biru
      ),
    );
  }
}