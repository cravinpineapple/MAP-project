import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lesson3part1/model/userrecord.dart';

import '../controller/firebasecontroller.dart';
import 'myview/mydialog.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/signUpScreen';

  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(func) => setState(func);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create an account'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 15.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Create an Account',
                  style: Theme.of(context).textTheme.headline5,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: con.validateEmail,
                  onSaved: con.saveEmail,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Password',
                  ),
                  obscureText: true,
                  autocorrect: false,
                  validator: con.validatePassword,
                  onSaved: con.savePassword,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Password confirm',
                  ),
                  obscureText: true,
                  autocorrect: false,
                  validator: con.validatePassword,
                  onSaved: con.savePasswordConfirm,
                ),
                con.passwordErrorMesssage == null
                    ? SizedBox(
                        height: 1.0,
                      )
                    : Text(
                        con.passwordErrorMesssage,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14.0,
                        ),
                      ),
                RaisedButton(
                  onPressed: con.createAccount,
                  child: Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.button,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _SignUpState state;
  _Controller(this.state);

  String email;
  String password;
  String passwordConfirm;
  String passwordErrorMesssage;

  String validateEmail(String value) {
    if (value.contains('@') && value.contains('.')) return null;

    return 'Invalid Email';
  }

  void saveEmail(String value) {
    email = value;
  }

  String validatePassword(String value) {
    if (value.length < 6) return 'too short';

    return null;
  }

  void savePassword(String value) {
    password = value;
  }

  void savePasswordConfirm(String value) {
    passwordConfirm = value;
  }

  void createAccount() async {
    if (!state.formKey.currentState.validate()) return;

    state.render(() => passwordErrorMesssage = null);
    state.formKey.currentState.save();

    if (password != passwordConfirm) {
      state.render(() => passwordErrorMesssage = 'Passwords do not match');
      return;
    }

    try {
      Random rand = Random();
      List<dynamic> defaultProfilePics = [
        UserRecord.USER1_DEFAULT_PROFILE_PIC_URL,
        UserRecord.USER2_DEFAULT_PROFILE_PIC_URL,
        UserRecord.USER3_DEFAULT_PROFILE_PIC_URL,
        UserRecord.USER4_DEFAULT_PROFILE_PIC_URL,
      ];

      await FirebaseController.createAccount(email: email, password: password);
      UserRecord userRecord = UserRecord(
        email: email,
        username: email.split('@')[0],
        age: 0,
        profilePictureURL: defaultProfilePics[rand.nextInt(4)],
      );
      await FirebaseController.createUserRecord(userRecord: userRecord)
          .then((value) => userRecord.docID = value);
      MyDialog.info(
        context: state.context,
        title: 'Account Created',
        content: 'Go to Sign In to use the app',
      );
    } catch (e) {
      MyDialog.info(
          context: state.context, title: 'Cannot Create', content: '$e');
    }
  }
}
