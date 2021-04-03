import 'package:flutter/cupertino.dart';

class UserRecord {
  String docID;
  String email;
  String username;
  String profilePictureURL;
  int age;

  static const EMAIL = 'email';
  static const USERNAME = 'username';
  static const PROFILE_PICTURE_URL = 'profilePictureURL';
  static const AGE = 'age';

  // DEFAULT PROFILE PICS URLS
  static const USER1_DEFAULT_PROFILE_PIC_URL =
      'https://firebasestorage.googleapis.com/v0/b/cmsc4303-noahs-lesson3part1.appspot.com/o/profile_pictures%2Fuser1.png?alt=media&token=1fa46ecd-eca0-43f9-963b-905494ce25e9';
  static const USER2_DEFAULT_PROFILE_PIC_URL =
      'https://firebasestorage.googleapis.com/v0/b/cmsc4303-noahs-lesson3part1.appspot.com/o/profile_pictures%2Fuser2.png?alt=media&token=5637495a-0a59-4123-b9c0-a6b84a1cc211';
  static const USER3_DEFAULT_PROFILE_PIC_URL =
      'https://firebasestorage.googleapis.com/v0/b/cmsc4303-noahs-lesson3part1.appspot.com/o/profile_pictures%2Fuser3.png?alt=media&token=681b0d9d-ce0d-4179-9f58-73a5a52ca371';
  static const USER4_DEFAULT_PROFILE_PIC_URL =
      'https://firebasestorage.googleapis.com/v0/b/cmsc4303-noahs-lesson3part1.appspot.com/o/profile_pictures%2Fuser4.png?alt=media&token=ff1cc63d-c49d-413d-b0e3-ddf0143badc9';

  UserRecord({
    @required this.email,
    this.docID,
    this.username,
    this.profilePictureURL,
    this.age,
  });

  UserRecord.clone(UserRecord u) {
    this.docID = u.docID;
    this.email = u.email;
    this.username = u.username;
    this.profilePictureURL = u.profilePictureURL;
    this.age = u.age;
  }

  Map<String, dynamic> serialize() {
    return <String, dynamic>{
      EMAIL: this.email,
      USERNAME: this.username,
      PROFILE_PICTURE_URL: this.profilePictureURL,
      AGE: this.age,
    };
  }

  static UserRecord deserialize(Map<String, dynamic> doc, String docID) {
    return UserRecord(
      docID: docID,
      email: doc[EMAIL],
      username: doc[USERNAME],
      profilePictureURL: doc[PROFILE_PICTURE_URL],
      age: doc[AGE],
    );
  }
}
