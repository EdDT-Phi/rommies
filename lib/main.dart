import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'roomies.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final roomieProvider = RoomieProvider(sharedPreferences);

  runApp(MyApp(roomieProvider));
}

class MyApp extends StatelessWidget {
  final RoomieProvider _roomieProvider;

  const MyApp(this._roomieProvider);

  @override
  Widget build(BuildContext context) {
    final roomie = _roomieProvider.selectedRoomie;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: roomie == null
          ? RoomieSelectionScreen(_roomieProvider)
          : MyHomePage(),
    );
  }
}
