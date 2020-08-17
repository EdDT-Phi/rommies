import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class RoomieSelectionScreen extends StatelessWidget {
  final RoomieProvider _roomieProvider;

  const RoomieSelectionScreen(this._roomieProvider);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Select your name'),
        ),
        body: ListView(
          children: Roomie.roomies
              .map((roomie) => ListTile(
                    title: Text(roomie.name),
                    subtitle: Text(roomie.subtitle),
                    onTap: () {
                      _roomieProvider.selectRoomie(roomie);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => MyHomePage(
                          roomie: roomie,
                        ),
                      ));
                    },
                  ))
              .toList(),
        ),
      );
}

const _roomieKey = 'roomieKey';

class RoomieProvider {
  final SharedPreferences _sharedPreferences;

  RoomieProvider(this._sharedPreferences);

  Roomie get selectedRoomie =>
      Roomie.forName(_sharedPreferences.get(_roomieKey));

  void selectRoomie(Roomie roomie) =>
      _sharedPreferences.setString(_roomieKey, roomie.name);
}

class Roomie {
  final String name;
  final String subtitle;

  const Roomie({
    @required this.name,
    @required this.subtitle,
  });

  static const tom = Roomie(
    name: 'Tom',
    subtitle: 'AKA Rom',
  );

  static const eddie = Roomie(
    name: 'Eddie',
    subtitle: 'AKA Edry',
  );

  static const carmina = Roomie(
    name: 'Carmina',
    subtitle: 'AKA Carmione',
  );

  static const roomies = [tom, carmina, eddie];

  static Roomie forName(String name) => name == null || name.isEmpty
      ? null
      : roomies.firstWhere((roomie) => roomie.name == name);
}
