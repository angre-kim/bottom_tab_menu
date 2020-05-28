import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "flutter demo",
      theme: ThemeData(primarySwatch: Colors.lightBlue),
      home: _Home(),
    );
  }
}

class _Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<_Home> {
  List<Widget> _viewList;
  int _index = 0;
  @override
  void initState() {
    super.initState();
    _viewList = List();
    _viewList
      ..add(EachView("page1"))
      ..add(EachView("page2"))
      ..add(EachView("page3"))
      ..add(EachView("page4"));
  }

  _openNewPage() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return EachView("new Pager");
    }));
  }

  static const double offset = 15.0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: _openNewPage,
          elevation: 0,
          child: Icon(
            Icons.add,
            color: Colors.white,
          )),
      floatingActionButtonLocation:
          const _CenterDockedFloatingActionButtonLocation(offset),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6,
        color: Colors.white,
        shape: CircularRaisedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _buildBottomItem(_index, 0, Icons.home, "홈"),
            _buildBottomItem(_index, 1, Icons.calendar_today, "업무"),
            _buildBottomItem(_index, -1, null, ""),
            _buildBottomItem(_index, 2, Icons.access_alarm, "알림"),
            _buildBottomItem(_index, 3, Icons.more_horiz, "전체"),
          ],
        ),
      ),
      body: _viewList[_index],
    );
  }

  Widget _buildBottomItem(
      int selectIndex, int index, IconData iconData, String title) {
    TextStyle textStyle = TextStyle(fontSize: 12.0, color: Colors.grey);
    MaterialColor iconColor = Colors.grey;
    double iconSize = 20;
    EdgeInsetsGeometry padding = EdgeInsets.only(top: 8.0);

    if (selectIndex == index) {
      textStyle = TextStyle(fontSize: 12.0, color: Colors.blue);

      iconColor = Colors.blue;
    }
    Widget padItem = SizedBox();
    if (iconData != null) {
      padItem = Padding(
        padding: padding,
        child: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: <Widget>[
                Icon(
                  iconData,
                  color: iconColor,
                  size: iconSize,
                ),
                Text(
                  title,
                  style: textStyle,
                )
              ],
            ),
          ),
        ),
      );
    }
    Widget item = Expanded(
      flex: 1,
      child: new GestureDetector(
        onTap: () {
          if (index != _index) {
            setState(() {
              _index = index;
            });
          }
        },
        child: SizedBox(
          height: 52,
          child: padItem,
        ),
      ),
    );
    return item;
  }
}

class EachView extends StatefulWidget {
  String _title;

  EachView(this._title);

  @override
  _EachViewState createState() => _EachViewState();
}

class _EachViewState extends State<EachView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: Center(child: Text(widget._title)),
    );
  }
}

class CircularRaisedRectangle extends NotchedShape {
  const CircularRaisedRectangle();

  @override
  Path getOuterPath(Rect host, Rect guest) {
    if (guest == null || !host.overlaps(guest)) return Path()..addRect(host);

    // The guest's shape is a circle bounded by the guest rectangle.
    // So the guest's radius is half the guest width.
    final double notchRadius = guest.width / 2.0;
    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(guest.left, host.top)
      ..arcTo(
          Rect.fromLTWH(
            guest.left,
            guest.top,
            notchRadius * 2,
            notchRadius * 2,
          ),
          math.asin(1 - (host.top - guest.top) / notchRadius) + degToRad(180),
          math.acos(1 - (host.top - guest.top) / notchRadius) * 2,
          false)
      ..lineTo(guest.right, host.top)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}

abstract class _DockedFloatingActionButtonLocation
    extends FloatingActionButtonLocation {
  const _DockedFloatingActionButtonLocation();

  @protected
  double getDockedY(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double contentBottom = scaffoldGeometry.contentBottom;
    final double bottomSheetHeight = scaffoldGeometry.bottomSheetSize.height;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final double snackBarHeight = scaffoldGeometry.snackBarSize.height;

    double fabY = contentBottom - fabHeight / 2.0;
    if (snackBarHeight > 0.0)
      fabY = math.min(
          fabY,
          contentBottom -
              snackBarHeight -
              fabHeight -
              kFloatingActionButtonMargin);
    if (bottomSheetHeight > 0.0)
      fabY =
          math.min(fabY, contentBottom - bottomSheetHeight - fabHeight / 2.0);

    final double maxFabY = scaffoldGeometry.scaffoldSize.height - fabHeight;
    return math.min(maxFabY, fabY);
  }
}

class _CenterDockedFloatingActionButtonLocation
    extends _DockedFloatingActionButtonLocation {
  const _CenterDockedFloatingActionButtonLocation(this.offset);

  final double offset;

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;
    return Offset(fabX, getDockedY(scaffoldGeometry) + offset);
  }

  @override
  String toString() => 'FloatingActionButtonLocation.centerDocked';
}

num degToRad(num deg) => deg * (math.pi / 180.0);
