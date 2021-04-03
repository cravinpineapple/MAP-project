class UserRecord {
  String email;
  String username;
  String profilePictureURL;
  int age;

  UserRecord({this.email, this.username, this.profilePictureURL, this.age});

  UserRecord.clone(UserRecord u) {
    this.email = u.email;
    this.username = u.username;
    this.profilePictureURL = u.profilePictureURL;
    this.age = u.age;
  }
}
