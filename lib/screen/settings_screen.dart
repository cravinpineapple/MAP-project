import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/constant.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settingsScreen';

  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<SettingsScreen> {
  _Controller con;
  User user;
  bool editMode = false;
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
    // user ??= args[Constant.ARG_USER];

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
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Username',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        enabled: editMode,
                        initialValue: 'username here',
                        validator: null,
                        onSaved: null,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Age',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        enabled: editMode,
                        initialValue: 'age here',
                        validator: con.validateAge,
                        onSaved: con.saveAge,
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

  void edit() {
    state.render(() => state.editMode = true);
  }

  void update() {
    if (!state.formKey.currentState.validate()) return;

    state.formKey.currentState.save();

    state.render(() => state.editMode = false);
  }

  String validateUsername(String value) {
    if (value.length < 2) {
      return 'min 2 chars';
    } else {
      return null;
    }
  }

  void saveUsername(String value) {}

  String validateAge(String value) {
    try {
      int age = int.parse(value);
      if (age >= 5)
        return null;
      else
        return 'Min age is 5';
    } catch (e) {
      return 'Not valid age';
    }
  }

  void saveAge(String value) {}
}
