import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3part1/model/constant.dart';
import 'package:lesson3part1/model/photomemo.dart';

class MyPhotoScreen extends StatefulWidget {
  static const routeName = '/myPhotosScreen';

  @override
  State<StatefulWidget> createState() {
    return _MyPhotoScreenState();
  }
}

class _MyPhotoScreenState extends State<MyPhotoScreen> {
  _Controller con;
  List<PhotoMemo> photoMemoList;

  @override
  void initState() {
    super.initState();
    con = _Controller();
  }

  void render(func) => setState(func);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];

    // return Scaffold(
    //   appBar: AppBar(
    //     // title: Text('User Home'),
    //     actions: [
    //       con.deleteIndex != null
    //           ? IconButton(
    //               icon: Icon(Icons.cancel),
    //               onPressed: con.cancelDelete,
    //             )
    //           : Padding(
    //               padding: const EdgeInsets.only(top: 4.0),
    //               child: Container(
    //                 width: MediaQuery.of(context).size.width * 0.7,
    //                 child: Form(
    //                   key: formKey,
    //                   child: TextFormField(
    //                     decoration: InputDecoration(
    //                       hintText: 'Search',
    //                       fillColor: Theme.of(context).backgroundColor,
    //                       filled: true,
    //                     ),
    //                     autocorrect: true,
    //                     onSaved: con.saveSearchKeyString,
    //                   ),
    //                 ),
    //               ),
    //             ),
    //       con.deleteIndex != null
    //           ? IconButton(
    //               icon: Icon(Icons.delete),
    //               onPressed: con.delete,
    //             )
    //           : IconButton(
    //               icon: Icon(
    //                 Icons.search,
    //               ),
    //               onPressed: con.search,
    //             ),
    //     ],
    //   ),
    //   drawer: Drawer(
    //     child: ListView(
    //       children: [
    //         UserAccountsDrawerHeader(
    //           currentAccountPicture: ClipOval(
    //             child: FittedBox(
    //               fit: BoxFit.cover,
    //               child: MyImage.network(
    //                   url: userRecord.profilePictureURL, context: context),
    //             ),
    //           ),
    //           accountName: Text(userRecord.username),
    //           accountEmail: Text(user.email),
    //         ),
    //         ListTile(
    //           leading: Icon(Icons.people),
    //           title: Text('Shared With Me'),
    //           onTap: con.sharedWithMe,
    //         ),
    //         ListTile(
    //           leading: Icon(Icons.people),
    //           title: Text('My Photos'),
    //           onTap: con.myPhotos,
    //         ),
    //         Divider(
    //           height: 50.0,
    //           color: Colors.grey[100],
    //         ),
    //         MyRoomList(
    //           roomList: roomList,
    //           user: user,
    //           photoMemos: photoMemoList,
    //           userRecord: userRecord,
    //         ),
    //         IconButton(
    //           onPressed: con.addRoom,
    //           icon: Icon(Icons.add),
    //         ),
    //         Divider(
    //           height: 50.0,
    //           color: Colors.grey[100],
    //         ),
    //         ListTile(
    //           leading: Icon(Icons.settings),
    //           title: Text('Settings'),
    //           onTap: () {
    //             Navigator.pushNamed(
    //               context,
    //               SettingsScreen.routeName,
    //               arguments: {
    //                 Constant.ARG_USERRECORD: userRecord,
    //                 Constant.ARG_USER: user,
    //               },
    //             );

    //             render(() {});
    //           },
    //         ),
    //         ListTile(
    //           leading: Icon(Icons.exit_to_app),
    //           title: Text('Sign Out'),
    //           onTap: con.signOut,
    //         ),
    //       ],
    //     ),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     child: Icon(Icons.add),
    //     onPressed: con.addButton,
    //   ),
    //   body: photoMemoList.length == 0
    //       ? Text(
    //           'No PhotoMemos Found',
    //           style: Theme.of(context).textTheme.headline5,
    //         )
    //       : ListView.builder(
    //           itemCount: photoMemoList.length,
    //           itemBuilder: (BuildContext context, int index) => Container(
    //             color: con.deleteIndex != null && con.deleteIndex == index
    //                 ? Theme.of(context).highlightColor
    //                 : Theme.of(context).scaffoldBackgroundColor,
    //             child: ListTile(
    //               leading: MyImage.network(
    //                 url: photoMemoList[index].photoURL,
    //                 context: context,
    //               ),
    //               trailing: Icon(Icons.keyboard_arrow_right),
    //               title: Text(photoMemoList[index].title),
    //               subtitle: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     photoMemoList[index].memo.length >= 20
    //                         ? photoMemoList[index].memo.substring(0, 20) + '...'
    //                         : photoMemoList[index].memo,
    //                   ),
    //                   Text('Created By: ${photoMemoList[index].createdBy}'),
    //                   Text('Shared With: ${photoMemoList[index].sharedWith}'),
    //                   Text('Updated At: ${photoMemoList[index].timestamp}'),
    //                 ],
    //               ),
    //               onTap: () => con.onTap(index),
    //               onLongPress: () => con.onLongPress(index),
    //             ),
    //           ),
    //         ),
    // );
  }
}

class _Controller {
  _MyPhotoScreenState state;
  _Controller({this.state});
}
