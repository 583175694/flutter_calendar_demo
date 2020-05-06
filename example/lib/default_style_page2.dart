import 'dart:ui';

import 'package:example1/components/schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/constants/constants.dart';
import 'dart:math' as math;

import 'package:flutter_custom_calendar/controller.dart';
import 'package:flutter_custom_calendar/widget/calendar_view.dart';

class ProductItem {
  final String name;
  final String tag;
  final String asset;
  final int stock;
  final double price;

  ProductItem({
    this.name,
    this.tag,
    this.asset,
    this.stock,
    this.price,
  });
}


class SliverHeaderPage extends StatefulWidget {
  const SliverHeaderPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CollapsingState();
}

class _CollapsingState extends State<SliverHeaderPage> {
  bool floating = false;
  bool pinned = true;
  CalendarController controller;
  String currentView = 'month';

  ValueNotifier<String> text;
  ValueNotifier<String> selectText;

  Map prov = new Map();
  Map next = new Map();

  // 数据源
  List<String> titleItems = <String>[
    'keyboard', 'print',
    'router', 'pages',
    'zoom_out_map', 'zoom_out',
    'youtube_searched_for', 'wifi_tethering',
    'wifi_lock', 'widgets',
    'weekend', 'web',
    '图accessible', 'ac_unit',
  ];

  List<Icon> iconItems = <Icon>[
    new Icon(Icons.keyboard), new Icon(Icons.print),
    new Icon(Icons.router), new Icon(Icons.pages),
    new Icon(Icons.zoom_out_map), new Icon(Icons.zoom_out),
    new Icon(Icons.youtube_searched_for), new Icon(Icons.wifi_tethering),
    new Icon(Icons.wifi_lock), new Icon(Icons.widgets),
    new Icon(Icons.weekend), new Icon(Icons.web),
    new Icon(Icons.accessible), new Icon(Icons.ac_unit),
  ];

  List<String> subTitleItems = <String>[
    'subTitle: keyboard', 'subTitle: print',
    'subTitle: router', 'subTitle: pages',
    'subTitle: zoom_out_map', 'subTitle: zoom_out',
    'subTitle: youtube_searched_for', 'subTitle: wifi_tethering',
    'subTitle: wifi_lock', 'subTitle: widgets',
    'subTitle: weekend', 'subTitle: web',
    'subTitle: accessible', 'subTitle: ac_unit',
  ];

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    controller = new CalendarController(
        minYear: now.year - 1,
        minYearMonth: 1,
        maxYear: now.year + 1,
        maxYearMonth: 12,
        showMode: CalendarConstants.MODE_SHOW_MONTH_AND_WEEK);

    controller.addMonthChangeListener(
          (year, month) {
        text.value = "$year年$month月";
      },
    );

    controller.addOnCalendarSelectListener((dateModel) {
      //刷新选择的时间
      selectText.value =
      "单选模式\n选中的时间:\n${controller.getSingleSelectCalendar()}";
    });

    text = new ValueNotifier("${DateTime.now().year}年${DateTime.now().month}月");

    selectText = new ValueNotifier(
        "单选模式\n选中的时间:\n${controller.getSingleSelectCalendar()}");

    _scrollController = new ScrollController();
    _scrollController.addListener(() {
      print(_scrollController.offset);
      if (_scrollController.offset > 240.0) {
        if (currentView == 'month') {
          controller.toggleExpandStatus();
        }
        currentView = 'week';
      } else {
        if (currentView == 'week') {
          controller.toggleExpandStatus();
        }
        currentView = 'month';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('标题'),
      ),
      body: Stack(
        children: <Widget>[
          CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                bottom: PreferredSize(
                  preferredSize: Size(200, 100),
                  child: Container()
                ),
                backgroundColor: Colors.white,
                expandedHeight: 400.0,
                flexibleSpace: _calendarContent(),
                forceElevated: false,
                elevation: 0,
                pinned: pinned,
              ),
              SliverFixedExtentList(
                itemExtent: 80.0,
                delegate: SliverChildListDelegate(
                  buildGrid()
                ),
              ),
            ],
          ),

        ],
      )
    );
  }

  Widget _calendarContent() {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new IconButton(
                  icon: Icon(Icons.navigate_before),
                  onPressed: () {
                    controller.moveToPreviousMonth();
                    controller.previousPage();
                  }),
              ValueListenableBuilder(
                  valueListenable: text,
                  builder: (context, value, child) {
                    return new Text(text.value);
                  }),
              new IconButton(
                  icon: Icon(Icons.navigate_next),
                  onPressed: () {
//                      controller.moveToNextMonth();
                    controller.nextPage();
                  }),
            ],
          ),
          CalendarViewWidget(
            calendarController: controller,
          ),
//          ValueListenableBuilder(
//              valueListenable: selectText,
//              builder: (context, value, child) {
//                return new Text(selectText.value);
//              }),
        ],
      ),
    );
  }

  List<Widget> buildGrid() {
    List<Widget> tiles = [];
    Widget content;
    for(int i = 0; i < subTitleItems.length; i++) {
      tiles.add(
          buildListData(context, titleItems[i], iconItems[i], subTitleItems[i], i)
      );
    }

    return tiles;
  }

  Widget buildListData(BuildContext context, String titleItem, Icon iconItem, String subTitleItem, index) {
    bool accepted = false;

    return DragTarget(
      builder: (context, candidateData, rejectedData) {
        return new ListTile(
          leading: iconItem,
          title: new Text(
            titleItem,
            style: TextStyle(fontSize: 18),
          ),
          subtitle: new Text(
            subTitleItem,
          ),
          trailing: new Draggable(
              child: new Icon(Icons.adjust),
              axis: Axis.vertical,
              feedback: new Container(
                  transform: Matrix4.translationValues(-MediaQuery.of(context).size.width + 50, 0, 0),
                  child: new Text(
                    titleItem,
                    style: TextStyle(fontSize: 25),
                  )
              ),
              onDragStarted: () {
                prov["value"] = titleItem;
                prov["index"] = index;
                print(prov);
              }
          ),
        );
      },
      //返回是否接收 参数为Draggable的data 方向相同则允许接收
      onWillAccept: (data) {
        return true;
      },
      onAccept: (data) {
        next["value"] = titleItem;
        next["index"] = index;
        accepted = true;

        setState(() {
          titleItems[next["index"]] = prov["value"];
          titleItems[prov["index"]] = next["value"];
        });

        print('prov: $prov, next: $next accepted:$accepted');
      },
    );
  }
}