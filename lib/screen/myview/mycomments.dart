import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lesson3part1/controller/firebasecontroller.dart';
import 'package:lesson3part1/model/comment.dart';
import 'package:lesson3part1/model/photomemo.dart';
import 'package:lesson3part1/model/userrecord.dart';
import 'package:lesson3part1/screen/myview/mydialog.dart';
import 'package:lesson3part1/screen/myview/profilepic.dart';
import 'package:intl/intl.dart';

class CommentsBlock extends StatefulWidget {
  final List<Comment> comments;
  final UserRecord userRecord;
  final PhotoMemo photoMemo;
  final Map notifs;

  CommentsBlock({
    @required this.comments,
    @required this.userRecord,
    @required this.photoMemo,
    @required this.notifs,
  });

  @override
  State<StatefulWidget> createState() {
    return _CommentsBlockState();
  }
}

class _CommentsBlockState extends State<CommentsBlock> {
  _Controller con;
  List<Comment> comments = [];
  UserRecord userRecord;
  PhotoMemo photoMemo;
  dynamic parentSetState;
  Map notifs;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    comments = widget.comments;
    userRecord = widget.userRecord;
    photoMemo = widget.photoMemo;
    notifs = widget.notifs;
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: con.buildCommentList(),
    );
  }
}

class _Controller {
  _CommentsBlockState state;
  _Controller(this.state);
  List<Comment> deleteList = [];

  DateFormat formatter = DateFormat('EEE, M/d/y H:mm');

  List<Widget> buildCommentList() {
    return state.comments
        .map(
          (e) => !deleteList.contains(e)
              ? Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10.0),
                        ProfilePic(profilePicSize: 40.0, url: e.profilePicURL),
                        Expanded(
                          flex: 4,
                          child: Container(
                            margin: EdgeInsets.only(left: 20.0, right: 5.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                    height: 10.0,
                                    child: Text(
                                      formatter.format(e.datePosted),
                                      style: TextStyle(fontSize: 10.0),
                                    )),
                                Container(
                                    height: 20.0,
                                    child: Text(
                                      e.username,
                                      style: TextStyle(
                                          color: Theme.of(state.context).primaryColor),
                                    )),
                                Wrap(
                                  children: [
                                    Container(
                                        child: Text(
                                      e.message,
                                      style: TextStyle(
                                          fontFeatures: [FontFeature.tabularFigures()]),
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: state.userRecord.email == e.commentOwnerEmail ? 1 : 0,
                          child: state.userRecord.email == e.commentOwnerEmail
                              ? IconButton(
                                  icon: Icon(Icons.delete_forever),
                                  onPressed: () => deleteMyComment(e),
                                )
                              : SizedBox(),
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                )
              : SizedBox(),
        )
        .toList();
  }

  void deleteMyComment(Comment e) {
    showDialog(
      context: state.context,
      builder: (context) => AlertDialog(
        content: Container(
          height: 230.0,
          child: Center(
            child: Column(
              children: [
                Text(
                  'Are you sure you want to delete your comment?',
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
                      onPressed: () => confirmDelete(e),
                      child: Text('Delete It'),
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

  void confirmDelete(Comment comment) async {
    try {
      for (var member in state.photoMemo.roomMembers) {
        if (member == state.userRecord.email) continue;
        if (!state.notifs[state.photoMemo.docID].notification.containsKey(member)) {
          state.notifs[state.photoMemo.docID].notification[member] = 0;
        } else if (state.notifs[state.photoMemo.docID].notification[member] > 0) {
          state.notifs[state.photoMemo.docID].notification[member]--;
        }
      }
      // updating comment error
      // why did this happen
      // we took away await. dont await
      FirebaseController.updateUserNotifications(
          state.photoMemo, state.notifs[state.photoMemo.docID]);
      await FirebaseController.deleteComment(
          comment: comment, photoMemo: state.photoMemo);

      state.render(() => deleteList.add(comment));
      Navigator.pop(state.context);
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Delete Comment Error',
        content: '$e',
      );
    }
  }
}
