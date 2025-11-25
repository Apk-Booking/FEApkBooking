// lib/pages/tabs/schedule_list_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/booking_card.dart';

class ScheduleListTab extends StatelessWidget {
  const ScheduleListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        // Data booking milik user yang login
        final myBookings = bookingProvider.userBookings;

        // --- FITUR PULL TO REFRESH ---
        return RefreshIndicator(
          // Logic saat ditarik: Panggil fungsi fetch data
          onRefresh: () async {
            await bookingProvider.fetchAllBookings();
          },
          child: myBookings.isEmpty
              ? _buildEmptyState() // Tampilan jika kosong
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
                  itemCount: myBookings.length,
                  // Physics ini WAJIB agar bisa ditarik (bounce effect)
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    // Balik urutan: Yang terbaru di paling atas
                    final booking = myBookings.reversed.toList()[index];
                    return BookingCard(booking: booking);
                  },
                ),
        );
      },
    );
  }

  // Widget tampilan saat data kosong
  Widget _buildEmptyState() {
    // Kita gunakan ListView (bukan Column biasa) agar layar tetap bisa
    // ditarik ke bawah (scrollable) untuk memicu refresh.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height * 0.3),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_edu, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                'Riwayat booking Anda kosong.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tarik ke bawah untuk menyegarkan',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}