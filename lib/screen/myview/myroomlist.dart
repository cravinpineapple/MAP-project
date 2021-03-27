// custome widget for to do list panels
import 'package:flutter/material.dart';
import 'package:lesson3part1/model/room.dart';
import 'package:lesson3part1/screen/room_screen.dart';

import '../../model/constant.dart';

class MyRoomList extends StatefulWidget {
  final List<Room> roomList;

  MyRoomList({
    @required this.roomList,
  });

  @override
  State<StatefulWidget> createState() {
    return _MyRoomListState();
  }
}

class _MyRoomListState extends State<MyRoomList> {
  List<Room> roomList;
  _Controller con;

  @override
  void initState() {
    super.initState();
    roomList = widget.roomList;
    con = _Controller(this);
  }

  void render(func) {
    setState(func);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: con.generateRoomList(),
      ),
    );
  }
}

class _Controller {
  _MyRoomListState state;
  _Controller(this.state);

  List<Widget> generateRoomList() {
    return state.roomList
        .map(
          (e) => FlatButton(
            onPressed: () => Navigator.pushNamed(
                state.context, RoomScreen.routeName,
                arguments: {Constant.ARG_ROOM: e}),
            child: Text(e.roomName),
          ),
        )
        .toList();
  }
}
