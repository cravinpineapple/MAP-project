import 'package:flutter/material.dart';

class Notif {
  Map<dynamic, dynamic> notification;
  String docID;

  Notif({@required this.notification, this.docID});

  static const NOTIFICATION = 'notification';

  Notif.clone(Notif n) {
    this.notification = {};
    this.notification.addAll(n.notification);
    this.docID = n.docID;
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic>{NOTIFICATION: this.notification};
  }

  static Notif deserialize(Map<String, dynamic> doc, String docID) {
    return Notif(docID: docID, notification: doc[NOTIFICATION]);
  }
}
