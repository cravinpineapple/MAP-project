import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3part1/controller/firebasecontroller.dart';
import 'package:lesson3part1/model/activity.dart';
import 'package:lesson3part1/model/constant.dart';
import 'package:lesson3part1/model/photomemo.dart';
import 'package:lesson3part1/model/room.dart';
import 'package:lesson3part1/model/userrecord.dart';
import 'package:lesson3part1/screen/addphotomemo_screen.dart';
import 'package:lesson3part1/screen/detailedview_screen.dart';
import 'package:lesson3part1/screen/myview/myactivityelement.dart';
import 'package:lesson3part1/screen/myview/mydialog.dart';
import 'package:lesson3part1/screen/settings_screen.dart';
import 'package:lesson3part1/screen/sharedwith_screen.dart';
import 'package:lesson3part1/screen/myview/myroomlist.dart';

import '../controller/firebasecontroller.dart';
import 'myview/myimage.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/userHomeScreen';
  @override
  State<StatefulWidget> createState() {
    return _UserHomeState();
  }
}

class _UserHomeState extends State<UserHomeScreen> {
  _Controller con;
  User user;
  UserRecord userRecord;
  List<PhotoMemo> photoMemoList;
  List<Room> roomList;
  List<Activity> activityFeed;
  ListView activityView;
  GlobalKey<FormState> formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(func) => setState(func);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    roomList ??= args[Constant.ARG_ROOMLIST];
    userRecord ??= args[Constant.ARG_USERRECORD];
    activityFeed ??= args[Constant.ARG_ACTIVITY_FEED];

    print(roomList);

    return WillPopScope(
      onWillPop: () =>
          Future.value(false), // disables android system back button
      child: Scaffold(
        appBar: AppBar(
          // title: Text('User Home'),
          actions: [
            con.deleteIndex != null
                ? IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: con.cancelDelete,
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Search',
                            fillColor: Theme.of(context).backgroundColor,
                            filled: true,
                          ),
                          autocorrect: true,
                          onSaved: con.saveSearchKeyString,
                        ),
                      ),
                    ),
                  ),
            con.deleteIndex != null
                ? IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: con.delete,
                  )
                : IconButton(
                    icon: Icon(
                      Icons.search,
                    ),
                    onPressed: con.search,
                  ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: ClipOval(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: MyImage.network(
                        url: userRecord.profilePictureURL, context: context),
                  ),
                ),
                accountName: Text(userRecord.username),
                accountEmail: Text(user.email),
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Shared With Me'),
                onTap: con.sharedWithMe,
              ),
              Divider(
                height: 50.0,
                color: Colors.grey[100],
              ),
              MyRoomList(
                roomList: roomList,
                user: user,
                photoMemos: photoMemoList,
                userRecord: userRecord,
                activityFeed: activityFeed,
              ),
              IconButton(
                onPressed: con.addRoom,
                icon: Icon(Icons.add),
              ),
              Divider(
                height: 50.0,
                color: Colors.grey[100],
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    SettingsScreen.routeName,
                    arguments: {
                      Constant.ARG_USERRECORD: userRecord,
                      Constant.ARG_USER: user,
                      Constant.ARG_ACTIVITY_FEED: activityFeed,
                    },
                  );
                  render(() {});
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: con.signOut,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: con.getActivityFeed(activityFeed),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  _Controller(this.state);
  int deleteIndex;
  String keyString;

  void signOut() async {
    try {
      await FirebaseController.signOut();
    } catch (e) {
      // do nothing
    }

    Navigator.of(state.context).pop(); // pops drawer
    Navigator.of(state.context).pop(); // pops UserHome screen
  }

  void addRoom() async {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String roomName;
    String members;
    List<dynamic> membersList = [];

    showDialog(
      context: state.context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Center(child: Text('Add a new room')),
          scrollable: true,
          // backgroundColor: Colors.grey[200],
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(state.context),
              color: Colors.grey[800],
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
            FlatButton(
              onPressed: () async {
                if (!formKey.currentState.validate()) return;

                formKey.currentState.save();

                if (members.trim().length != 0) {
                  membersList = members
                      .split(RegExp('(,| )+'))
                      .map((e) => e.trim())
                      .toList();
                }

                List<String> removeList = [];
                for (var m in membersList) {
                  if (!(await FirebaseController.checkIfUserExists(email: m))) {
                    removeList.add(m);
                  }
                }
                for (var m in removeList) {
                  membersList.remove(m);
                }
                membersList.add(state.user.email);

                Room tempRoom = Room(
                    roomName: roomName,
                    members: membersList,
                    owner: state.user.email);

                String tempDocID;
                await FirebaseController.addRoom(tempRoom)
                    .then((value) => tempDocID = value);
                tempRoom.docID = tempDocID;
                state.roomList.add(tempRoom);
                Navigator.pop(state.context);
                state.render(() => {});
              },
              color: Colors.grey[800],
              child: Text(
                'Add Room',
                style: TextStyle(fontSize: 15.0, color: Colors.white),
              ),
            ),
          ],
          content: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(
                  width: 200.0,
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(primaryColor: Colors.red[800]),
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Room Name',
                      ),
                      keyboardType: TextInputType.name,
                      autocorrect: true,
                      onSaved: (String value) {
                        roomName = value;
                      },
                      validator: (String value) {
                        if (value.length < 3)
                          return 'Room name too short';
                        else
                          return null;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 200.0,
                  child: Theme(
                    data: Theme.of(context),
                    child: TextFormField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '1@test.com, 2@test.com',
                      ),
                      keyboardType: TextInputType.name,
                      autocorrect: true,
                      onSaved: (String value) {
                        members = value;
                      },
                      validator: (String value) {
                        if ((value.contains('@') && value.contains('.')) ||
                            value.trim() == "")
                          return null;
                        else
                          return 'invalid email address';
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Room tempRoom = Room();
    // tempRoom.owner = state.user.email;
    // tempRoom.

    // String docID = FirebaseController.addRoom(tempRoom);
  }

  void addButton() async {
    await Navigator.pushNamed(
      state.context,
      AddPhotoMemoScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: state.photoMemoList,
        Constant.ARG_ROOM: null,
      },
    );

    state.render(() {}); // rerender the screen
  }

  void onTap(int index) async {
    if (deleteIndex != null) return;
    await Navigator.pushNamed(
      state.context,
      DetailedViewScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_ONE_PHOTOMEMO: state.photoMemoList[index],
      },
    );

    state.render(() {});
  }

  void sharedWithMe() async {
    try {
      List<PhotoMemo> photoMemoList =
          await FirebaseController.getPhotoMemoSharedWithMe(
              email: state.user.email);

      await Navigator.pushNamed(state.context, SharedWithScreen.routeName,
          arguments: {
            Constant.ARG_USER: state.user,
            Constant.ARG_PHOTOMEMOLIST:
                photoMemoList, // list of shared with email we retrieved
          });

      Navigator.pop(state.context); // closes the drawer
    } catch (e) {
      MyDialog.info(
          context: state.context,
          title: 'Get Shared PhotoMemo Error',
          content: '$e');
    }
  }

  void onLongPress(int index) {
    if (deleteIndex != null) return;
    state.render(() => deleteIndex = index);
  }

  void cancelDelete() {
    state.render(() => deleteIndex = null);
  }

  void delete() async {
    try {
      PhotoMemo p = state.photoMemoList[deleteIndex];
      FirebaseController.deletePhotoMemo(p);

      state.render(() {
        state.photoMemoList.removeAt(deleteIndex);
        deleteIndex = null;
      });
    } catch (e) {
      MyDialog.info(
          context: state.context,
          title: 'Delete PhotoMemo Error',
          content: '$e');
    }
  }

  void saveSearchKeyString(String value) {
    keyString = value;
  }

  void search() async {
    state.formKey.currentState.save();

    var keys = keyString.split(',').toList();
    List<String> searchKeys = [];

    for (var k in keys) {
      if (k.trim().isNotEmpty) searchKeys.add(k.trim().toLowerCase());
    }

    try {
      List<PhotoMemo> results;

      if (searchKeys.isNotEmpty) {
        results = await FirebaseController.searchImage(
          createdBy: state.user.email,
          searchLabels: searchKeys,
        );
      } else {
        results =
            await FirebaseController.getPhotoMemoList(email: state.user.email);
      }
      state.render(() => state.photoMemoList = results);
    } catch (e) {
      MyDialog.info(
          context: state.context, title: 'Search Error', content: '$e');
    }
  }

  ListView getActivityFeed(List<Activity> activityFeed) {
    return ListView.builder(
      key: UniqueKey(),
      itemCount: activityFeed.length,
      itemBuilder: (BuildContext context, int index) => ActivityElement(
        userRecord: state.userRecord,
        activity: activityFeed[index],
      ),
    );
  }
}

/*
    old user home

body: photoMemoList.length == 0
            ? Text(
                'No PhotoMemos Found',
                style: Theme.of(context).textTheme.headline5,
              )
            : ListView.builder(
                itemCount: photoMemoList.length,
                itemBuilder: (BuildContext context, int index) => Container(
                  color: con.deleteIndex != null && con.deleteIndex == index
                      ? Theme.of(context).highlightColor
                      : Theme.of(context).scaffoldBackgroundColor,
                  child: ListTile(
                    leading: MyImage.network(
                      url: photoMemoList[index].photoURL,
                      context: context,
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    title: Text(photoMemoList[index].title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          photoMemoList[index].memo.length >= 20
                              ? photoMemoList[index].memo.substring(0, 20) +
                                  '...'
                              : photoMemoList[index].memo,
                        ),
                        Text('Created By: ${photoMemoList[index].createdBy}'),
                        Text('Shared With: ${photoMemoList[index].sharedWith}'),
                        Text('Updated At: ${photoMemoList[index].timestamp}'),
                      ],
                    ),
                    onTap: () => con.onTap(index),
                    onLongPress: () => con.onLongPress(index),
                  ),
                ),
              ),

*/
