// lib/services/dummy_data.dart

import '../models/booking.dart';

// Data tiruan (nanti diganti API)
final List<Booking> dummyBookings = [
  Booking(
    id: '#1',
    namaPegawai: 'Budi Santoso',
    divisi: 'Distribusi',
    namaRuangan: 'Ruang Rapat Lt.2',
    tanggal: DateTime(2025, 11, 6),
    waktuMulai: '09:00',
    waktuSelesai: '11:00',
    status: BookingStatus.menunggu,
  ),
  Booking(
    id: '#2',
    namaPegawai: 'Ani Wijaya',
    divisi: 'Transmisi',
    namaRuangan: 'Ruang Rapat Lt.3',
    tanggal: DateTime(2025, 11, 6),
    waktuMulai: '13:00',
    waktuSelesai: '15:00',
    status: BookingStatus.disetujui,
  ),
  Booking(
    id: '#3',
    namaPegawai: 'Dewi Lestari',
    divisi: 'Keuangan',
    namaRuangan: 'Ruang Rapat Utama',
    tanggal: DateTime(2025, 11, 7),
    waktuMulai: '10:00',
    waktuSelesai: '12:00',
    status: BookingStatus.menunggu,
  ),
  Booking(
    id: '#4',
    namaPegawai: 'Andi Pratama',
    divisi: 'SDM',
    namaRuangan: 'Ruang Rapat Lt.2',
    tanggal: DateTime(2025, 11, 8),
    waktuMulai: '14:00',
    waktuSelesai: '16:00',
    status: BookingStatus.disetujui,
  ),
  Booking(
    id: '#5',
    namaPegawai: 'Diana',
    divisi: 'Pembangkitan',
    namaRuangan: 'Ruang Rapat Lt.2',
    tanggal: DateTime(2025, 11, 14),
    waktuMulai: '09:00',
    waktuSelesai: '14:30',
    status: BookingStatus.menunggu,
  ),
];