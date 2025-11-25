// lib/pages/booking_form.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';

const Color plnYellow = Color(0xFFF9A825);
const Color plnBlue = Color(0xFF0D47A1);

class BookingFormScreen extends StatefulWidget {
  // User biasanya jarang edit booking yang sudah diajukan (biasanya cancel & buat baru), 
  // tapi kita biarkan fitur edit data mentah (nama/jam) tetap ada jika status masih menunggu.
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
  
  String? _selectedDivisi;
  String? _selectedRuangan;
  DateTime? _selectedDate;
  String? _selectedTimeSlot; 

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

  final List<String> _timeSlots = [
    '08:00 - 09:00', '09:00 - 10:00', '10:00 - 11:00', '11:00 - 12:00',
    '13:00 - 14:00', '14:00 - 15:00', '15:00 - 16:00',
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
      
      String combinedTime = '${booking.waktuMulai} - ${booking.waktuSelesai}';
      if (_timeSlots.contains(combinedTime)) {
        _selectedTimeSlot = combinedTime;
      }
    } else if (widget.selectedRoomName != null) {
      _selectedRuangan = widget.selectedRoomName;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false); 
      // Otomatis isi nama user yang login
      if (!isEditMode) {
        _namaController.text = authProvider.namaUser;
      }
    }
    _isInit = false;
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime initialToShow = _selectedDate ?? today;
    if (initialToShow.isBefore(today)) initialToShow = today;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialToShow,
      firstDate: today,
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedTimeSlot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap lengkapi semua data')),
        );
      return;
    }

    setState(() { _isLoading = true; });
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    try {
      final splitTime = _selectedTimeSlot!.split(' - ');
      final String start = splitTime[0];
      final String end = splitTime[1];

      // Default status selalu MENUNGGU saat submit dari Mobile User
      const BookingStatus defaultStatus = BookingStatus.menunggu;

      if (isEditMode) {
        final updatedBooking = Booking(
          id: widget.existingBooking!.id,
          namaPegawai: _namaController.text,
          divisi: _selectedDivisi!,
          namaRuangan: _selectedRuangan!,
          tanggal: _selectedDate!,
          waktuMulai: start, 
          waktuSelesai: end,
          status: widget.existingBooking!.status, // Pertahankan status lama jika edit
        );
        await bookingProvider.updateBooking(updatedBooking);
      } else {
        final newBooking = Booking(
          id: 'b_${DateTime.now().millisecondsSinceEpoch}', // ID dummy
          namaPegawai: _namaController.text,
          divisi: _selectedDivisi!,
          namaRuangan: _selectedRuangan!,
          tanggal: _selectedDate!,
          waktuMulai: start,
          waktuSelesai: end,
          status: defaultStatus, // User submit -> Menunggu
        );
        await bookingProvider.createBooking(newBooking);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permintaan booking terkirim! Menunggu konfirmasi Admin.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
        if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kita hapus cek isAdmin karena form ini khusus flow User
    final bool isRoomLocked = (widget.selectedRoomName != null && !isEditMode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Booking Ruangan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Field Nama (Read Only karena otomatis dari akun login)
              TextFormField(
                controller: _namaController,
                readOnly: true, 
                decoration: const InputDecoration(
                  labelText: 'Nama Pemohon',
                  prefixIcon: Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: _selectedDivisi,
                decoration: const InputDecoration(
                  labelText: 'Divisi',
                  prefixIcon: Icon(Icons.corporate_fare),
                ),
                items: _listDivisi.map((divisi) => DropdownMenuItem(value: divisi, child: Text(divisi))).toList(),
                onChanged: (val) => setState(() => _selectedDivisi = val),
                validator: (val) => val == null ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: _selectedRuangan,
                onChanged: isRoomLocked ? null : (val) => setState(() => _selectedRuangan = val),
                decoration: const InputDecoration(
                  labelText: 'Ruangan',
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                items: _listRuangan.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                validator: (val) => val == null ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: plnBlue),
                      const SizedBox(width: 12),
                      Text(_selectedDate == null ? 'Pilih Tanggal' : DateFormat('dd-MM-yyyy').format(_selectedDate!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text('Pilih Sesi Waktu', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _timeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    selectedColor: plnBlue,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                    onSelected: (selected) => setState(() => _selectedTimeSlot = selected ? slot : null),
                  );
                }).toList(),
              ),

              // HAPUS DROPDOWN STATUS ADMIN DARI SINI
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Ajukan Booking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}