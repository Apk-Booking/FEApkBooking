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
  final _waktuController = TextEditingController();
  
  String? _selectedDivisi;
  String? _selectedRuangan;
  DateTime? _selectedDate;
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

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final booking = widget.existingBooking!;
      _namaController.text = booking.namaPegawai;
      _selectedDivisi = booking.divisi;
      _selectedRuangan = booking.namaRuangan;
      _selectedDate = booking.tanggal;
      _waktuController.text = '${booking.waktuMulai}-${booking.waktuSelesai}';
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
    _waktuController.dispose();
    super.dispose();
  }

  // --- PERBAIKAN LOGIKA TANGGAL ---
  Future<void> _selectDate(BuildContext context) async {
    // 1. Tentukan "hari ini" (tanpa jam/menit)
    final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    // 2. Tentukan tanggal awal kalender
    DateTime initialToShow = _selectedDate ?? today;

    // 3. JIKA tanggal yang diedit (initialToShow) sudah lewat (sebelum hari ini),
    //    MAKA paksa kalender terbuka di hari ini.
    if (initialToShow.isBefore(today)) {
      initialToShow = today;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialToShow, // <-- Gunakan tanggal yang sudah diperbaiki
      firstDate: today, // <-- Gunakan 'today' sebagai tanggal paling awal
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  // --- BATAS PERBAIKAN ---

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap isi semua field dan tanggal')),
        );
      return;
    }
    setState(() { _isLoading = true; });
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    try {
      if (isEditMode) {
        final updatedBooking = Booking(
          id: widget.existingBooking!.id,
          namaPegawai: _namaController.text,
          divisi: _selectedDivisi!,
          namaRuangan: _selectedRuangan!,
          tanggal: _selectedDate!,
          waktuMulai: _waktuController.text.split('-')[0], 
          waktuSelesai: _waktuController.text.split('-')[1],
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
          waktuMulai: _waktuController.text.split('-')[0],
          waktuSelesai: _waktuController.text.split('-')[1],
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
              const SizedBox(height: 20),
              TextFormField(
                controller: _waktuController,
                decoration: const InputDecoration(
                  labelText: 'Jam Penggunaan',
                  hintText: 'Contoh: 09:00-11:00',
                  prefixIcon: Icon(Icons.access_time_outlined),
                ),
                validator: (value) {
                    if (value == null || value.isEmpty) return 'Jam tidak boleh kosong';
                    if (!value.contains('-')) return 'Format salah (Contoh: 09:00-11:00)';
                    return null;
                },
              ),
              
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