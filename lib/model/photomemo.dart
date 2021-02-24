class PhotoMemo {
  String docID; // Firestore auto generated ID
  String createdBy; // owner of this photo memo
  String title;
  String memo;
  String photoFilename; // stored at Storage
  String photoURL;
  DateTime timestamp;
  List<dynamic>
      sharedWith; // list of emails (dynamic gives better compatibility with Firestore)
  List<dynamic> imageLabels;

  // key for  Firestore documents
  static const TITLE = 'title';
  static const MEMO = 'memo';
  static const CREATED_BY = 'createdBy';
  static const PHOTO_URL = 'photoURL';
  static const PHOTO_FILENAME = 'photoFilename';
  static const TIMESTAMP = 'timestamp';
  static const SHARED_WITH = 'sharedWith';
  static const IMAGE_LABELS = 'imageLabels';

  PhotoMemo({
    this.docID,
    this.createdBy,
    this.memo,
    this.title,
    this.photoFilename,
    this.photoURL,
    this.timestamp,
    this.sharedWith,
    this.imageLabels,
  }) {
    this.sharedWith ??= [];
    this.imageLabels ??= [];
  }

  // converts dart object (instance of class) to compatible Firestore document
  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      TITLE: this.title,
      CREATED_BY: this.createdBy,
      MEMO: this.memo,
      PHOTO_FILENAME: this.photoFilename,
      PHOTO_URL: this.photoURL,
      SHARED_WITH: this.sharedWith,
      TIMESTAMP: this.timestamp,
      IMAGE_LABELS: this.imageLabels,
    };
  }

  // converts Firestore document to dart object
  static PhotoMemo deserialize(Map<String, dynamic> doc, String docID) {
    return PhotoMemo(
      docID: docID,
      createdBy: doc[CREATED_BY],
      title: doc[TITLE],
      memo: doc[MEMO],
      photoFilename: doc[PHOTO_FILENAME],
      photoURL: doc[PHOTO_URL],
      sharedWith: doc[SHARED_WITH],
      imageLabels: doc[IMAGE_LABELS],
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
