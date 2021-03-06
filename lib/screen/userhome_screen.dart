import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3part1/controller/firebasecontroller.dart';
import 'package:lesson3part1/model/constant.dart';
import 'package:lesson3part1/model/photomemo.dart';
import 'package:lesson3part1/screen/addphotomemo_screen.dart';
import 'package:lesson3part1/screen/detailedview_screen.dart';
import 'package:lesson3part1/screen/myview/mydialog.dart';
import 'package:lesson3part1/screen/sharedwith_screen.dart';

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
  List<PhotoMemo> photoMemoList;
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
                accountName: Text(user.displayName ?? 'N / A'),
                accountEmail: Text(user.email),
              ),
              ListTile(
                leading: Icon(Icons.people),
                title: Text('Shared With Me'),
                onTap: con.sharedWithMe,
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

  void addButton() async {
    await Navigator.pushNamed(
      state.context,
      AddPhotoMemoScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_PHOTOMEMOLIST: state.photoMemoList,
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

  void search() {
    state.formKey.currentState.save();

    var keys = keyString.split(',').toList();
    List<String> searchKeys = [];

    for (var k in keys) {
      if (k.trim().isNotEmpty) searchKeys.add(k.trim().toLowerCase());
    }

    print('$searchKeys');
  }
}
