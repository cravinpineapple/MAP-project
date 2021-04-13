class PhotoMemo {
  String docID; // Firestore auto generated ID
  String createdBy; // owner of this photo memo
  String title;
  String memo;
  String photoFilename; // stored at Storage
  String photoURL;
  String roomName;
  DateTime timestamp;
  List<dynamic>
      sharedWith; // list of emails (dynamic gives better compatibility with Firestore)
  List<dynamic> roomMembers;
  List<dynamic> imageLabels;
  // expecting {email: int}
  Map<dynamic, dynamic> userNotifications;

  // key for  Firestore documents
  static const TITLE = 'title';
  static const MEMO = 'memo';
  static const CREATED_BY = 'createdBy';
  static const PHOTO_URL = 'photoURL';
  static const PHOTO_FILENAME = 'photoFilename';
  static const TIMESTAMP = 'timestamp';
  static const SHARED_WITH = 'sharedWith';
  static const IMAGE_LABELS = 'imageLabels';
  static const ROOM_NAME = 'roomName';
  static const ROOM_MEMBERS = 'roomMembers';
  static const USER_NOTOIFICATIONS = 'userNotifications';

  PhotoMemo({
    this.docID,
    this.createdBy,
    this.roomName,
    this.memo,
    this.title,
    this.photoFilename,
    this.photoURL,
    this.timestamp,
    this.sharedWith,
    this.roomMembers,
    this.imageLabels,
    this.userNotifications,
  }) {
    this.sharedWith ??= [];
    this.roomMembers ??= [];
    this.imageLabels ??= [];
    this.userNotifications ??= {};
  }

  PhotoMemo.clone(PhotoMemo p) {
    // direct copy okay
    this.docID = p.docID;
    this.createdBy = p.docID;
    this.roomName = p.roomName;
    this.memo = p.memo;
    this.title = p.title;
    this.photoFilename = p.photoFilename;
    this.photoURL = p.photoURL;
    this.timestamp = p.timestamp;

    // deep copy needed because sharedWith and imageLabels are
    //    references to a list
    this.sharedWith = [];
    this.sharedWith.addAll(p.sharedWith);
    this.roomMembers = [];
    this.roomMembers.addAll(p.roomMembers);
    this.imageLabels = [];
    this.imageLabels.addAll(p.imageLabels);
    this.userNotifications = {};
    this.userNotifications.addAll(p.userNotifications);
  }

  // a = b ==> a.assign(b) (achieves memberwise assignment)
  void assign(PhotoMemo p) {
    // direct copy okay
    this.docID = p.docID;
    this.roomName = p.roomName;
    this.createdBy = p.docID;
    this.memo = p.memo;
    this.title = p.title;
    this.photoFilename = p.photoFilename;
    this.photoURL = p.photoURL;
    this.timestamp = p.timestamp;

    // deep copy needed because sharedWith and imageLabels are
    //    references to a list
    this.sharedWith.clear();
    this.sharedWith.addAll(p.sharedWith);
    this.roomMembers.clear();
    this.roomMembers.addAll(p.roomMembers);
    this.imageLabels.clear();
    this.imageLabels.addAll(p.imageLabels);
    this.userNotifications.clear();
    this.userNotifications.addAll(p.userNotifications);
  }

  // converts dart object (instance of class) to compatible Firestore document
  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      TITLE: this.title,
      CREATED_BY: this.createdBy,
      ROOM_NAME: this.roomName,
      MEMO: this.memo,
      PHOTO_FILENAME: this.photoFilename,
      PHOTO_URL: this.photoURL,
      SHARED_WITH: this.sharedWith,
      ROOM_MEMBERS: this.roomMembers,
      TIMESTAMP: this.timestamp,
      IMAGE_LABELS: this.imageLabels,
      USER_NOTOIFICATIONS: this.userNotifications,
    };
  }

  // converts Firestore document to dart object
  static PhotoMemo deserialize(Map<String, dynamic> doc, String docID) {
    return PhotoMemo(
      docID: docID,
      createdBy: doc[CREATED_BY],
      roomName: doc[ROOM_NAME],
      title: doc[TITLE],
      memo: doc[MEMO],
      photoFilename: doc[PHOTO_FILENAME],
      photoURL: doc[PHOTO_URL],
      sharedWith: doc[SHARED_WITH],
      roomMembers: doc[ROOM_MEMBERS],
      imageLabels: doc[IMAGE_LABELS],
      userNotifications: doc[USER_NOTOIFICATIONS],
      timestamp: doc[TIMESTAMP] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(doc[TIMESTAMP].millisecondsSinceEpoch),
    );
  }

  static String validateTitle(String value) {
    if (value == null || value.length < 3)
      return 'too short';
    else
      return null;
  }

  static String validateMemo(String value) {
    if (value == null || value.length < 5)
      return 'too short';
    else
      return null;
  }

  static String validateSharedWith(String value) {
    // not sharing with anyone
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
