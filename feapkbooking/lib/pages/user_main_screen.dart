// lib/pages/user_main_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'tabs/room_list_tab.dart';
import 'tabs/schedule_list_tab.dart';

// Definisikan warna
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.meeting_room),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Sistem Booking Ruangan", 
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ],
        ),
        actions: [
          // --- PERBAIKAN: GANTI IconButton DENGAN TextButton ---
          Center(
            child: TextButton.icon(
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
                backgroundColor: plnRed, // Warna merah
                foregroundColor: Colors.white, // Teks putih
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14
                ),
              ),
            ),
          ),
          const SizedBox(width: 8), // Beri jarak
          // --- BATAS PERBAIKAN ---
        ],
        
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          labelColor: Colors.white, 
          unselectedLabelColor: Colors.white.withOpacity(0.7), 
          indicatorColor: plnYellow,
          indicatorWeight: 3.0, 
          tabs: const [
            Tab(text: 'Daftar Ruangan'),
            Tab(text: 'Jadwal Booking'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          RoomListTab(),
          ScheduleListTab(),
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
}