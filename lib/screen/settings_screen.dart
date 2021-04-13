import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3part1/controller/firebasecontroller.dart';
import 'package:lesson3part1/model/activity.dart';
import 'package:lesson3part1/model/userrecord.dart';
import 'package:lesson3part1/screen/myview/mydialog.dart';

import '../model/constant.dart';
import 'myview/myimage.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settingsScreen';

  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<SettingsScreen> {
  _Controller con;
  UserRecord userRecord;
  User user;
  File photo;
  bool editMode = false;
  double profilePicLength = 225.0;
  String progressMessage;
  List<Activity> activityFeed;
  Activity temp;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(func) {
    setState(func);
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    userRecord ??= args[Constant.ARG_USERRECORD];
    user ??= args[Constant.ARG_USER];
    activityFeed ??= args[Constant.ARG_ACTIVITY_FEED];

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          editMode
              ? IconButton(
                  icon: Icon(Icons.check),
                  onPressed: con.update,
                )
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: con.edit,
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: profilePicLength,
                      width: profilePicLength,
                      child: photo == null
                          ? ClipOval(
                              child: FittedBox(
                                child: MyImage.network(
                                  url: userRecord.profilePictureURL,
                                  context: context,
                                ),
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipOval(
                              child: Image.file(
                                photo,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    editMode
                        ? Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: ClipOval(
                              child: Container(
                                color: Colors.blue[200],
                                child: PopupMenuButton<String>(
                                  icon: Icon(Icons.photo),
                                  onSelected: con.getPhoto,
                                  itemBuilder: (context) =>
                                      <PopupMenuEntry<String>>[
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
                          )
                        : SizedBox(),
                  ],
                ),
                SizedBox(height: 10.0),
                progressMessage == null
                    ? SizedBox()
                    : Text(
                        progressMessage,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                SizedBox(height: 10.0),
                Divider(height: 5.0),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Username',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        enabled: editMode,
                        initialValue: userRecord.username,
                        validator: con.validateUsername,
                        onSaved: con.saveUsername,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Age',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        enabled: editMode,
                        initialValue: userRecord.age.toString(),
                        validator: con.validateAge,
                        onSaved: con.saveAge,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Email',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        userRecord.email,
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _ProfileState state;
  _Controller(this.state);
  String updatedUsername = 'A';
  int updatedAge = 99;

  void edit() {
    state.render(() => state.editMode = true);
  }

  void update() async {
    if (!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();

    UserRecord tempUserRecord = UserRecord.clone(state.userRecord);
    tempUserRecord.age = updatedAge;
    tempUserRecord.username = updatedUsername;

    try {
      if (state.photo != null) {
        String temp = tempUserRecord.profilePictureURL;

        Map photoInfo = await FirebaseController.uploadPhotoFile(
          profilePic: true,
          photo: state.photo,
          uid: state.user.uid,
          listener: (double progress) {
            state.render(() {
              if (progress == null)
                state.progressMessage = null;
              else {
                progress *= 100;
                state.progressMessage =
                    'Uploading: ' + progress.toStringAsFixed(1) + '%';
              }
            });
          },
        );
        tempUserRecord.profilePictureURL = photoInfo[Constant.ARG_DOWNLOADURL];
      }

      await FirebaseController.updateUserProfileInformation(
          userRecord: tempUserRecord);

      state.temp = Activity(
          timestamp: DateTime.now(),
          enumAction: ActivityAction.myProfileChange,
          photoUrl: tempUserRecord.profilePictureURL);
      state.temp.docID =
          await FirebaseController.addActivity(state.temp, state.userRecord);

      state.activityFeed.insert(0, state.temp);
      for (int i = 0; i < state.activityFeed.length; i++) {
        print('${state.activityFeed[i].timestamp}');
      }

      state.render(() => state.userRecord.assign(tempUserRecord));
      state.editMode = false;
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Update User Record Error',
        content: '$e',
      );
    }

    state.render(() => state.userRecord.assign(tempUserRecord));
  }

  String validateUsername(String value) {
    if (value.trim().length == 0 || value.trim().length > 20) {
      return 'min 1 chars, max 20 chars';
    } else {
      return null;
    }
  }

  void saveUsername(String value) {
    updatedUsername = value;
  }

  String validateAge(String value) {
    try {
      int age = int.parse(value);
      if (age >= 13 && age <= 125)
        return null;
      else
        return 'Min age is 13';
    } catch (e) {
      return 'Age must be a number';
    }
  }

  void saveAge(String value) {
    updatedAge = int.parse(value);
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

      if (_imageFile == null)
        return; // selection from camera/gallery was canceled
      state.render(() => state.photo = File(_imageFile.path));
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Failed to get picutre',
        content: '$e',
      );
    }
  }
}
