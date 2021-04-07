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
  static const PROFILE_PIC_URL = 'profilePicURL';
  static const USERNAME = 'username';
  static const COMMENT_OWNER_EMAIL = 'commentOwnerEmail';

  Comment({
    @required this.commentOwnerEmail,
    @required this.profilePicURL,
    @required this.username,
    @required this.message,
    @required this.datePosted,
    this.docID,
  });

  Map<String, dynamic> serialize() {
    return {
      COMMENT_OWNER_EMAIL: this.commentOwnerEmail,
      USERNAME: this.username,
      PROFILE_PIC_URL: this.profilePicURL,
      COMMENT_MESSAGE: this.message,
      DATE_POSTED: this.datePosted,
    };
  }

  static Comment deserialize(Map<String, dynamic> doc, String docID) {
    return Comment(
      profilePicURL: doc[PROFILE_PIC_URL],
      commentOwnerEmail: doc[COMMENT_OWNER_EMAIL],
      username: doc[USERNAME],
      message: doc[COMMENT_MESSAGE],
      datePosted: doc[DATE_POSTED] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(doc[DATE_POSTED].millisecondsSinceEpoch),
      docID: docID,
    );
  }
}
