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
  final int idx;

  const Roomie(
      {@required this.name, @required this.subtitle, @required this.idx});

  static const tom = Roomie(
    name: 'Tom',
    subtitle: 'AKA Rom',
    idx: 0,
  );
  static const carmina = Roomie(
    name: 'Carmina',
    subtitle: 'AKA Carmione',
    idx: 1,
  );
  static const eddie = Roomie(
    name: 'Eddie',
    subtitle: 'AKA Edry',
    idx: 2,
  );

  static const roomies = [tom, carmina, eddie];

  static Roomie forName(String name) => name == null || name.isEmpty
      ? null
      : roomies.firstWhere((roomie) => roomie.name == name);

  // TODO(eddt): Probably need to add some offset for the day I want;
  static int get _weekNum =>
      DateTime.now().millisecondsSinceEpoch ~/ (7 * 24 * 60 * 60 * 1000);

  static int taskIdxForRoomie(Roomie roomie) =>
      (_weekNum + roomies.indexOf(roomie)) % roomies.length;
}
