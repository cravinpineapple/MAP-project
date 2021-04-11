import 'package:flutter/cupertino.dart';

class Comment {
  String docID;
  String commentOwnerEmail;
  String username;
  String profilePicURL;
  String message;
  DateTime datePosted;

  static const COMMENT_MESSAGE = 'commentMessage';
  static const DATE_POSTED = 'datePosted';
  static const COMMENT_OWNER_EMAIL = 'commentOwnerEmail';

  Comment({
    @required this.commentOwnerEmail,
    @required this.message,
    @required this.datePosted,
    this.profilePicURL,
    this.username,
    this.docID,
  });

  Map<String, dynamic> serialize() {
    return {
      COMMENT_OWNER_EMAIL: this.commentOwnerEmail,
      COMMENT_MESSAGE: this.message,
      DATE_POSTED: this.datePosted,
    };
  }

  static Comment deserialize(Map<String, dynamic> doc, String docID) {
    return Comment(
      commentOwnerEmail: doc[COMMENT_OWNER_EMAIL],
      message: doc[COMMENT_MESSAGE],
      datePosted: doc[DATE_POSTED] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(doc[DATE_POSTED].millisecondsSinceEpoch),
      docID: docID,
    );
  }
}
