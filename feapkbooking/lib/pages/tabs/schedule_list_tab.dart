// lib/pages/tabs/schedule_list_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import 'package:feapkbooking/widgets/booking_card.dart';

class ScheduleListTab extends StatelessWidget {
  const ScheduleListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, bookingProvider, child) {
        if (bookingProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allBookings = bookingProvider.allBookings;

        if (allBookings.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada jadwal booking.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // Tampilkan sebagai list
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
          itemCount: allBookings.length,
          itemBuilder: (context, index) {
            final booking = allBookings[index];
            return BookingCard(booking: booking); // Baris ini HARUSNYA sudah benar
          },
        );
      },
    );
  }
}