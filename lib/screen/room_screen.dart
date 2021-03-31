import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3part1/model/room.dart';
import 'package:lesson3part1/screen/addphotomemo_screen.dart';

import '../model/constant.dart';

class RoomScreen extends StatefulWidget {
  static const routeName = '/roomScreen';

  @override
  State<StatefulWidget> createState() {
    return _RoomScreenState();
  }
}

class _RoomScreenState extends State<RoomScreen> {
  _Controller con;
  Room room;
  User user;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(func) => setState(func);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    room ??= args[Constant.ARG_ROOM];
    user ??= args[Constant.ARG_USER];

    return Scaffold(
      appBar: AppBar(
        title: Text(room.roomName),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(
            context, AddPhotoMemoScreen.routeName,
            arguments: {
              Constant.ARG_USER: user,
              Constant.ARG_ROOMMEMOLIST: room.memos,
              Constant.ARG_ROOM: room,
            }),
      ),
      body: Text('room screen'),
    );
  }
}

class _Controller {
  _RoomScreenState state;
  _Controller(this.state);

  void addPhotoMemo() {}
}
