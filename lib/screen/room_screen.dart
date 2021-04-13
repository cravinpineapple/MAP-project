import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3part1/controller/firebasecontroller.dart';
import 'package:lesson3part1/model/activity.dart';
import 'package:lesson3part1/model/comment.dart';
import 'package:lesson3part1/model/photomemo.dart';
import 'package:lesson3part1/model/room.dart';
import 'package:lesson3part1/model/userrecord.dart';
import 'package:lesson3part1/screen/addphotomemo_screen.dart';
import 'package:lesson3part1/screen/myview/mycomments.dart';
import 'package:lesson3part1/screen/myview/mydetailedview.dart';
import 'package:lesson3part1/screen/myview/mydialog.dart';
import 'package:lesson3part1/screen/myview/myimage.dart';
import 'package:lesson3part1/screen/myview/profilepic.dart';

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
  Map<dynamic, dynamic> notifs;
  Map<String, String> memberProfilePicURLS;
  Map<dynamic, dynamic> memberUsernames;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<UserRecord> memberUserRecords;
  List<Activity> activityFeed;

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
    memberProfilePicURLS ??= args[Constant.ARG_USER_PROFILE_URL_MAP];
    memberUsernames ??= args[Constant.USER_USERNAME_MAP];
    notifs ??= args[Constant.ARG_NOTIFS];
    memberUserRecords ??= args[Constant.ARG_USERRECORD_LIST];
    activityFeed ??= args[Constant.ARG_ACTIVITY_FEED];

    print(notifs);

    for (var m in roomMemos) {
      if (!notifs[m.docID].notification.containsKey(userRecord.email)) {
        notifs[m.docID].notification[userRecord.email] = 0;
        FirebaseController.updateUserNotifications(m, notifs[m.docID]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(room.roomName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
          context,
          AddPhotoMemoScreen.routeName,
          arguments: {
            Constant.ARG_USER: user,
            Constant.ARG_ROOM_MEMO_DOCIDS: room.memos,
            Constant.ARG_ROOM: room,
            Constant.ARG_PHOTOMEMOLIST: photoMemos,
            Constant.ARG_ROOM_MEMOLIST: roomMemos,
            Constant.ARG_NOTIFS: notifs,
            Constant.ARG_USERRECORD: userRecord,
            Constant.ARG_USERRECORD_LIST: memberUserRecords,
            Constant.ARG_ACTIVITY_FEED: activityFeed,
          },
        ),
      ),
      body: con.generateWall(),
    );
  }
}

class _Controller {
  _RoomScreenState state;
  _Controller(this.state);
  final double profilePicSize = 30.0;
  String message = '';
  List<Comment> comments = [];
  Comment tempComment;
  bool detailedView = false;
  Activity tempActivity;

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
          'Members',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
    w.add(
      Container(
        padding: EdgeInsets.only(left: 10.0),
        margin: EdgeInsets.all(10.0),
        height: 50.0,
        color: Colors.grey[800],
        child: Row(
          children: [
            ProfilePic(
              profilePicSize: profilePicSize,
              url: state.memberProfilePicURLS[state.room.owner],
            ),
            SizedBox(width: 20.0),
            Text(
              state.memberUsernames[state.room.owner],
              style: TextStyle(fontSize: 20.0),
            ),
            Icon(
              Icons.star,
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
    for (var m in state.room.members) {
      if (m == state.room.owner) continue;
      w.add(
        Container(
          padding: EdgeInsets.only(left: 10.0),
          margin: EdgeInsets.all(10.0),
          height: 50.0,
          color: Colors.grey[800],
          child: Row(
            children: [
              ProfilePic(
                profilePicSize: profilePicSize,
                url: state.memberProfilePicURLS[m],
              ),
              SizedBox(width: 20.0),
              Text(
                state.memberUsernames[m],
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
        Stack(
          children: [
            Container(
              width: width,
              height: width,
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: MaterialButton(
                    child: MyImage.network(url: m.photoURL, context: state.context),
                    onPressed: () {
                      focusMemoView(m);
                      state.render(() {});
                    }),
              ),
              color: Colors.transparent,
            ),
            Positioned(
              right: 5.0,
              top: 2.0,
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(color: Colors.grey[600].withOpacity(.8), blurRadius: 5.0)
                ]),
                child: getNotificationIcon(
                  state.notifs[m.docID].notification[state.userRecord.email],
                ),
              ),
            )
          ],
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

  Widget getNotificationIcon(int value) {
    Color notificationIconColor = Theme.of(state.context).primaryColor;
    switch (value) {
      case 0:
        return SizedBox();
      case 1:
        return Icon(Icons.filter_1_rounded, size: 36.0, color: notificationIconColor);
      case 2:
        return Icon(Icons.filter_2_rounded, size: 36.0, color: notificationIconColor);
      case 3:
        return Icon(Icons.filter_3_rounded, size: 36.0, color: notificationIconColor);
      case 4:
        return Icon(Icons.filter_4_rounded, size: 36.0, color: notificationIconColor);
      case 5:
        return Icon(Icons.filter_5_rounded, size: 36.0, color: notificationIconColor);
      case 6:
        return Icon(Icons.filter_6_rounded, size: 36.0, color: notificationIconColor);
      case 7:
        return Icon(Icons.filter_7_rounded, size: 36.0, color: notificationIconColor);
      case 8:
        return Icon(Icons.filter_8_rounded, size: 36.0, color: notificationIconColor);
      case 9:
        return Icon(Icons.filter_9_rounded, size: 36.0, color: notificationIconColor);
      default:
        return Icon(Icons.filter_9_plus_rounded,
            size: 36.0, color: notificationIconColor);
    }
  }

  void focusMemoView(PhotoMemo m) async {
    int commentCount;
    UserRecord photoMemoOwner;
    try {
      state.notifs[m.docID].notification[state.userRecord.email] = 0;
      await FirebaseController.updateUserNotifications(m, state.notifs[m.docID]);
      comments = await FirebaseController.getComments(memo: m);
      photoMemoOwner = await FirebaseController.getUserRecord(email: m.createdBy);
      // getting comment owner username & profile pic from firebase
      for (var c in comments) {
        UserRecord userR =
            await FirebaseController.getUserRecord(email: c.commentOwnerEmail);
        c.username = userR.username;
        c.profilePicURL = userR.profilePictureURL;
      }
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Get Comments Error',
        content: '$e',
      );
    }
    var focusWidth = MediaQuery.of(state.context).size.width * 0.8;
    var focusHeight = MediaQuery.of(state.context).size.height * 0.8;
    detailedView = false;
    showDialog(
      context: state.context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            backgroundColor: Colors.transparent,
            content: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 0.0),
                      Stack(
                        children: [
                          Container(
                            height: focusWidth,
                            width: focusWidth,
                            color: Colors.transparent,
                            child: FittedBox(
                                fit: BoxFit.cover,
                                clipBehavior: Clip.hardEdge,
                                child: MyImage.network(
                                    url: m.photoURL, context: state.context)),
                          ),
                          Positioned(
                            right: 3.0,
                            bottom: 3.0,
                            width: 40.0,
                            height: 40.0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.grey[600].withOpacity(0.7),
                              ),
                            ),
                          ),
                          Positioned(
                            right: !detailedView ? 8.0 : 4.0,
                            bottom: !detailedView ? 8.0 : 4.0,
                            child: IconButton(
                              icon: Icon(
                                !detailedView
                                    ? Icons.analytics_outlined
                                    : Icons.comment_outlined,
                                color: Theme.of(context).primaryColor.withOpacity(0.8),
                                size: !detailedView ? 50.0 : 40.0,
                              ),
                              onPressed: () async {
                                commentCount =
                                    await FirebaseController.getPhotomemoCommentCount(
                                        photoMemo: m);
                                setState(() => detailedView = !detailedView);
                              },
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: focusHeight * (!detailedView ? 0.3 : 0.48),
                        width: focusWidth,
                        color: Colors.grey[800],
                        child: !detailedView
                            ? SingleChildScrollView(
                                reverse: true,
                                child: CommentsBlock(
                                  comments: comments,
                                  userRecord: state.userRecord,
                                  photoMemo: m,
                                  notifs: state.notifs,
                                ),
                              )
                            : DetailedView(
                                photoMemo: m,
                                commentCount: commentCount,
                                ownerUsername: photoMemoOwner.username,
                                allRoomMemos: state.roomMemos,
                              ),
                      ),
                      !detailedView
                          ? Container(
                              height: focusHeight * 0.18,
                              width: focusWidth,
                              color: Colors.grey[800],
                              child: Column(
                                children: [
                                  Divider(),
                                  Form(
                                    key: state.formKey,
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(left: 10.0),
                                                width: focusWidth * 0.75,
                                                child: TextFormField(
                                                  decoration: InputDecoration(
                                                    hintText: 'Leave a comment!',
                                                  ),
                                                  autocorrect: true,
                                                  obscureText: false,
                                                  validator: validateComment,
                                                  onSaved: saveComment,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 12.0, left: 10.0),
                                                child: ClipOval(
                                                  child: Container(
                                                    color: Theme.of(state.context)
                                                        .primaryColor,
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.arrow_forward_rounded,
                                                      ),
                                                      iconSize: 30.0,
                                                      onPressed: () {
                                                        uploadComment(m);
                                                        setState(() =>
                                                            comments.add(tempComment));
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void uploadComment(PhotoMemo memo) async {
    if (!state.formKey.currentState.validate()) return;
    // now validated
    state.formKey.currentState.save();
    state.formKey.currentState.reset();

    try {
      for (var member in memo.roomMembers) {
        if (member == state.userRecord.email) continue;
        if (!state.notifs[memo.docID].notification.containsKey(member)) {
          state.notifs[memo.docID].notification[member] = 1;
        } else {
          state.notifs[memo.docID].notification[member]++;
        }
      }
      // updating comment error
      // why did this happen
      // we took away await. dont await
      FirebaseController.updateUserNotifications(memo, state.notifs[memo.docID]);
      tempComment = Comment(
        commentOwnerEmail: state.userRecord.email,
        profilePicURL: state.userRecord.profilePictureURL,
        username: state.userRecord.username,
        message: message,
        datePosted: DateTime.now(),
      );
      tempComment.docID = await FirebaseController.addComment(tempComment, memo);

      // sending activity feed to all users
      tempActivity = Activity(
        actionOwnerUsername: state.userRecord.username,
        enumAction: ActivityAction.comment,
        timestamp: tempComment.datePosted,
        photoTitle: memo.title,
        photoUrl: memo.photoURL,
        commentMessage: tempComment.message,
        roomName: state.room.roomName,
      );
      state.activityFeed.insert(0, tempActivity);

      for (var u in state.memberUserRecords) {
        if (u.email == state.userRecord.email) {
          tempActivity.actionOwnerUsername = 'I';
          FirebaseController.addActivity(tempActivity, u);
          tempActivity.actionOwnerUsername = state.userRecord.username;
          continue;
        }

        FirebaseController.addActivity(tempActivity, u);
      }
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'upload comment error',
        content: '$e',
      );
    }
  }

  String validateComment(String value) {
    if (value.length == 0 || value.length > 200)
      return 'Comments must be between 1 and 200 characters';
    return null;
  }

  void saveComment(String value) {
    message = value;
  }
}
