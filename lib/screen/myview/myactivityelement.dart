import 'package:flutter/material.dart';
import 'package:lesson3part1/model/activity.dart';
import 'package:lesson3part1/model/userrecord.dart';
import 'package:intl/intl.dart';
import 'package:lesson3part1/screen/myview/mydialog.dart';
import 'package:lesson3part1/screen/myview/myimage.dart';

class ActivityElement extends StatefulWidget {
  final UserRecord userRecord;
  final Activity activity;

  ActivityElement({@required this.userRecord, @required this.activity});

  @override
  State<StatefulWidget> createState() {
    return _ActivityElementState();
  }
}

class _ActivityElementState extends State<ActivityElement> {
  _Controller con;

  UserRecord userRecord;
  Activity activity;
  double imageSize = 75.0;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    userRecord = widget.userRecord;
    activity = widget.activity;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('EEE, M/d/y H:mm');

    return Container(
      margin: EdgeInsets.only(top: 10.0, left: 7.0, right: 7.0),
      color: Colors.grey[800],
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.all(5.0),
            width: imageSize,
            height: imageSize,
            child: FittedBox(
              clipBehavior: Clip.hardEdge,
              fit: BoxFit.cover,
              child: MyImage.network(
                context: context,
                url: activity.photoUrl,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatter.format(activity.timestamp),
                ),
                con.getActionInfo(actionType: activity.enumAction),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Controller {
  _ActivityElementState state;
  _Controller(this.state);

  Widget getActionInfo({ActivityAction actionType}) {
    switch (actionType) {
      case ActivityAction.comment:
        String commentMessage = state.activity.commentMessage.length >= 20
            ? state.activity.commentMessage.substring(0, 20) + '...'
            : state.activity.commentMessage;
        return Text(
            '${state.activity.actionOwnerUsername} left a comment on ${state.activity.photoTitle} in room ${state.activity.roomName}\n$commentMessage');
      case ActivityAction.myProfileChange:
        return Text('You updated your profile.');
      case ActivityAction.photoUpload:
        return Text(
            '${state.activity.actionOwnerUsername} uploaded a new photo in ${state.activity.roomName}');
      default:
        return Text('Uh oh');
    }
  }
}
