import 'package:flutter/material.dart';
import 'package:lesson3part1/model/photomemo.dart';
import 'package:intl/intl.dart';

class DetailedView extends StatefulWidget {
  final PhotoMemo photoMemo;
  final int commentCount;
  final String ownerUsername;

  DetailedView({
    @required this.photoMemo,
    @required this.commentCount,
    @required this.ownerUsername,
  });

  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedView> {
  PhotoMemo photoMemo;
  int commentCount;
  String ownerUsername;

  @override
  void initState() {
    super.initState();
    photoMemo = widget.photoMemo;
    commentCount = widget.commentCount;
    ownerUsername = widget.ownerUsername;
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('EEE, M/d/y H:mm');
    double contentFont = 20.0;
    double headerFont = 15.0;
    Color contentColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        SizedBox(
          height: 9.0,
        ),
        Text(
          'Created By',
          style: TextStyle(
            fontSize: headerFont,
          ),
        ),
        Text(
          ownerUsername,
          style: TextStyle(
            fontSize: contentFont,
            fontWeight: FontWeight.bold,
            color: contentColor,
          ),
        ),
        SizedBox(
          height: 13.0,
        ),
        Text(
          'Last Updated',
          style: TextStyle(fontSize: headerFont),
        ),
        Text(
          formatter.format(photoMemo.timestamp),
          style: TextStyle(
            fontSize: contentFont,
            fontWeight: FontWeight.bold,
            color: contentColor,
          ),
        ),
        SizedBox(
          height: 13.0,
        ),
        Text(
          'Number of Comments',
          style: TextStyle(
            fontSize: headerFont,
          ),
        ),
        Text(
          commentCount.toString(),
          style: TextStyle(
            fontSize: contentFont,
            fontWeight: FontWeight.bold,
            color: contentColor,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(),
              flex: 1,
            ),
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0, top: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      height: 70.0,
                      width: 200.0,
                    ),
                  ),
                  Positioned(
                    left: 43.0,
                    bottom: 36.0,
                    child: IconButton(
                      icon: Icon(
                        Icons.pageview,
                        size: 65.0,
                        color: Colors.grey[800],
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Positioned(
                    bottom: 1.0,
                    left: 20.0,
                    child: Text(
                      'Similar Photos',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
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
      ],
    );
  }
}
