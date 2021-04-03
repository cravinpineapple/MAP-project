import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:lesson3part1/model/photomemo.dart';
import 'package:lesson3part1/model/room.dart';
import 'package:lesson3part1/model/userrecord.dart';

import '../model/constant.dart';

class FirebaseController {
  static Future<User> signIn(
      {@required String email, @required String password}) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return userCredential.user;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> createAccount(
      {@required String email, @required String password}) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<Map<String, String>> uploadPhotoFile({
    @required File photo,
    String fileName,
    @required String uid,
    @required Function listener,
  }) async {
    fileName ??= '${Constant.PHOTOIMAGE_FOLDER}/$uid/${DateTime.now()}';
    UploadTask task = FirebaseStorage.instance.ref(fileName).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      double progress = event.bytesTransferred / event.totalBytes;
      if (event.bytesTransferred == event.totalBytes) progress = null;
      listener(progress);
    });
    await task;
    String downloadURL =
        await FirebaseStorage.instance.ref(fileName).getDownloadURL();
    return <String, String>{
      Constant.ARG_DOWNLOADURL: downloadURL,
      Constant.ARG_FILENAME: fileName,
    };
  }

  static Future<bool> checkIfUserExists({@required String email}) async {
    try {
      List<String> temp =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      print('============= checkIfUserExists - list size: ${temp.length}');
      return temp.length > 0;
    } catch (error) {
      return false;
    }
  }

  static Future<void> updateRoom({
    @required List<dynamic> emails,
    @required Room room,
  }) async {
    CollectionReference roomCollection =
        FirebaseFirestore.instance.collection(Constant.ROOM_COLLECTION);

    roomCollection.doc(room.docID).update(
      {
        Room.OWNER: room.owner,
        Room.MEMBERS: emails,
        Room.MEMOS: room.memos,
        Room.ROOM_NAME: room.roomName,
      },
    ).catchError((e) => print('$e'));
  }

  static Future<String> addPhotoMemo(PhotoMemo photoMemo) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .add(photoMemo.serialize());

    return ref.id;
  }

  static Future<void> changeOwner(Room room, String updatedOwner) async {
    CollectionReference roomCollection =
        FirebaseFirestore.instance.collection(Constant.ROOM_COLLECTION);

    if (!room.members.contains(updatedOwner.trim()))
      room.members.add(updatedOwner.trim());

    print('==== docid ${room.docID}');

    roomCollection.doc(room.docID).update({
      Room.OWNER: updatedOwner,
      Room.MEMBERS: room.members,
      Room.MEMOS: room.memos,
      Room.ROOM_NAME: room.roomName,
    }).catchError(
      (error) => print(
        'Update Owner Failed in Firebase Controller. ERROR: $error',
      ),
    );

    /*

    String docID, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docID)
        .update(updateInfo);
    */
    // roomCollection.doc(room.docID)
  }

  static Future<String> addRoom(Room room) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.ROOM_COLLECTION)
        .add(room.serialize());

    return ref.id;
  }

  static Future<List<PhotoMemo>> getPhotoMemoList(
      {@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });

    return result;
  }

  static Future<List<PhotoMemo>> getRoomPhotoMemoList(
      {@required List<dynamic> photoMemoList}) async {
    List<DocumentSnapshot> documentSnapshots = [];
    for (var e in photoMemoList) {
      DocumentSnapshot dSnap = await getPhotoMemoSnapshot(docID: e);
      documentSnapshots.add(dSnap);
    }

    var result = <PhotoMemo>[];
    documentSnapshots.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });

    return result;
  }

  static Future<DocumentSnapshot> getPhotoMemoSnapshot(
      {@required String docID}) async {
    DocumentSnapshot docSnap = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docID)
        .get();
    return docSnap;
  }

  static Future<List<Room>> getRoomList({@required String email}) async {
    print(email);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.ROOM_COLLECTION)
        .where(Room.MEMBERS, arrayContains: email)
        .orderBy(Room.ROOM_NAME,
            descending: true) // WARNING: desecnding false breaks login
        .get();

    print('docs');
    print(querySnapshot.docs);

    var result = <Room>[];
    querySnapshot.docs.forEach((doc) {
      result.add(Room.deserialize(doc.data(), doc.id));
    });

    return result;
  }

  static Future<void> deleteRoom(Room r) async {
    await FirebaseFirestore.instance
        .collection(Constant.ROOM_COLLECTION)
        .doc(r.docID)
        .delete();

    // TODO: delete photos from room as well.
  }

  static Future<List<dynamic>> getImageLabels(
      {@required File photoFile}) async {
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(photoFile);
    final ImageLabeler cloudLabeler =
        FirebaseVision.instance.cloudImageLabeler();
    final List<ImageLabel> cloudLabels =
        await cloudLabeler.processImage(visionImage);

    List<dynamic> labels = <dynamic>[];

    for (ImageLabel label in cloudLabels) {
      if (label.confidence >= Constant.MIN_ML_CONFIDENCE)
        labels.add(label.text.toLowerCase());
    }

    return labels;
  }

  static Future<void> updatePhotoMemo(
      String docID, Map<String, dynamic> updateInfo) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(docID)
        .update(updateInfo);
  }

  static Future<List<PhotoMemo>> getPhotoMemoSharedWithMe(
      {@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.SHARED_WITH, arrayContains: email)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var result = <PhotoMemo>[];
    querySnapshot.docs.forEach((doc) {
      result.add(PhotoMemo.deserialize(doc.data(), doc.id));
    });

    return result;
  }

  static Future<void> deletePhotoMemo(PhotoMemo p) async {
    await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .doc(p.docID)
        .delete();
    await FirebaseStorage.instance.ref(p.photoFilename).delete();
  }

  static Future<List<PhotoMemo>> searchImage(
      {@required String createdBy, @required List<String> searchLabels}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.PHOTOMEMO_COLLECTION)
        .where(PhotoMemo.CREATED_BY, isEqualTo: createdBy)
        .where(PhotoMemo.IMAGE_LABELS, arrayContainsAny: searchLabels)
        .orderBy(PhotoMemo.TIMESTAMP, descending: true)
        .get();

    var results = <PhotoMemo>[];
    querySnapshot.docs.forEach(
        (doc) => results.add(PhotoMemo.deserialize(doc.data(), doc.id)));

    return results;
  }

  static Future<String> createUserRecord(
      {@required UserRecord userRecord}) async {
    var ref = await FirebaseFirestore.instance
        .collection(Constant.USERRECORD_COLLECTION)
        .add(userRecord.serialize());

    return ref.id;
  }

  static Future<UserRecord> getUserRecord({@required String email}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constant.USERRECORD_COLLECTION)
        .where(UserRecord.EMAIL, isEqualTo: email)
        .get();

    UserRecord userRecord;
    querySnapshot.docs.forEach(
        (doc) => userRecord = UserRecord.deserialize(doc.data(), doc.id));
    return userRecord;
  }
}
