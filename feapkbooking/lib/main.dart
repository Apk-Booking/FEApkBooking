// lib/main.dart

import 'package:feapkbooking/auth/login_screen.dart';
import 'package:feapkbooking/auth/register_screen.dart';
import 'package:feapkbooking/pages/booking_form.dart';
import 'package:feapkbooking/pages/user_main_screen.dart'; 
import 'package:feapkbooking/providers/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// --- (Warna-warna PLN) ---
const Color plnBlue = Color(0xFF0D47A1);
const Color plnYellow = Color(0xFFF9A825);
const Color plnLightGray = Color(0xFFF4F7F9);
const Color plnRed = Color(0xFFD32F2F);
const Color plnGreen = Color(0xFF388E3C);
const Color plnOrange = Color(0xFFF57C00);
// --------------------------

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Intl.defaultLocale = 'id_ID';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, BookingProvider>(
          create: (context) => BookingProvider(null),
          update: (context, authProvider, previousBookingProvider) {
            return BookingProvider(authProvider.namaUser);
          },
        ),
      ],
      child: MaterialApp(
        title: 'PLN Booking App',
        debugShowCheckedModeBanner: false,

        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
        ],

        theme: ThemeData(
          primaryColor: plnBlue,
          scaffoldBackgroundColor: plnLightGray,
          fontFamily: GoogleFonts.poppins().fontFamily,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ).apply(
            bodyColor: const Color(0xFF333333),
            displayColor: const Color(0xFF333333),
          ),
          
          // --- PERBAIKAN TEMA KARTU (HAPUS MARGIN) ---
          cardTheme: CardThemeData(
            elevation: 1,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            // margin: ... (HAPUS INI AGAR RESPONSIVE)
          ),
          // --- BATAS PERBAIKAN ---

          appBarTheme: const AppBarTheme(
            backgroundColor: plnBlue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: plnBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              )
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: plnBlue, width: 2),
            ),
            prefixIconColor: plnBlue,
            iconColor: plnBlue,
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: plnYellow,
            foregroundColor: plnBlue,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          chipTheme: ChipThemeData(
            labelStyle: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 12
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          )
        ),
        
        home: const LoginScreen(),
        
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/user_dashboard': (context) => const UserMainScreen(),
          // '/admin_dashboard': (context) => const AdminDashboardScreen(), // HAPUS INI JUGA
          '/booking_form': (context) => const BookingFormScreen(),
        },
      ),
    );
  }
}