import 'package:flutter/cupertino.dart';

enum ActivityAction {
  comment,
  myProfileChange,
  photoUpload,
}

class Activity {
  String docID;
  DateTime timestamp;
  int action; // 0 == comment, 1 == profile change, 2 == photo

  ActivityAction enumAction;

  // FOR COMMENT PHOTO, UPLOAD PHOTO, NEW PROFILE PIC
  String photoUrl;

  // FOR COMMENTS
  String commentMessage;
  String roomName;
  String photoTitle;

  Activity({
    this.docID,
    @required this.timestamp,
    @required this.enumAction,
    this.photoUrl,
    this.commentMessage,
    this.roomName,
    this.photoTitle,
  }) {
    this.action = enumAction.index;
  }

  static const TIMESTAMP = 'timestamp';
  static const ACTION = 'action';
  static const ACTION_USER_EMAIL = 'actionUserEmail';
  static const PHOTO_URL = 'photUrl';
  static const COMMENT_MESSAGE = 'commentMessage';
  static const PHOTO_TITLE = 'photoTitle';
  static const ROOM_NAME = 'roomName';

  Map<String, dynamic> serialize() {
    return {
      TIMESTAMP: this.timestamp,
      ACTION: this.action,
      PHOTO_URL: this.photoUrl,
      COMMENT_MESSAGE: this.commentMessage,
      ROOM_NAME: this.roomName,
      PHOTO_TITLE: this.photoTitle,
    };
  }

  static Activity deserialize(Map<String, dynamic> doc, String docID) {
    return Activity(
      docID: docID,
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              doc[TIMESTAMP].millisecondsSinceEpoch),
      enumAction: ActivityAction.values[doc[ACTION]],
      photoUrl: doc[PHOTO_URL],
      commentMessage: doc[COMMENT_MESSAGE],
      roomName: doc[ROOM_NAME],
      photoTitle: doc[PHOTO_TITLE],
    );
  }
}
