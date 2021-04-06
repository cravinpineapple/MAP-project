import 'package:flutter/cupertino.dart';
import 'package:lesson3part1/model/userrecord.dart';

class Comment {
  String docID;
  UserRecord commentOwner;
  String message;
  DateTime datePosted;

  static const COMMENT_OWNER = 'commentOwner';
  static const COMMENT_MESSAGE = 'commentMessage';
  static const DATE_POSTED = 'datePosted';

  Comment({
    @required this.commentOwner,
    @required this.message,
    @required this.datePosted,
    @required this.docID,
  });

  Map<String, dynamic> serialize() {
    return {
      COMMENT_MESSAGE: this.message,
      COMMENT_OWNER: this.commentOwner,
      DATE_POSTED: this.datePosted,
    };
  }

  static Comment deserialize(Map<String, dynamic> doc, String docID) {
    return Comment(
      commentOwner: doc[COMMENT_OWNER],
      message: doc[COMMENT_MESSAGE],
      datePosted: doc[DATE_POSTED],
      docID: docID,
    );
  }
}
