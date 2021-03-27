import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lesson3part1/screen/addphotomemo_screen.dart';
import 'package:lesson3part1/screen/room_screen.dart';
import 'package:lesson3part1/screen/sharedwith_screen.dart';
import 'package:lesson3part1/screen/signin_screen.dart';
import 'package:lesson3part1/screen/signup_screen.dart';
import 'package:lesson3part1/screen/userhome_screen.dart';
import 'package:lesson3part1/screen/detailedview_screen.dart';

import 'model/constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Lesson3Part1App());
}

class Lesson3Part1App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: Constant.DEV,
      initialRoute: SignInScreen.routeName,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[200],
      ),
      routes: {
        SignInScreen.routeName: (context) => SignInScreen(),
        UserHomeScreen.routeName: (context) => UserHomeScreen(),
        AddPhotoMemoScreen.routeName: (context) => AddPhotoMemoScreen(),
        DetailedViewScreen.routeName: (context) => DetailedViewScreen(),
        SignUpScreen.routeName: (context) => SignUpScreen(),
        SharedWithScreen.routeName: (context) => SharedWithScreen(),
        RoomScreen.routeName: (context) => RoomScreen(),
      },
    );
  }
}
