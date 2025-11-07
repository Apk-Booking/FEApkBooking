// lib/services/dummy_room_data.dart

import '../models/room.dart';

// Data tiruan untuk daftar ruangan
final List<Room> dummyRooms = [
  Room(
    id: 'R1',
    nama: 'Ruang Sriwijaya',
    kapasitas: 20,
    lantai: 3,
    fasilitas: ['Proyektor', 'Whiteboard', 'AC', 'WiFi'],
  ),
  Room(
    id: 'R2',
    nama: 'Ruang Majapahit',
    kapasitas: 15,
    lantai: 3,
    fasilitas: ['Proyektor', 'AC'],
  ),
  Room(
    id: 'R3',
    nama: 'Ruang Rapat Utama',
    kapasitas: 30,
    lantai: 1,
    fasilitas: ['Proyektor', 'Video Conference', 'AC', 'WiFi'],
  ),
  Room(
    id: 'R4',
    nama: 'Ruang Rapat Lt.2',
    kapasitas: 15,
    lantai: 2,
    fasilitas: ['Proyektor', 'Whiteboard', 'AC'],
  ),
  Room(
    id: 'R5',
    nama: 'Ruang Rapat Lt.3',
    kapasitas: 20,
    lantai: 3,
    fasilitas: ['Proyektor', 'Whiteboard', 'AC', 'WiFi'],
  ),
  Room(
    id: 'R6',
    nama: 'Ruang Rapat Lt.4',
    kapasitas: 10,
    lantai: 4,
    fasilitas: ['Proyektor', 'AC'],
  ),
];