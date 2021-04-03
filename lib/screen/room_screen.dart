import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3part1/controller/firebasecontroller.dart';
import 'package:lesson3part1/model/photomemo.dart';
import 'package:lesson3part1/model/room.dart';
import 'package:lesson3part1/model/userrecord.dart';
import 'package:lesson3part1/screen/addphotomemo_screen.dart';
import 'package:lesson3part1/screen/myview/mydialog.dart';
import 'package:lesson3part1/screen/myview/myimage.dart';

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
  UserRecord userRecord;
  List<PhotoMemo> photoMemos;
  List<PhotoMemo> roomMemos;

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
    photoMemos ??= args[Constant.ARG_PHOTOMEMOLIST];
    roomMemos ??= args[Constant.ARG_ROOM_MEMOLIST];
    userRecord ??= args[Constant.ARG_USERRECORD];

    return Scaffold(
      appBar: AppBar(
        title: Text(room.roomName),
        actions: [
          // SOLUTION for changing the icon of end drawer found from:
          // https://stackoverflow.com/questions/51957960/how-to-change-the-enddrawer-icon-in-flutter
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.person,
                size: 30.0,
              ),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          children: con.getAllMembers(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(
            context, AddPhotoMemoScreen.routeName,
            arguments: {
              Constant.ARG_USER: user,
              Constant.ARG_ROOM_MEMO_DOCIDS: room.memos,
              Constant.ARG_ROOM: room,
              Constant.ARG_PHOTOMEMOLIST: photoMemos,
              Constant.ARG_ROOM_MEMOLIST: roomMemos,
            }),
      ),
      body: con.generateWall(),
    );
  }
}

class _Controller {
  _RoomScreenState state;
  _Controller(this.state);
  final double profilePicSize = 30.0;

  Widget generateWall() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: getRows(),
        ),
      ),
    );
  }

  List<Widget> getAllMembers() {
    List<Widget> w = [];
    w.add(
      Container(
        margin: EdgeInsets.only(bottom: 10.0),
        padding: EdgeInsets.fromLTRB(10.0, 12.0, 0, 0),
        height: 56.0,
        color: Colors.grey[800],
        child: Text(
          // TODO: SET ROOM NAME TO A LENGTH LIMIT
          'Members',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    for (var m in state.room.members) {
      w.add(
        Container(
          padding: EdgeInsets.only(left: 10.0),
          margin: EdgeInsets.all(10.0),
          height: 50.0,
          color: Colors.grey[800],
          child: Row(
            children: [
              // TODO: only getting current user's prifle pic.
              Container(
                height: profilePicSize,
                width: profilePicSize,
                child: ClipOval(
                  child: MyImage.network(
                    url: state.userRecord.profilePictureURL,
                    context: state.context,
                  ),
                ),
              ),
              SizedBox(width: 20.0),
              Text(
                m,
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
        ),
      );
    }
    return w;
  }

  List<Widget> getRows() {
    List<Color> colors = [Colors.red, Colors.blue, Colors.green];
    var width = MediaQuery.of(state.context).size.width * .31;
    List<Widget> w = [];
    int counter = 0;
    int size = state.roomMemos.length; // 3
    Row row;
    List<Widget> widgies = [];

    for (var m in state.roomMemos.reversed) {
      // 3
      widgies.add(
        Container(
          width: width,
          height: width,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: FlatButton(
              child: MyImage.network(url: m.photoURL, context: state.context),
              onPressed: null,
            ),
          ),
          color: Colors.transparent,
        ),
      );
      size--;
      if (counter != 2) widgies.add(SizedBox(width: 2.0));
      if (counter == 2) {
        row = Row(children: widgies);
        w.add(row);
        w.add(SizedBox(height: 5.0));
        widgies = [];
        counter = -1;
      }
      counter++;
    }
    print(size);
    if (size == 0) {
      row = Row(children: widgies);
      w.add(row);
      w.add(SizedBox());
    }
    return w;
  }

  void addPhotoMemo() {}
}
