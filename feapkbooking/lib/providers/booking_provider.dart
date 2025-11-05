// lib/providers/booking_provider.dart

import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/dummy_data.dart'; // Nanti ini diganti API Service

class BookingProvider with ChangeNotifier {
  List<Booking> _allBookings = [];
  bool _isLoading = false;

  // Getter
  List<Booking> get allBookings => _allBookings;
  List<Booking> get userBookings => _allBookings
      .where((b) =>
          b.namaPegawai == 'Budi Santoso' || b.namaPegawai == 'Diana')
      .toList();
  
  bool get isLoading => _isLoading;

  BookingProvider() {
    fetchAllBookings();
  }

  Future<void> fetchAllBookings() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _allBookings = List.from(dummyBookings); // Salin list agar tidak terikat
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBooking(Booking newBooking) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _allBookings.add(newBooking);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateBooking(Booking updatedBooking) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _allBookings.indexWhere((b) => b.id == updatedBooking.id);
    if (index != -1) {
      _allBookings[index] = updatedBooking;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _allBookings.removeWhere((b) => b.id == bookingId);
    notifyListeners();
  }
}