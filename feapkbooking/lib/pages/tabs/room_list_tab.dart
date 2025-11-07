// lib/pages/tabs/room_list_tab.dart

import 'package:flutter/material.dart';
import '../../services/dummy_room_data.dart';
import '../../widgets/room_card.dart';

class RoomListTab extends StatelessWidget {
  const RoomListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, bottom: 80.0), 
      itemCount: dummyRooms.length,
      itemBuilder: (context, index) {
        final room = dummyRooms[index];
        return RoomCard(room: room);
      },
    );
  }
}