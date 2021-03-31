import 'photomemo.dart';

class Room {
  String docID;
  String roomName;
  List<dynamic> members;
  List<dynamic> memos;
  String owner;

  static const ROOM_NAME = 'roomName';
  static const MEMBERS = 'members';
  static const OWNER = 'owner';
  static const MEMOS = 'memos';

  Room({
    this.docID,
    this.roomName,
    this.members,
    this.memos,
    this.owner,
  }) {
    this.members ??= [];
    this.memos ??= [];
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      ROOM_NAME: this.roomName,
      MEMBERS: this.members,
      OWNER: this.owner,
      MEMOS: this.memos,
    };
  }

  static Room deserialize(Map<String, dynamic> doc, String docID) {
    return Room(
      docID: docID,
      roomName: doc[ROOM_NAME],
      members: doc[MEMBERS],
      memos: doc[MEMOS],
      owner: doc[OWNER],
    );
  }

  static String validateUserList(String value) {
    if (value == null || value.trim().length == 0) return null;

    // sharing with people
    List<String> emailList = value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    for (String email in emailList) {
      if (email.contains('@') && email.contains('.'))
        continue;
      else
        return 'Comma(,) or space seperated email list';
    }

    return null;
  }
}
