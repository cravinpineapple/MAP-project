import 'package:flutter/material.dart';

class SharedWithScreen extends StatefulWidget {
  static const routeName = '/sharedWithScreen';

  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  _Controller con;

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
        title: Text('Shared With Me'),
      ),
      body: Text('Shared with'),
    );
  }
}

class _Controller {
  _SharedWithState state;
  _Controller(this.state);
}
