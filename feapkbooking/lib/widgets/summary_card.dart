// lib/widgets/summary_card.dart

import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final Color backgroundColor;
  final IconData icon;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.count,
    required this.backgroundColor,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kita TIDAK pakai Card() dari tema, tapi buat container sendiri
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor, // Warna solid
        borderRadius: BorderRadius.circular(12), // Sudut tumpul
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Teks (Kiri)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // 2. Ikon (Kanan)
          Icon(
            icon,
            color: Colors.white.withOpacity(0.8), // Ikon sedikit transparan
            size: 40,
          ),
        ],
      ),
    );
  }
}