// lib/models/booking.dart

enum BookingStatus { menunggu, disetujui, ditolak }

class Booking {
  final String id;
  final String namaPegawai;
  final String divisi;
  final String namaRuangan;
  final DateTime tanggal;
  final String waktuMulai;
  final String waktuSelesai;
  final BookingStatus status;

  Booking({
    required this.id,
    required this.namaPegawai,
    required this.divisi,
    required this.namaRuangan,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuSelesai,
    this.status = BookingStatus.menunggu,
  });
}