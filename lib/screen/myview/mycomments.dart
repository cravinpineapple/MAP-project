import 'package:flutter/material.dart';
import 'package:lesson3part1/model/comment.dart';

class CommentsBlock extends StatefulWidget {
  List<Comment> comments;

  CommentsBlock({
    @required this.comments,
  });

  @override
  State<StatefulWidget> createState() {
    return _CommentsBlockState();
  }
}

class _CommentsBlockState extends State<CommentsBlock> {
  _Controller con;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: con.getComments(),
    );
  }
}

class _Controller {
  _CommentsBlockState state;
  _Controller(this.state);

  List<Widget> getComments() {}
}
