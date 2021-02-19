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
