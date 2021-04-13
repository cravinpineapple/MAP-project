import 'package:flutter/material.dart';

import '../model/constant.dart';
import '../model/photomemo.dart';
import 'myview/myimage.dart';

class SimilarPhotosScreen extends StatefulWidget {
  static const routeName = 'similarPhotosScreen';
  @override
  State<StatefulWidget> createState() {
    return _SimilarPhotosState();
  }
}

class _SimilarPhotosState extends State<SimilarPhotosScreen> {
  _Controller con;
  List<PhotoMemo> similarPhotos;
  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    Map args = ModalRoute.of(context).settings.arguments;
    similarPhotos ??= args[Constant.ARG_PHOTOMEMOLIST];
    return Scaffold(
      appBar: AppBar(
        title: Text('Similar Photos'),
      ),
      body: con.generateWall(),
    );
  }
}

class _Controller {
  _SimilarPhotosState state;
  _Controller(this.state);

  Widget generateWall() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: getRows(),
        ),
      ),
    );
  }

  List<Widget> getRows() {
    int size = state.similarPhotos.length; // 3
    if (size == 0)
      return [
        Text(
          'No Similar Photos Were Found',
          style: TextStyle(color: Colors.grey[400], fontSize: 40.0),
        )
      ];

    List<Widget> w = [];
    int counter = 0;
    List<Color> colors = [Colors.red, Colors.blue, Colors.green];
    var width = MediaQuery.of(state.context).size.width * .31;
    Row row;
    List<Widget> widgies = [];

    for (var m in state.similarPhotos.reversed) {
      // 3
      widgies.add(
        Stack(
          children: [
            Container(
              width: width,
              height: width,
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: MaterialButton(
                    child: MyImage.network(url: m.photoURL, context: state.context),
                    onPressed: null),
              ),
              color: Colors.transparent,
            ),
          ],
        ),
      );
      size--;
      if (counter != 2) widgies.add(SizedBox(width: 2.0));
      if (counter == 2) {
        row = Row(children: widgies);
        w.add(row);
        w.add(SizedBox(height: 5.0));
        widgies = [];
        counter = -1;
      }
      counter++;
    }
    print(size);
    if (size == 0) {
      row = Row(children: widgies);
      w.add(row);
      w.add(SizedBox());
    }
    return w;
  }
}
