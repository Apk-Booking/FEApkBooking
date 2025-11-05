// lib/main.dart

import 'package:feapkbooking/auth/login_screen.dart';
import 'package:feapkbooking/auth/register_screen.dart';
import 'package:feapkbooking/pages/admin_dashboard.dart';
import 'package:feapkbooking/pages/booking_form.dart';
import 'package:feapkbooking/pages/user_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

// Import Providers
import 'providers/auth_provider.dart';
import 'providers/booking_provider.dart';

void main() {
  // Atur default locale untuk format tanggal/waktu Indonesia
  Intl.defaultLocale = 'id_ID';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MultiProvider mendaftarkan semua state management di level tertinggi
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'PLN Booking App',
        debugShowCheckedModeBanner: false,

        // Konfigurasi untuk bahasa Indonesia (untuk format tanggal)
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
        ],

        // === TEMA APLIKASI ===
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF005EA0), // Warna biru PLN

          // Menggunakan Google Fonts "Poppins" untuk seluruh aplikasi
          fontFamily: GoogleFonts.poppins().fontFamily,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),

          // Tema untuk AppBar
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF005EA0),
            foregroundColor: Colors.white,
            elevation: 0,
          ),

          // Tema untuk Tombol
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005EA0), // Biru tua
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Tema untuk Input Form (TextFormField, Dropdown)
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF005EA0), width: 2),
            ),
            prefixIconColor: const Color(0xFF005EA0), // Warna ikon di form
            iconColor: const Color(0xFF005EA0), // Warna ikon di form
          ),
        ),
        // === AKHIR TEMA ===

        // Halaman awal saat aplikasi dibuka
        home: const LoginScreen(),
        
        // Daftar semua rute/halaman di aplikasi
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/user_dashboard': (context) => const UserDashboardScreen(),
          '/admin_dashboard': (context) => const AdminDashboardScreen(),
          // Rute ini menangani Create dan Edit
          '/booking_form': (context) => const BookingFormScreen(),
        },
      ),
    );
  }
}