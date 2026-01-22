import 'package:flutter/material.dart';

// ================= WARNA =================
const Color plnBlue = Color(0xFF0D47A1);
const Color plnGreen = Color(0xFF2E7D32);

class RoomListTab extends StatelessWidget {
  final List<dynamic> ruangan;
  final bool isLoading;

  const RoomListTab({
    super.key,
    required this.ruangan,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ruangan.isEmpty) {
      return const Center(child: Text('Data ruangan kosong'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: ruangan.length,
      itemBuilder: (context, index) {
        final item = ruangan[index];

        // Pecah deskripsi jadi badge
        final fasilitas = (item['deskripsi'] ?? '').toString().split(',');

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['namaruangan'] ?? '-',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.people, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Kapasitas: ${item['kapasitas']} orang',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Lantai: ${item['lantai']?.toString() ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // ================= FASILITAS =================
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: fasilitas.map((f) {
                              return Chip(
                                label: Text(
                                  f.trim(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.grey.shade200,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // RIGHT (STATUS)
                    const Text(
                      'Tersedia',
                      style: TextStyle(
                        color: plnGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/booking_form',
                      arguments: item,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: plnBlue,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Book Sekarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
