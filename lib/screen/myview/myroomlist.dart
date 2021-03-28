// custome widget for to do list panels
// import 'dart:js';

import 'package:flutter/material.dart';
import 'package:lesson3part1/controller/firebasecontroller.dart';
import 'package:lesson3part1/model/room.dart';
import 'package:lesson3part1/screen/myview/mydialog.dart';
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

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String ownerUpdate = '';
  Room room;
  List<Widget> generateRoomList() {
    return state.roomList
        .map(
          (e) => FlatButton(
            onLongPress: () => roomPrompt(e),
            onPressed: () => Navigator.pushNamed(state.context, RoomScreen.routeName,
                arguments: {Constant.ARG_ROOM: e}),
            child: Text(e.roomName),
          ),
        )
        .toList();
  }

  void roomPrompt(Room e) {
    room = e;
    showDialog(
      context: state.context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 230.0,
            child: Column(
              children: [
                ButtonTheme(
                  minWidth: 200.0,
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: changeOwner,
                    child: Text(
                      'Change Owner',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                ButtonTheme(
                  minWidth: 200.0,
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: addMembers,
                    child: Text(
                      'Add Members',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                ButtonTheme(
                  minWidth: 200.0,
                  height: 50.0,
                  child: RaisedButton(
                    onPressed: removeMembers,
                    child: Text(
                      'Remove Members',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
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
    try {
      FirebaseController.changeOwner(room, ownerUpdate);
      Navigator.pop(state.context);
      Navigator.pop(state.context);
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Update Owner Firebase Error',
        content: '$e',
      );
    }
  }

  void saveOwner(String value) {
    ownerUpdate = value;
  }

  String validateOwner(String value) {
    var ownerList = value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    if (ownerList.length != 1) {
      return 'Too many owners. Only One allowed.';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Formating incorrect. EXAMPLE: 1@test.com';
    }
    try {
      bool b;
      FirebaseController.checkIfUserExists(email: value.trim())
          .then((value) => b = value);
      if (!b) {
        return 'User does not exist.';
      }
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'checkIfUserExists Error',
        content: '$e',
      );
    }
    return null;
  }

  void addMembers() {}

  void removeMembers() {}

  void leaveRoom() {}

  void updateRoom() {
    List<dynamic> membersList = [];
    String members = '';
    String owner = '';
    String roomName = '';

    // showDialog(
    //   context: state.context,
    //   barrierDismissible: false,
    //   builder: (context) {
    //     return AlertDialog(
    //       scrollable: true,
    //       backgroundColor: Colors.grey[200],
    //       actions: [
    //         FlatButton(
    //           onPressed: () => Navigator.pop(state.context),
    //           color: Colors.grey[800],
    //           child: Text(
    //             'Cancel',
    //             style: TextStyle(fontSize: 15.0, color: Colors.white),
    //           ),
    //         ),
    //         FlatButton(
    //           onPressed: () {
    //             if (!formKey.currentState.validate()) return;

    //             formKey.currentState.save();

    //             if (members.trim().length != 0) {
    //               membersList =
    //                   members.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    //             }

    //             membersList.add(state.user.email);

    //             Room tempRoom = Room(
    //                 roomName: roomName, members: membersList, owner: state.user.email);

    //             FirebaseController.addRoom(tempRoom);
    //             state.roomList.add(tempRoom);
    //             Navigator.pop(state.context);
    //             state.render(() => {});
    //             // FirebaseController.addRoom(tempRoom);
    //           },
    //           color: Colors.grey[800],
    //           child: Text(
    //             'Add Room',
    //             style: TextStyle(fontSize: 15.0, color: Colors.white),
    //           ),
    //         ),
    //       ],
    //       content: Form(
    //         key: formKey,
    //         child: Column(
    //           children: [
    //             Text(
    //               'Add New Room',
    //               textAlign: TextAlign.center,
    //               style: TextStyle(
    //                 color: Colors.grey[800],
    //                 fontSize: 25.0,
    //               ),
    //             ),
    //             SizedBox(
    //               width: 200.0,
    //               child: Theme(
    //                 data: Theme.of(context).copyWith(primaryColor: Colors.red[800]),
    //                 child: TextFormField(
    //                   style: TextStyle(color: Colors.grey[800]),
    //                   decoration: InputDecoration(
    //                     hintText: 'Room Name',
    //                     fillColor: Colors.blue[900],
    //                   ),
    //                   keyboardType: TextInputType.name,
    //                   autocorrect: true,
    //                   onSaved: (String value) {
    //                     roomName = value;
    //                   },
    //                   validator: (String value) {
    //                     if (value.length < 3)
    //                       return 'Room name too short';
    //                     else
    //                       return null;
    //                   },
    //                 ),
    //               ),
    //             ),
    //             SizedBox(
    //               width: 200.0,
    //               child: Theme(
    //                 data: Theme.of(context),
    //                 child: TextFormField(
    //                   style: TextStyle(color: Colors.grey[800]),
    //                   decoration: InputDecoration(
    //                     hintText: '1@test.com, 2@test.com',
    //                   ),
    //                   keyboardType: TextInputType.name,
    //                   autocorrect: true,
    //                   onSaved: (String value) {
    //                     members = value;
    //                   },
    //                   validator: (String value) {
    //                     if ((value.contains('@') && value.contains('.')) ||
    //                         value.trim() == "")
    //                       return null;
    //                     else
    //                       return 'invalid email address';
    //                   },
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );
  }
}
