import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3part1/model/activity.dart';
import 'package:lesson3part1/model/constant.dart';
import 'package:lesson3part1/model/notif.dart';
import 'package:lesson3part1/model/photomemo.dart';
import 'package:lesson3part1/model/room.dart';
import 'package:lesson3part1/model/userrecord.dart';

import '../controller/firebasecontroller.dart';
import 'myview/mydialog.dart';

class AddPhotoMemoScreen extends StatefulWidget {
  static const routeName = '/addPhotoMemoScreen';

  @override
  State<StatefulWidget> createState() {
    return _AddPhotoMemoState();
  }
}

class _AddPhotoMemoState extends State<AddPhotoMemoScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  _Controller con;
  User user;

  // uploading photo
  UserRecord userRecord;
  // all other members that need to be notified
  List<UserRecord> otherMembers;

  List<PhotoMemo> photoMemoList;
  List<dynamic> roomMemoList;
  List<PhotoMemo> roomActualPhotoMemos;
  Map<dynamic, dynamic> notif;
  File photo;
  String progressMessage;
  Room room;
  List<Activity> activityFeed;
  bool isImageMLSwitchedOn = false;
  bool isTextMLSwitchedOn = false;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(func) => setState(func);

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    user ??= args[Constant.ARG_USER];
    photoMemoList ??= args[Constant.ARG_PHOTOMEMOLIST];
    roomMemoList ??= args[Constant.ARG_ROOM_MEMO_DOCIDS];
    roomActualPhotoMemos ??= args[Constant.ARG_ROOM_MEMOLIST];
    room ??= args[Constant.ARG_ROOM];
    notif ??= args[Constant.ARG_NOTIFS];
    userRecord ??= args[Constant.ARG_USERRECORD];
    otherMembers ??= args[Constant.ARG_USERRECORD_LIST];
    activityFeed ??= args[Constant.ARG_ACTIVITY_FEED];

    String title = room != null ? 'Upload Photo' : 'Upload Photo Privately';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: con.save,
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: photo == null
                        ? Icon(
                            Icons.photo_library,
                            size: 300.0,
                          )
                        : Image.file(
                            photo,
                            fit: BoxFit.fill,
                          ),
                  ),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: Container(
                      color: Colors.blue[200],
                      child: PopupMenuButton<String>(
                        onSelected: con.getPhoto,
                        itemBuilder: (context) => <PopupMenuEntry<String>>[
                          PopupMenuItem(
                            value: Constant.SRC_CAMERA,
                            child: Row(
                              children: [
                                Icon(Icons.photo_camera),
                                Text(Constant.SRC_CAMERA),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: Constant.SRC_GALLERY,
                            child: Row(
                              children: [
                                Icon(Icons.photo_album),
                                Text(Constant.SRC_GALLERY),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              progressMessage == null
                  ? SizedBox(height: 1.0)
                  : Text(progressMessage, style: Theme.of(context).textTheme.headline6),
              SizedBox(
                height: 20.0,
              ),
              Text(
                'Select Additional Machine Learning Options',
                style: Theme.of(context).textTheme.headline6,
              ),
              Container(
                height: 90.0,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20.0,
                          ),
                          Text('Image Labeler ML'),
                          Container(
                            width: 80.0,
                            child: Switch(
                              value: isImageMLSwitchedOn,
                              onChanged: (v) => render(() => isImageMLSwitchedOn = v),
                              activeTrackColor: isImageMLSwitchedOn
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              inactiveThumbColor:
                                  isImageMLSwitchedOn ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20.0,
                          ),
                          Text('Text Recognition ML'),
                          Container(
                            width: 80.0,
                            child: Switch(
                              value: isTextMLSwitchedOn,
                              onChanged: (v) => render(() => isTextMLSwitchedOn = v),
                              activeTrackColor: isTextMLSwitchedOn
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              inactiveThumbColor:
                                  isTextMLSwitchedOn ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(),
                      flex: 1,
                    ),
                  ],
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Title',
                ),
                autocorrect: true,
                validator: PhotoMemo.validateTitle,
                onSaved: con.saveTitle,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Memo',
                ),
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveMemo,
              ),
              room == null
                  ? TextFormField(
                      decoration: InputDecoration(
                        hintText:
                            'SharedWith (comma seperated email list). \nLeave empty to upload privately',
                      ),
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      maxLines: 2,
                      validator: PhotoMemo.validateSharedWith,
                      onSaved: con.saveSharedWith,
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _AddPhotoMemoState state;
  _Controller(this.state);
  PhotoMemo tempMemo = PhotoMemo();
  Activity tempActivity;

  void save() async {
    if (!state.formKey.currentState.validate()) return;

    // now validated
    state.formKey.currentState.save();

    MyDialog.circularProggressStart(state.context);

    try {
      Map photoInfo = await FirebaseController.uploadPhotoFile(
        profilePic: false,
        photo: state.photo,
        uid: state.user.uid,
        listener: (double progress) {
          state.render(() {
            if (progress == null)
              state.progressMessage = null;
            else {
              progress *= 100;
              state.progressMessage = 'Uploading: ' + progress.toStringAsFixed(1) + '%';
            }
          });
        },
      );

      List<dynamic> imageLabels = <dynamic>[];
      List<dynamic> textLabels = <dynamic>[];
      if (state.isImageMLSwitchedOn) {
        // image labels by ML
        state.render(() => state.progressMessage = 'ML Image Labeler Started');
        imageLabels = await FirebaseController.getImageLabels(photoFile: state.photo);
        state.render(() => state.progressMessage = null);
      }

      if (state.isTextMLSwitchedOn) {
        state.render(() => state.progressMessage = 'ML Text Recognition Started');
        textLabels = await FirebaseController.getRecognizedText(photoFile: state.photo);
        state.render(() => state.progressMessage = null);
      }

      imageLabels.addAll(textLabels);
      tempMemo.photoFilename = photoInfo[Constant.ARG_FILENAME];
      tempMemo.photoURL = photoInfo[Constant.ARG_DOWNLOADURL];
      tempMemo.roomName = state.room == null ? null : state.room.roomName;
      tempMemo.timestamp = DateTime.now();
      tempMemo.createdBy = state.user.email;
      tempMemo.imageLabels = imageLabels;
      if (state.room != null) tempMemo.roomMembers.addAll(state.room.members);
      String docID = await FirebaseController.addPhotoMemo(tempMemo);
      tempMemo.docID = docID;

      if (state.room != null) {
        state.notif[docID] = Notif(notification: {});
        state.notif[docID].docID =
            await FirebaseController.addNotif(state.notif[docID], docID);
      }

      if (state.room != null) {
        state.roomActualPhotoMemos.add(tempMemo);
        state.room.memos.add(docID);
        await FirebaseController.updateRoom(
          emails: state.room.members,
          room: state.room,
        );
      }

      state.photoMemoList.insert(0, tempMemo);

      // Give Activity Feed notification to all other room members
      if (state.room != null) {
        tempActivity = Activity(
          enumAction: ActivityAction.photoUpload,
          timestamp: tempMemo.timestamp,
          actionOwnerUsername: state.userRecord.username,
          photoUrl: tempMemo.photoURL,
          roomName: state.room.roomName,
        );
        state.activityFeed.insert(0, tempActivity);

        for (var u in state.otherMembers) {
          if (u.email == state.userRecord.email) {
            tempActivity.actionOwnerUsername = 'I';
            FirebaseController.addActivity(tempActivity, u);
            tempActivity.actionOwnerUsername = state.userRecord.username;
            continue;
          }

          FirebaseController.addActivity(tempActivity, u);
        }
      }

      MyDialog.circularProgressStop(state.context);
      Navigator.pop(state.context); // return to user home screen
    } catch (e) {
      MyDialog.circularProgressStop(state.context);
      MyDialog.info(
        context: state.context,
        title: 'Save Photo Memo Error',
        content: '$e',
      );
      print('=========== $e');
    }
  }

  void getPhoto(String src) async {
    try {
      PickedFile _imageFile;
      var _picker = ImagePicker();

      // if coming from camera
      if (src == Constant.SRC_CAMERA) {
        _imageFile = await _picker.getImage(source: ImageSource.camera);
      }
      // if coming from gallery
      else {
        _imageFile = await _picker.getImage(source: ImageSource.gallery);
      }

      if (_imageFile == null) return; // selection from camera/gallery was canceled
      state.render(() => state.photo = File(_imageFile.path));
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Failed to get picutre',
        content: '$e',
      );
    }
  }

  void saveTitle(String value) {
    tempMemo.title = value;
  }

  void saveMemo(String value) {
    tempMemo.memo = value;
  }

  void saveSharedWith(String value) {
    if (value.trim().length != 0) {
      tempMemo.sharedWith = value.split(RegExp('(,| )+')).map((e) => e.trim()).toList();
    }
  }
}
