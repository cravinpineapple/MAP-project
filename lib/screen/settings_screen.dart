import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  bool editMode = false;
  double profilePicLength = 225.0;
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
                Container(
                  height: profilePicLength,
                  width: profilePicLength,
                  child: ClipOval(
                    child: MyImage.network(
                      url: userRecord.profilePictureURL,
                      context: context,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
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
                        validator: null,
                        onSaved: null,
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
  UserRecord tempUserRecord;

  void edit() {
    state.render(() => state.editMode = true);
  }

  void update() async {
    if (!state.formKey.currentState.validate()) return;
    state.formKey.currentState.save();

    try {
      tempUserRecord.assign(state.userRecord);
      // TODO: FIREBASE STUFF
    } catch (e) {
      MyDialog.info(
        context: state.context,
        title: 'Update User Record Error',
        content: '$e',
      );
    }

    state.render(() => state.editMode = false);
  }

  String validateUsername(String value) {
    if (value.length == 0 || value.length > 20) {
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
      if (age >= 13 || age <= 125)
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
}
