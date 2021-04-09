import 'package:flutter/material.dart';

import 'myimage.dart';

class ProfilePic extends StatefulWidget {
  final double profilePicSize;
  final String url;

  ProfilePic({@required this.profilePicSize, @required this.url});

  @override
  State<StatefulWidget> createState() {
    return _ProfilePicState();
  }
}

class _ProfilePicState extends State<ProfilePic> {
  _Controller con;
  double profilePicSize;
  String url = '';

  @override
  void initState() {
    super.initState();
    profilePicSize = widget.profilePicSize;
    url = widget.url;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: profilePicSize,
      width: profilePicSize,
      child: ClipOval(
        child: FittedBox(
          fit: BoxFit.cover,
          child: MyImage.network(
            url: url,
            context: context,
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _ProfilePicState state;
  _Controller(this.state);
}
