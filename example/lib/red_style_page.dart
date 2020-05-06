import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';

class RedStylePage extends StatefulWidget {
  RedStylePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RedStylePageState createState() => _RedStylePageState();
}

class _RedStylePageState extends State<RedStylePage> {
  ValueNotifier<String> text;
  ValueNotifier<String> selectText;

  CalendarController controller;

  Map<DateModel, String> customExtraData = {};

  Color pinkColor = Color(0xffFF8291);

  Map prov = {
    'value': null,
    'index': null
  };
  Map next = {
    'value': null,
    'index': null
  };

  @override
  void initState() {
    super.initState();

    controller = new CalendarController(
        showMode: CalendarConstants.MODE_SHOW_MONTH_AND_WEEK,
        extraDataMap: customExtraData);

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
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _list = new List();
    for (int i = 0; i < titleItems.length; i++) {
      _list.add(buildListData(context, titleItems[i], iconItems[i], subTitleItems[i], i));
    }
    // 分割线
    var divideTiles = ListTile.divideTiles(context: context, tiles: _list).toList();

    var calendarWidget = CalendarViewWidget(
      calendarController: controller,
      margin: EdgeInsets.only(top: 20),
      weekBarItemWidgetBuilder: () {
        return CustomStyleWeekBarItem();
      },
      dayWidgetBuilder: (dateModel) {
        return CustomStyleDayWidget(dateModel);
      },
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: new Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: new Column(
            crossAxisAlignment:CrossAxisAlignment.stretch ,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  ValueListenableBuilder(
                      valueListenable: text,
                      builder: (context, value, child) {
                        return new Text(
                          "${text.value}",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w700),
                        );
                      }),
                  Positioned(
                    left: 0,
                    child: Icon(
                      Icons.notifications,
                      color: pinkColor,
                    ),
                  ),
                  Positioned(
                    right: 40,
                    child: Icon(
                      Icons.search,
                      color: pinkColor,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Icon(
                      Icons.add,
                      color: pinkColor,
                    ),
                  ),
                ],
              ),
              calendarWidget,
              ValueListenableBuilder(
                  valueListenable: selectText,
                  builder: (context, value, child) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: new Text(selectText.value),
                    );
                  }),
            Flexible(
                child: new ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, item) {
                    return buildListData(context, titleItems[item], iconItems[item], subTitleItems[item], item);
                    },
                  separatorBuilder: (BuildContext context, int index) => new Divider(),
                  itemCount: iconItems.length)
            )],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.toggleExpandStatus();
          },
          tooltip: 'Increment',
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
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
}

class CustomStyleWeekBarItem extends BaseWeekBar {
  final List<String> weekList = ["M", "T", "W", "T", "F", "S", "S"];

  //可以直接重写build方法
  @override
  Widget build(BuildContext context) {
    List<Widget> children = List();

    var items = getWeekDayWidget();
    children.add(Row(
      children: items,
    ));
    children.add(Divider(
      color: Colors.grey,
    ));
    return Column(
      children: children,
    );
  }

  @override
  Widget getWeekBarItem(int index) {
    return new Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: new Center(
        child: new Text(
          weekList[index],
          style:
              TextStyle(fontWeight: FontWeight.w700, color: Color(0xffBBC0C6)),
        ),
      ),
    );
  }
}

class CustomStyleDayWidget extends BaseCombineDayWidget {
  CustomStyleDayWidget(DateModel dateModel) : super(dateModel);

  final TextStyle normalTextStyle =
      TextStyle(fontWeight: FontWeight.w700, color: Colors.black);

  final TextStyle noIsCurrentMonthTextStyle =
      TextStyle(fontWeight: FontWeight.w700, color: Colors.grey);

  @override
  Widget getNormalWidget(DateModel dateModel) {
    return Container(
      margin: EdgeInsets.all(8),
      child: new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          new Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //公历
              new Expanded(
                child: Center(
                  child: new Text(
                    dateModel.day.toString(),
                    style: dateModel.isCurrentMonth
                        ? normalTextStyle
                        : noIsCurrentMonthTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget getSelectedWidget(DateModel dateModel) {
    return Container(
//      margin: EdgeInsets.all(8),
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xffFF8291),
      ),
      child: new Stack(
        alignment: Alignment.center,
        children: <Widget>[
          new Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //公历
              new Expanded(
                child: Center(
                  child: new Text(
                    dateModel.day.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
