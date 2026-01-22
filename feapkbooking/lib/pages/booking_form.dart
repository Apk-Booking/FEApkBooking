// lib/screens/booking/booking_form_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

const Color plnBlue = Color(0xFF0D47A1);

class BookingFormScreen extends StatefulWidget {
  final String? selectedRoomName;
  final String? roomId;

  const BookingFormScreen({
    Key? key,
    this.selectedRoomName,
    this.roomId,
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

  // --- HIDANGAN ---
  String? _selectedHidangan;
  final List<String> _listHidangan = [
    'Tanpa Hidangan',
    'Snack Pagi',
    'Makan Siang',
    'Snack Sore',
    'Snack & Makan Siang',
  ];

  bool _isLoading = false;
  bool _isInit = true;

  // ✅ Lock divisi from auth
  final bool _lockDivisi = true;

  final List<String> _listDivisi = [
    'Distribusi',
    'Transmisi',
    'Pembangkitan',
    'Keuangan',
    'SDM',
    'Hukum',
    'IT',
  ];

  final List<String> _timeSlots = [
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
  ];

  // ✅ booking slots yang sudah terpakai pada tanggal yang dipilih
  final Set<String> _bookedSlots = {};

  // ✅ loading state saat fetch booking by date
  bool _isFetchingBookedSlots = false;

  @override
  void initState() {
    super.initState();

    if (widget.roomId != null) {
      fetchRuanganSatu(widget.roomId!);
    }

    if (widget.selectedRoomName != null) {
      _selectedRuangan = widget.selectedRoomName;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      _namaController.text = authProvider.namaUser;

      final divisiFromAuth = authProvider.divisiUser.trim();
      if (divisiFromAuth.isNotEmpty) {
        _selectedDivisi = divisiFromAuth;
      }

      _isInit = false;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  // ===================== DATE PICKER =====================
  Future<void> _selectDate(BuildContext context) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // reset pilihan waktu saat ganti tanggal
        _bookedSlots.clear(); // clear slot sebelum fetch ulang
      });

      // ✅ fetch booking berdasarkan tanggal yang dipilih
      await fetchBookedSlotsByDate(picked);
    }
  }

  // ===================== SUBMIT =====================
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedTimeSlot == null ||
        _selectedHidangan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data')),
      );
      return;
    }

    // ❗ prevent submit jika slot sudah dibooking
    if (_bookedSlots.contains(_selectedTimeSlot)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Sesi waktu sudah dibooking. Pilih waktu lain.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final DateTime dateWithTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        0,
        0,
        0,
      );

      final String formattedTanggal =
          "${DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dateWithTime)}+07:00";

      await fetchAddBooking(
        namaPemohon: _namaController.text,
        divisi: _selectedDivisi!,
        ruangan: _selectedRuangan!,
        tanggal: formattedTanggal,
        sesi: _selectedTimeSlot!,
        hidangan: _selectedHidangan!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking berhasil diajukan')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim booking: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    final isRoomLocked = widget.selectedRoomName != null;

    // fallback: jika divisi dari auth tidak ada di list, tetap tampil
    final List<String> divisiDropdownItems =
        _listDivisi.contains(_selectedDivisi)
            ? _listDivisi
            : [
                ..._listDivisi,
                if (_selectedDivisi != null && _selectedDivisi!.isNotEmpty)
                  _selectedDivisi!,
              ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Form Booking Ruangan',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _namaController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Nama Pemohon',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.person, color: Colors.black),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedDivisi,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Divisi',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.business, color: Colors.black),
                ),
                items: divisiDropdownItems
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style: const TextStyle(color: Colors.black)),
                        ))
                    .toList(),
                onChanged: _lockDivisi
                    ? null
                    : (val) => setState(() => _selectedDivisi = val),
                validator: (val) => val == null ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedRuangan,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Ruangan',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.meeting_room, color: Colors.black),
                ),
                onChanged: isRoomLocked
                    ? null
                    : (val) => setState(() => _selectedRuangan = val),
                validator: (val) => val == null ? 'Wajib diisi' : null,
                items: _selectedRuangan == null
                    ? []
                    : [
                        DropdownMenuItem(
                          value: _selectedRuangan,
                          child: Text(_selectedRuangan!,
                              style: const TextStyle(color: Colors.black)),
                        )
                      ],
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: plnBlue),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Pilih Tanggal'
                            : DateFormat('dd-MM-yyyy').format(_selectedDate!),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const Spacer(),
                      if (_isFetchingBookedSlots)
                        const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Pilih Sesi Waktu',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),

              // ================== INI WRAP SLOT WAKTU ==================
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.map((slot) {
                  final bool isBooked = _bookedSlots.contains(slot);

                  return ChoiceChip(
                    label: Text(
                      slot,
                      style: TextStyle(
                        color: isBooked ? Colors.grey : Colors.black,
                        decoration: isBooked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    selected: _selectedTimeSlot == slot,
                    selectedColor: plnBlue.withOpacity(0.25),
                    backgroundColor: Colors.grey.shade100,
                    disabledColor: Colors.grey.shade300,
                    onSelected: isBooked
                        ? null // ⛔ slot booked tidak bisa diklik
                        : (selected) {
                            setState(() {
                              _selectedTimeSlot = selected ? slot : null;
                            });
                          },
                  );
                }).toList(),
              ),
// ================== AKHIR WRAP ==================

              if (_selectedDate != null && _bookedSlots.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Slot terpakai: ${_bookedSlots.join(", ")}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],

              const SizedBox(height: 24),

              const Text(
                'Pilih Hidangan',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedHidangan,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Jenis Hidangan',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.fastfood, color: Colors.black),
                ),
                items: _listHidangan
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e,
                              style: const TextStyle(color: Colors.black)),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedHidangan = val),
                validator: (val) => val == null ? 'Wajib diisi' : null,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed:
                    (_isLoading || _isFetchingBookedSlots) ? null : _submitForm,
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

  // ===================== API =====================

  Future<void> fetchRuanganSatu(String roomId) async {
    final url =
        Uri.parse('meetyuk-d4d37074a638.herokuapp.com/api/user/get-one/ruangan/$roomId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      // NOTE: kamu sebelumnya pakai: data['NamaRuangan']
      // Sesuaikan dengan response asli backend kamu
      final nama = body['data']?['namaruangan'] ??
          body['data']?['NamaRuangan'] ??
          body['namaruangan'] ??
          body['NamaRuangan'];

      setState(() {
        _selectedRuangan = nama?.toString();
      });
    } else {
      debugPrint(
          'Gagal fetch ruangan: ${response.statusCode} ${response.body}');
    }
  }

  /// ✅ GET booked slots by date
  /// endpoint: /api/user/get/book-ruangan/date?date=YYYY-MM-DD
  /// response data: [{ "Ruangan": "...", "Waktu": "09:00 - 10:00", ... }, ...]
  Future<void> fetchBookedSlotsByDate(DateTime date) async {
    final dateParam = DateFormat('yyyy-MM-dd').format(date);
    final url = Uri.parse(
      'meetyuk-d4d37074a638.herokuapp.com/api/user/get/book-ruangan/date?date=$dateParam',
    );

    setState(() {
      _isFetchingBookedSlots = true;
      _bookedSlots.clear();
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final List<dynamic> data = (json['data'] as List?) ?? [];

        // IMPORTANT:
        // API kamu mengembalikan booking untuk semua ruangan di tanggal itu.
        // Kita filter hanya untuk ruangan yang sedang dipilih.
        final selectedRoom = _selectedRuangan?.trim();

        final Set<String> slots = {};
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            final waktu =
                item['waktu']?.toString() ?? item['Waktu']?.toString();
            final ruangan =
                item['ruangan']?.toString() ?? item['Ruangan']?.toString();

            // filter ruangan jika ada selectedRoom
            if (selectedRoom != null &&
                selectedRoom.isNotEmpty &&
                ruangan != null &&
                ruangan.toString().trim() != selectedRoom) {
              continue;
            }

            if (waktu != null && waktu.isNotEmpty) {
              slots.add(waktu.trim());
            }
          }
        }

        if (mounted) {
          setState(() {
            _bookedSlots
              ..clear()
              ..addAll(slots);
          });
        }

        // 🔍 DEBUG (LETTAKKAN DI SINI)
        debugPrint('BOOKED SLOTS: $_bookedSlots');
      } else {
        // kalau response bukan 200, tetap dianggap tidak ada booking
        debugPrint(
            'Fetch booked slots failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Fetch booked slots error: $e');
    } finally {
      if (mounted) {
        setState(() => _isFetchingBookedSlots = false);
      }
    }
  }

  Future<void> fetchAddBooking({
    required String namaPemohon,
    required String divisi,
    required String ruangan,
    required String tanggal,
    required String sesi,
    required String hidangan,
  }) async {
    final url = Uri.parse('meetyuk-d4d37074a638.herokuapp.com/api/user/createbooking');

    final payload = {
      'namapeminjam': namaPemohon,
      'Unit': divisi,
      'Ruangan': ruangan,
      'Tanggal': tanggal,
      'Waktu': sesi,
      'hidangan': hidangan,
    };

    debugPrint('PAYLOAD BOOKING => ${jsonEncode(payload)}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201 &&
        response.statusCode != 202) {
      throw Exception(response.body);
    }
  }
}
