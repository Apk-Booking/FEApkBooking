// lib/providers/booking_provider.dart

import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/dummy_data.dart';
import 'dart:async'; // Perlu import ini untuk Timer

class BookingProvider with ChangeNotifier {
  List<Booking> _allBookings = [];
  bool _isLoading = true;
  final String? _loggedInUserName;

  // Filter booking hanya milik user yang login
  List<Booking> get userBookings => _allBookings
      .where((b) => b.namaPegawai == _loggedInUserName)
      .toList();
      
  bool get isLoading => _isLoading;

  // Constructor
  BookingProvider(this._loggedInUserName) {
    _initData();
  }

  // Init data awal saat aplikasi dibuka
  Future<void> _initData() async {
    _isLoading = true;
    await Future.delayed(const Duration(milliseconds: 800));
    _allBookings = List.from(dummyBookings);
    _isLoading = false;
    notifyListeners();
  }

  // --- FUNGSI REFRESH ---
  // Dipanggil saat Pull-to-Refresh
  Future<void> fetchAllBookings() async {
    // Simulasi delay jaringan (misal: koneksi ke server Golang)
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));
    
    // Di real app: _allBookings = await ApiService.getBookings();
    
    // Memberitahu UI bahwa data sudah "segar" kembali
    notifyListeners(); 
  }

  // --- CREATE BOOKING (Dengan Simulasi Admin Menolak) ---
  Future<void> createBooking(Booking newBooking) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    _allBookings.add(newBooking);
    
    _isLoading = false;
    notifyListeners();

    // TRIGGER SIMULASI ADMIN: 
    // Setelah 5 detik, status otomatis berubah jadi Ditolak
    // (Biar Anda bisa tes fitur Refresh-nya)
    _simulateAdminResponse(newBooking.id);
  }

  void _simulateAdminResponse(String bookingId) {
    Timer(const Duration(seconds: 5), () {
      final index = _allBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        Booking original = _allBookings[index];
        
        // Ubah status jadi Ditolak
        _allBookings[index] = Booking(
          id: original.id,
          namaPegawai: original.namaPegawai,
          divisi: original.divisi,
          namaRuangan: original.namaRuangan,
          tanggal: original.tanggal,
          waktuMulai: original.waktuMulai,
          waktuSelesai: original.waktuSelesai,
          status: BookingStatus.ditolak, // <-- Status berubah di background
        );
        
        print("SIMULASI: Admin telah menolak booking ID $bookingId");
        // Kita TIDAK panggil notifyListeners() di sini agar user 
        // harus refresh manual untuk melihat perubahannya (Sesuai request Anda)
        // notifyListeners(); 
      }
    });
  }

  Future<void> updateBooking(Booking updatedBooking) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _allBookings.indexWhere((b) => b.id == updatedBooking.id);
    if (index != -1) {
      _allBookings[index] = updatedBooking;
    }
    
    _isLoading = false;
    notifyListeners();
  }
}