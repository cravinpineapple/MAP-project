// custome widget for to do list panels
// import 'dart:js';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3part1/controller/firebasecontroller.dart';
import 'package:lesson3part1/model/activity.dart';
import 'package:lesson3part1/model/photomemo.dart';
import 'package:lesson3part1/model/room.dart';
import 'package:lesson3part1/model/userrecord.dart';
import 'package:lesson3part1/screen/myview/mydialog.dart';
import 'package:lesson3part1/screen/room_screen.dart';

import '../../model/constant.dart';

class MyRoomList extends StatefulWidget {
  final List<Room> roomList;
  final User user;
  final List<PhotoMemo> photoMemos;
  final UserRecord userRecord;
  final List<Activity> activityFeed;

  MyRoomList({
    @required this.roomList,
    @required this.user,
    @required this.photoMemos,
    @required this.userRecord,
    @required this.activityFeed,
  });

  @override
  State<StatefulWidget> createState() {
    return _MyRoomListState();
  }
}

class _MyRoomListState extends State<MyRoomList> {
  ScrollController _scrollController;
  List<Room> roomList;
  List<PhotoMemo> photoMemos;
  _Controller con;
  User user;
  UserRecord userRecord;
  List<Activity> activityFeed;
  void callBack;

  @override
  void initState() {
    super.initState();
    roomList = widget.roomList;
    user = widget.user;
    photoMemos = widget.photoMemos;
    userRecord = widget.userRecord;
    activityFeed = widget.activityFeed;

    con = _Controller(this);
    _scrollController = ScrollController();
  }

  void render(func) {
    setState(func);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: roomList.length <= 5 ? roomList.length * 50.0 : 250.0,
      color: Color(0x545454),
      child: Scrollbar(
        isAlwaysShown: false,
        // controller: _scrollController,
        child: SingleChildScrollView(
          child: Column(
            children: con.generateRoomList(),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _MyRoomListState state;
  _Controller(this.state);
  bool ownerChangeBool;
  List<PhotoMemo> photoMemos;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String ownerUpdate = '';
  List<String> membersUpdate = [];
  Room room;

  List<Widget> generateRoomList() {
    return state.roomList
        .map(
          (e) => FlatButton(
            onLongPress: () => roomPrompt(e),
            onPressed: () => signInToRoom(e),
            child: Text(e.roomName),
          ),
        )
        .toList();
  }

  void signInToRoom(Room e) async {
    MyDialog.circularProggressStart(state.context);
    List<PhotoMemo> memos = [];
    try {
      memos = await FirebaseController.getRoomPhotoMemoList(
        photoMemoList: e.memos,
      );
      Map memberUsernames = await FirebaseController.getRoomMemberUsernames(
          roomMemberList: e.members);
      Map urls = await FirebaseController.getRoomMemberProfilePicURLs(
        roomMemberList: e.members,
      );
      List<UserRecord> memberUserRecords =
          await FirebaseController.getUserRecords(roomMemberList: e.members);

      Map notifs = await FirebaseController.getRoomNotifs(memos);
      print('======================= URLS = $urls');
      MyDialog.circularProgressStop(state.context);
      await Navigator.pushNamed(
        state.context,
        RoomScreen.routeName,
        arguments: {
          Constant.ARG_ROOM: e,
          Constant.ARG_USER: state.user,
          Constant.ARG_PHOTOMEMOLIST: state.photoMemos,
          Constant.ARG_ROOM_MEMOLIST: memos,
          Constant.ARG_USERRECORD: state.userRecord,
          Constant.ARG_USER_PROFILE_URL_MAP: urls,
          Constant.USER_USERNAME_MAP: memberUsernames,
          Constant.ARG_NOTIFS: notifs,
          Constant.ARG_USERRECORD_LIST: memberUserRecords,
          Constant.ARG_ACTIVITY_FEED: state.activityFeed,
        },
      );

      state.render(() {});
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'getRoomPhotoMemoList or getNotifs or ERROR',
        content: '$e',
      );
    }
  }

  void roomPrompt(Room e) {
    room = e;
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
      await saveOwner(ownerUpdate); // ??
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
        changeConfirmationDialog(success: ownerChangeBool);
      } else
        changeConfirmationDialog(
            success: ownerChangeBool, reason: 'New owner does not exist');
    } catch (e) {
      print('============= $e');
      changeConfirmationDialog(success: false, reason: '$e');
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

  void addMembers() {
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
                    'Add members to ${room.roomName}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(
                    child: TextFormField(
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'EXAMPLE: 1@test.com, 2@test.com',
                      ),
                      validator: Room.validateMemberList,
                      onSaved: saveMembers,
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
                        onPressed: submitAddMembers,
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

  void saveMembers(String value) {
    membersUpdate = value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
  }

  void submitAddMembers() async {
    if (!formKey.currentState.validate()) return;
    formKey.currentState.save();

    // NOW WE HAVE THE LIST
    Navigator.pop(state.context);
    Navigator.pop(state.context);

    try {
      bool usersExist = true;
      List<String> remover = [];
      for (var e in membersUpdate) {
        if (room.members.contains(e)) {
          remover.add(e);
          continue;
        }
        usersExist = await FirebaseController.checkIfUserExists(email: e);
        if (!usersExist) {
          break;
        }
      }
      for (var e in remover) {
        membersUpdate.remove(e);
      }
      List<PhotoMemo> roomPhotoMemos =
          await FirebaseController.getRoomPhotoMemoList(
              photoMemoList: room.memos);
      if (usersExist) {
        print('################################### ${room.docID}');

        // ====== ADDING NEW ROOM MEMBERS TO EACH PHOTOMEMO IN ROOM ======
        // locally
        for (var m in roomPhotoMemos) m.roomMembers.addAll(membersUpdate);
        // updates firebase
        for (var m in roomPhotoMemos)
          FirebaseController.updatePhotoMemo(
              m.docID, {PhotoMemo.ROOM_MEMBERS: m.roomMembers});
        // ===============================================================

        room.members.addAll(membersUpdate);
        FirebaseController.updateRoom(
          emails: room.members,
          room: room,
        );
        state.render(
          () {
            state.roomList
                .where((e) => e.roomName == room.roomName)
                .elementAt(0)
                .members = room.members; //membersUpdate;
          },
        );
        changeConfirmationDialog(success: true);
      } else
        changeConfirmationDialog(
            success: false, reason: 'One or more users doesn\'t exist');
    } catch (e) {
      print('============= $e');
      changeConfirmationDialog(success: false, reason: '$e');
    }
  }

  void submitRemoveMembers() async {
    if (!formKey.currentState.validate()) return;
    formKey.currentState.save();
    // removed members now in memberUpdate list

    Navigator.pop(state.context);
    Navigator.pop(state.context);

    try {
      print('################################### ${room.docID}');
      print('roomMembersList: ${room.members}');
      print('memberUpdate: $membersUpdate');

      List<PhotoMemo> roomPhotoMemos =
          await FirebaseController.getRoomPhotoMemoList(
              photoMemoList: room.memos);

      if (membersUpdate.contains(room.owner)) {
        changeConfirmationDialog(
            success: false, reason: 'You cannot remove yourself');
        return;
      }

      for (String m in membersUpdate) {
        room.members.remove(m);
      }

      // ====== ADDING NEW ROOM MEMBERS TO EACH PHOTOMEMO IN ROOM ======
      // locally
      for (var m in roomPhotoMemos) m.roomMembers = room.members;
      // updates firebase
      for (var m in roomPhotoMemos)
        FirebaseController.updatePhotoMemo(
            m.docID, {PhotoMemo.ROOM_MEMBERS: m.roomMembers});
      // ===============================================================

      FirebaseController.updateRoom(
        emails: room.members,
        room: room,
      );
      state.render(
        () {
          state.roomList
              .where((e) => e.roomName == room.roomName)
              .elementAt(0)
              .members = room.members;
        },
      );
      changeConfirmationDialog(success: true);
    } catch (e) {
      changeConfirmationDialog(success: false, reason: '$e');
    }
  }

  void removeMembers() async {
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
                    'Remove members from ${room.roomName}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(
                    child: TextFormField(
                      autocorrect: false,
                      decoration: InputDecoration(
                        hintText: 'EXAMPLE: 1@test.com, 2@test.com',
                      ),
                      validator: Room.validateMemberList,
                      onSaved: saveMembers,
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
                        onPressed: submitRemoveMembers,
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

  void leaveRoom() {
    showDialog(
      context: state.context,
      builder: (context) => AlertDialog(
        content: Container(
          height: 230.0,
          child: Center(
            child: Column(
              children: [
                Text(
                  'Are you sure you want to leave ${room.roomName}',
                  style: Theme.of(context).textTheme.headline6,
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
                      onPressed: submitLeaveRoom,
                      child: Text('I\'m Sure'),
                    ),
                    SizedBox(width: 20.0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitLeaveRoom() {
    Navigator.pop(state.context);
    Navigator.pop(state.context);

    try {
      if (state.user.email == room.owner) {
        // leaving as only member
        if (room.members.length == 1) {
          FirebaseController.deleteRoom(room);
          state.roomList.remove(room);
        }
        // leaving room as owner will transfer ownership to a random room member
        else {
          room.members.remove(state.user.email);
          room.owner = room.members[0];
          state.roomList.remove(room);
          FirebaseController.updateRoom(emails: room.members, room: room);
        }
      } else {
        room.members.remove(state.user.email);
        state.roomList.remove(room);
        FirebaseController.updateRoom(emails: room.members, room: room);
      }
      changeConfirmationDialog(
          success: true, reason: 'You have left room ${room.roomName}');
      state.render(() {});
    } catch (e) {
      changeConfirmationDialog(success: false, reason: 'Firebase Error: $e');
    }
  }

  void changeConfirmationDialog({
    @required bool success,
    String reason = '',
  }) {
    String msg =
        'Room Update ' + (success ? 'Success:\n' : 'Failed:\n') + reason;

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
