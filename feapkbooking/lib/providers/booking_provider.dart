// lib/providers/booking_provider.dart

import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/dummy_data.dart'; 

class BookingProvider with ChangeNotifier {
  List<Booking> _allBookings = [];
  bool _isLoading = true;
  final String? _loggedInUserName; // <-- Variabel untuk simpan nama user

  List<Booking> get allBookings => _allBookings;
  
  // Filter dinamis berdasarkan nama user yang login
  List<Booking> get userBookings => _allBookings
      .where((b) => b.namaPegawai == _loggedInUserName) // <-- FILTER DINAMIS
      .toList();
  
  bool get isLoading => _isLoading;

  // Constructor diubah untuk menerima nama user
  BookingProvider(this._loggedInUserName) {
    fetchAllBookings();
  }

  Future<void> fetchAllBookings() async {
    _isLoading = true;
    // Jangan panggil notifyListeners() di sini saat _isLoading = true
    
    await Future.delayed(const Duration(milliseconds: 500));
    _allBookings = List.from(dummyBookings); 
    _isLoading = false;
    notifyListeners(); // Panggil setelah semua data siap
  }

  // Method CRUD lainnya sudah aman
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