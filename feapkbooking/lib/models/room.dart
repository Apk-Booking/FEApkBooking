// lib/models/room.dart

class Room {
  final String id;
  final String nama;
  final int kapasitas;
  final int lantai;
  final List<String> fasilitas;

  Room({
    required this.id,
    required this.nama,
    required this.kapasitas,
    required this.lantai,
    required this.fasilitas,
  });
}