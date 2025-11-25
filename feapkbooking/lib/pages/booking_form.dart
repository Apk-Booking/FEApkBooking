// lib/pages/booking_form.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';

// Ambil warna
const Color plnYellow = Color(0xFFF9A825);
const Color plnBlue = Color(0xFF0D47A1);

class BookingFormScreen extends StatefulWidget {
  final Booking? existingBooking;
  final String? selectedRoomName;

  const BookingFormScreen({
    Key? key,
    this.existingBooking,
    this.selectedRoomName,
  }) : super(key: key);

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  
  // HAPUS: _waktuController tidak dipakai lagi
  // final _waktuController = TextEditingController(); 

  String? _selectedDivisi;
  String? _selectedRuangan;
  DateTime? _selectedDate;
  
  // BARU: Variabel untuk menyimpan slot waktu yang dipilih
  String? _selectedTimeSlot; 

  BookingStatus _selectedStatus = BookingStatus.menunggu;
  bool _isLoading = false;
  bool _isInit = true;

  bool get isEditMode => widget.existingBooking != null;

  final List<String> _listDivisi = [
    'Distribusi', 'Transmisi', 'Pembangkitan', 'Keuangan', 'SDM', 'Hukum', 'IT'
  ];

  final List<String> _listRuangan = [
    'Ruang Sriwijaya', 'Ruang Majapahit', 'Ruang Rapat Utama', 
    'Ruang Rapat Lt.2', 'Ruang Rapat Lt.3', 'Ruang Rapat Lt.4'
  ];

  // BARU: Daftar Slot Waktu (Bisa disesuaikan kebutuhan)
  final List<String> _timeSlots = [
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
  ];

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final booking = widget.existingBooking!;
      _namaController.text = booking.namaPegawai;
      _selectedDivisi = booking.divisi;
      _selectedRuangan = booking.namaRuangan;
      _selectedDate = booking.tanggal;
      
      // Menggabungkan waktu lama ke format slot agar tombol terpilih otomatis
      // Format harus persis sama dengan yang ada di _timeSlots
      String combinedTime = '${booking.waktuMulai} - ${booking.waktuSelesai}';
      
      // Cek apakah waktu booking lama ada di list slot kita
      if (_timeSlots.contains(combinedTime)) {
        _selectedTimeSlot = combinedTime;
      } else {
        // Jika format lama beda (misal manual), kita biarkan kosong atau isi custom
        // Di sini kita biarkan null agar user memilih ulang slot yang valid
        _selectedTimeSlot = null; 
      }
      
      _selectedStatus = booking.status;
    } else if (widget.selectedRoomName != null) {
      _selectedRuangan = widget.selectedRoomName;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false); 
      if (!isEditMode) {
        final bool isAdmin = authProvider.userRole == UserRole.admin;
        
        if (!isAdmin) {
          _namaController.text = authProvider.namaUser;
        }
      }
    }
    _isInit = false;
  }

  @override
  void dispose() {
    _namaController.dispose();
    // _waktuController.dispose(); // Sudah dihapus
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime initialToShow = _selectedDate ?? today;

    if (initialToShow.isBefore(today)) {
      initialToShow = today;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialToShow,
      firstDate: today,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    // Validasi tambahan untuk TimeSlot
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedTimeSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap isi semua field, tanggal, dan jam')),
        );
      return;
    }

    setState(() { _isLoading = true; });
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    try {
      // Pecah string "08:00 - 09:00" menjadi dua bagian
      final splitTime = _selectedTimeSlot!.split(' - ');
      final String start = splitTime[0];
      final String end = splitTime[1];

      if (isEditMode) {
        final updatedBooking = Booking(
          id: widget.existingBooking!.id,
          namaPegawai: _namaController.text,
          divisi: _selectedDivisi!,
          namaRuangan: _selectedRuangan!,
          tanggal: _selectedDate!,
          waktuMulai: start, 
          waktuSelesai: end,
          status: _selectedStatus,
        );
        await bookingProvider.updateBooking(updatedBooking);
      } else {
        final newBooking = Booking(
          id: 'dummy_${DateTime.now().millisecondsSinceEpoch}',
          namaPegawai: _namaController.text,
          divisi: _selectedDivisi!,
          namaRuangan: _selectedRuangan!,
          tanggal: _selectedDate!,
          waktuMulai: start,
          waktuSelesai: end,
          status: _selectedStatus,
        );
        await bookingProvider.createBooking(newBooking);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil di-${isEditMode ? 'update' : 'tambah'}!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
        setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool isAdmin = authProvider.userRole == UserRole.admin;
    final bool isRoomLocked = (widget.selectedRoomName != null && !isEditMode);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.flash_on, color: plnYellow, size: 28),
            const SizedBox(width: 8),
            Text(isEditMode ? 'Edit Booking' : 'Tambah Booking Baru'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                readOnly: !isAdmin, 
                enabled: isAdmin,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap Pegawai',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: _selectedDivisi,
                decoration: const InputDecoration(
                  labelText: 'Divisi/Unit Kerja',
                  prefixIcon: Icon(Icons.corporate_fare_outlined),
                ),
                items: _listDivisi.map((String divisi) {
                  return DropdownMenuItem<String>(
                    value: divisi,
                    child: Text(divisi),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedDivisi = newValue),
                validator: (value) => value == null ? 'Pilih divisi' : null,
              ),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: _selectedRuangan,
                onChanged: isRoomLocked ? null : (newValue) => setState(() => _selectedRuangan = newValue),
                decoration: InputDecoration(
                  labelText: 'Ruang Rapat',
                  prefixIcon: const Icon(Icons.meeting_room_outlined),
                  filled: isRoomLocked,
                  fillColor: isRoomLocked ? Colors.grey[200] : Colors.white,
                ),
                items: _listRuangan.map((String ruangan) {
                  return DropdownMenuItem<String>(
                    value: ruangan,
                    child: Text(ruangan),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Pilih ruangan' : null,
              ),
              
              const SizedBox(height: 20),
              
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400, width: 0.5), // Tambahan border agar terlihat seperti input
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: plnBlue),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Pilih Tanggal Penggunaan'
                            : 'Tanggal: ${DateFormat('dd-MM-yyyy').format(_selectedDate!)}',
                        style: TextStyle(
                          fontSize: 16, 
                          color: _selectedDate == null ? Colors.grey[700] : Colors.black
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // --- BAGIAN PILIH JAM (CHIPS) ---
              const Text(
                'Pilih Jam Penggunaan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: plnBlue),
              ),
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.center, // Tengah
                  children: _timeSlots.map((timeSlot) {
                    final bool isSelected = _selectedTimeSlot == timeSlot;
                    return ChoiceChip(
                      label: Text(timeSlot),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      selected: isSelected,
                      selectedColor: plnBlue, // Warna saat dipilih
                      backgroundColor: Colors.grey[200], // Warna saat tidak dipilih (mirip screenshot)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? plnBlue : Colors.transparent,
                        )
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          // Jika diklik lagi, bisa di-unselect atau tetap (pilih salah satu)
                          // Di sini saya buat wajib pilih salah satu, jadi kalau sudah selected tidak bisa null
                          _selectedTimeSlot = selected ? timeSlot : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              // Validasi visual kecil jika user lupa pilih jam
              if (_selectedTimeSlot == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, left: 12),
                  child: Text(
                    'Mohon pilih salah satu slot waktu',
                    style: TextStyle(color: Color(0xFFD32F2F), fontSize: 12),
                  ),
                ),
              // ---------------------------------
              
              if (isAdmin && isEditMode) ...[
                const SizedBox(height: 20),
                DropdownButtonFormField<BookingStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status Persetujuan',
                    prefixIcon: Icon(Icons.shield_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: BookingStatus.menunggu,
                      child: Text('Menunggu Persetujuan'),
                    ),
                    DropdownMenuItem(
                      value: BookingStatus.disetujui,
                      child: Text('Disetujui'),
                    ),
                    DropdownMenuItem(
                      value: BookingStatus.ditolak,
                      child: Text('Ditolak'),
                    ),
                  ],
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                    }
                  },
                ),
              ],
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Text(isEditMode ? 'Update Booking' : 'Tambah Booking', 
                          style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}