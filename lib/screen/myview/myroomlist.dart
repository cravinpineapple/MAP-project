// custome widget for to do list panels
// import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3part1/controller/firebasecontroller.dart';
import 'package:lesson3part1/model/room.dart';
import 'package:lesson3part1/screen/myview/mydialog.dart';
import 'package:lesson3part1/screen/room_screen.dart';

import '../../model/constant.dart';

class MyRoomList extends StatefulWidget {
  final List<Room> roomList;
  final User user;

  MyRoomList({@required this.roomList, @required this.user});

  @override
  State<StatefulWidget> createState() {
    return _MyRoomListState();
  }
}

class _MyRoomListState extends State<MyRoomList> {
  List<Room> roomList;
  _Controller con;
  User user;

  @override
  void initState() {
    super.initState();
    roomList = widget.roomList;
    user = widget.user;
    con = _Controller(this);
  }

  void render(func) {
    setState(func);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      isAlwaysShown: true,
      child: SingleChildScrollView(
        child: Column(
          children: con.generateRoomList(),
        ),
      ),
    );
  }
}

class _Controller {
  _MyRoomListState state;
  _Controller(this.state);
  bool ownerChangeBool;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String ownerUpdate = '';
  Room room;

  List<Widget> generateRoomList() {
    return state.roomList
        .map(
          (e) => FlatButton(
            onLongPress: () => roomPrompt(e),
            onPressed: () => Navigator.pushNamed(
                state.context, RoomScreen.routeName,
                arguments: {Constant.ARG_ROOM: e}),
            child: Text(e.roomName),
          ),
        )
        .toList();
  }

  void roomPrompt(Room e) {
    room = e;
    print('==== roomPrompt ${room.docID}');
    showDialog(
      context: state.context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: state.user.email == room.owner ? 230.0 : 50.0,
            child: Column(
              children: [
                state.user.email == room.owner
                    ? ButtonTheme(
                        minWidth: 200.0,
                        height: 50.0,
                        child: RaisedButton(
                          onPressed: changeOwner,
                          child: Text(
                            'Change Owner',
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: state.user.email == room.owner ? 10.0 : 0.0),
                state.user.email == room.owner
                    ? ButtonTheme(
                        minWidth: 200.0,
                        height: 50.0,
                        child: RaisedButton(
                          onPressed: addMembers,
                          child: Text(
                            'Add Members',
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: state.user.email == room.owner ? 10.0 : 0.0),
                state.user.email == room.owner
                    ? ButtonTheme(
                        minWidth: 200.0,
                        height: 50.0,
                        child: RaisedButton(
                          onPressed: removeMembers,
                          child: Text(
                            'Remove Members',
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: state.user.email == room.owner ? 10.0 : 0.0),
                ButtonTheme(
                  minWidth: 200.0,
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: leaveRoom,
                    child: Text(
                      'Leave Room',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void changeOwner() {
    showDialog(
      context: state.context,
      builder: (context) => AlertDialog(
        content: Container(
          height: 230.0,
          child: Form(
            key: formKey,
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Change ${room.roomName} Owner',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(
                    child: TextFormField(
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'User Email. EXAMPLE: 1@test.com',
                      ),
                      validator: validateOwner,
                      onSaved: saveOwner,
                    ),
                  ),
                  SizedBox(height: 60.0),
                  Row(
                    children: [
                      SizedBox(width: 20.0),
                      RaisedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 34.0),
                      RaisedButton(
                        onPressed: submitChangeOwner,
                        child: Text('Submit'),
                      ),
                      SizedBox(width: 20.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void submitChangeOwner() async {
    if (!formKey.currentState.validate()) return;
    formKey.currentState.save();

    Navigator.pop(state.context);
    Navigator.pop(state.context);

    try {
      await saveOwner(
          ownerUpdate); // I DON'T KNOW WHY THE FUCK THIS WORKS LIKE THIS BUT IT DOES
      if (ownerChangeBool) {
        FirebaseController.changeOwner(room, ownerUpdate);
        state.render(
          () {
            state.roomList
                .where((e) => e.roomName == room.roomName)
                .elementAt(0)
                .owner = ownerUpdate;
          },
        );
        changeConfirmationDialog(ownerChangeBool);
      } else
        changeConfirmationDialog(ownerChangeBool);
    } catch (e) {
      print('============= $e');
      changeConfirmationDialog(false);
    }
  }

  Future<void> saveOwner(String value) async {
    ownerUpdate = value;

    try {
      await FirebaseController.checkIfUserExists(email: value.trim())
          .then((value) => ownerChangeBool = value);
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'checkIfUserExists Error',
        content: '$e',
      );
    }
  }

  String validateOwner(String value) {
    var ownerList = value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    if (ownerList.length != 1) {
      return 'Too many owners. Only One allowed.';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Formating incorrect. EXAMPLE: 1@test.com';
    }

    return null;
  }

  void addMembers() {}

  void removeMembers() {}

  void leaveRoom() {}

  void changeConfirmationDialog(bool success) {
    String msg = 'Room Update ' + (success ? 'Success' : 'Failure');

    showDialog(
      context: state.context,
      builder: (context) {
        return AlertDialog(
          scrollable: true,
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  msg,
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(height: 15.0),
                RaisedButton(
                  onPressed: () {
                    Navigator.pop(state.context);
                  },
                  child: Text(
                    'OK',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
