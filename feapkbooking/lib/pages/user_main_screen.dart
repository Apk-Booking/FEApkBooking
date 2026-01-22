// lib/pages/user_main_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../providers/auth_provider.dart';
import 'tabs/room_list_tab.dart';
import 'tabs/schedule_list_tab.dart';

// ================= WARNA =================
const Color plnRed = Color(0xFFD32F2F);
const Color plnYellow = Color(0xFFF9A825);
const Color plnBlue = Color(0xFF0D47A1);

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({Key? key}) : super(key: key);

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ================= DATA =================
  List<dynamic> ruangan = [];
  List<dynamic> booking = [];

  bool isLoadingRuangan = true;
  bool isLoadingBooking = true;

  // 🔴 PENTING: cegah fetch berulang
  bool _alreadyFetched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (!_alreadyFetched) {
      _alreadyFetched = true;
      fetchRuangan();
      fetchBooking();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.meeting_room),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Sistem Booking Ruangan",
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, size: 16),
            label: const Text('Logout'),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (route) => false);
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: plnRed,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: plnYellow,
          tabs: const [
            Tab(text: 'Daftar Ruangan'),
            Tab(text: 'Jadwal Booking'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          RoomListTab(
            ruangan: ruangan,
            isLoading: isLoadingRuangan,
          ),
          ScheduleListTab(
            booking: booking,
            isLoading: isLoadingBooking,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/booking_form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================= FETCH RUANGAN =================
  Future<void> fetchRuangan() async {
    const url = 'http://localhost:5000/api/user/get/allruangan';

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 202) {
        final json = jsonDecode(response.body);

        setState(() {
          ruangan = json['data'] ?? [];
          isLoadingRuangan = false;
        });
      } else {
        setState(() => isLoadingRuangan = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingRuangan = false);
      debugPrint('ERROR FETCH RUANGAN: $e');
    }
  }

  // ================= FETCH BOOKING =================
  Future<void> fetchBooking() async {
    const url = 'http://localhost:5000/api/user/get/allbooking';

    try {
      final response = await http.get(Uri.parse(url));

      if (!mounted) return;

      if (response.statusCode == 202) {
        final json = jsonDecode(response.body);

        setState(() {
          booking = json['data'] ?? [];
          isLoadingBooking = false;
        });
      } else {
        setState(() => isLoadingBooking = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingBooking = false);
      debugPrint('ERROR FETCH BOOKING: $e');
    }
  }
}
