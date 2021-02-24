import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3part1/controller/firebasecontroller.dart';
import 'package:lesson3part1/model/constant.dart';
import 'package:lesson3part1/model/photomemo.dart';
import 'package:lesson3part1/screen/addphotomemo_screen.dart';
import 'package:lesson3part1/screen/detailedview_screen.dart';

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
      onWillPop: () => Future.value(false), // disables android system back button
      child: Scaffold(
        appBar: AppBar(
          title: Text('User Home'),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user.displayName ?? 'N / A'),
                accountEmail: Text(user.email),
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: con.signOut,
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: con.addButton,
        ),
        body: photoMemoList.length == 0
            ? Text(
                'No PhtoMemos Found',
                style: Theme.of(context).textTheme.headline5,
              )
            : ListView.builder(
                itemCount: photoMemoList.length,
                itemBuilder: (BuildContext context, int index) => ListTile(
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
                            ? photoMemoList[index].memo.substring(0, 20) + '...'
                            : photoMemoList[index].memo,
                      ),
                      Text('Created By: ${photoMemoList[index].createdBy}'),
                      Text('Shared With: ${photoMemoList[index].sharedWith}'),
                      Text('Updated At: ${photoMemoList[index].timestamp}'),
                    ],
                  ),
                  onTap: () => con.onTap(index),
                ),
              ),
      ),
    );
  }
}

class _Controller {
  _UserHomeState state;
  _Controller(this.state);

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

  void onTap(int index) {
    Navigator.pushNamed(
      state.context,
      DetailedViewScreen.routeName,
      arguments: {
        Constant.ARG_USER: state.user,
        Constant.ARG_ONE_PHOTOMEMO: state.photoMemoList[index],
      },
    );
  }
}
