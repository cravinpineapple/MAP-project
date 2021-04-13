import 'package:flutter/material.dart';
import 'package:lesson3part1/model/photomemo.dart';
import 'package:intl/intl.dart';
import 'package:lesson3part1/screen/similarphotos_screen.dart';

import '../../model/constant.dart';
import '../../model/photomemo.dart';

class DetailedView extends StatefulWidget {
  final List<PhotoMemo> allRoomMemos;
  final PhotoMemo photoMemo;
  final int commentCount;
  final String ownerUsername;

  DetailedView({
    @required this.photoMemo,
    @required this.commentCount,
    @required this.ownerUsername,
    @required this.allRoomMemos,
  });

  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedView> {
  _Controller con;
  PhotoMemo photoMemo;
  int commentCount;
  String ownerUsername;
  List<PhotoMemo> allRoomMemos;
  List<PhotoMemo> filteredList;

  @override
  void initState() {
    super.initState();
    photoMemo = widget.photoMemo;
    commentCount = widget.commentCount;
    ownerUsername = widget.ownerUsername;
    allRoomMemos = widget.allRoomMemos;
    con = _Controller(this);
    filteredList = [];
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('EEE, M/d/y H:mm');
    double contentFont = 20.0;
    double headerFont = 15.0;
    double spacer = 20.0;
    Color contentColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 9.0,
          ),
          Text(
            'Photo Title',
            style: TextStyle(
              fontSize: headerFont,
            ),
          ),
          Text(
            photoMemo.title,
            style: TextStyle(
              fontSize: contentFont,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),
          SizedBox(
            height: spacer,
          ),
          Text(
            'Memo',
            style: TextStyle(
              fontSize: headerFont,
            ),
          ),
          Text(
            photoMemo.memo,
            style: TextStyle(
              fontSize: contentFont,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
          ),
          SizedBox(
            height: spacer,
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
            height: spacer,
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
            height: spacer,
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
            height: spacer,
          ),
          Text(
            'ML Data',
            style: TextStyle(
              fontSize: headerFont,
            ),
          ),
          Text(
            photoMemo.imageLabels.toString(),
            style: TextStyle(
              fontSize: contentFont,
              fontWeight: FontWeight.bold,
              color: contentColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: spacer,
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
                        onPressed: () {
                          con.filterPhotosOnMLLabels();
                          Navigator.pushNamed(context, SimilarPhotosScreen.routeName,
                              arguments: {Constant.ARG_PHOTOMEMOLIST: filteredList});
                        },
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
          SizedBox(
            height: spacer,
          )
        ],
      ),
    );
  }
}

class _Controller {
  _DetailedViewState state;
  _Controller(this.state);

  void filterPhotosOnMLLabels() {
    state.filteredList.clear();
    List<dynamic> imageLabels = state.photoMemo.imageLabels;

    for (var p in state.allRoomMemos)
      for (var l in p.imageLabels)
        if (imageLabels.contains(l) && p.docID != state.photoMemo.docID) {
          state.filteredList.add(p);
          break;
        }
  }
}
