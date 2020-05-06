import 'package:example1/pullDrag/pull_drag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/flutter_custom_calendar.dart';

/**
 * 默认风格+单选
 */
class DefaultStylePage extends StatefulWidget {
  DefaultStylePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DefaultStylePageState createState() => _DefaultStylePageState();
}

class _DefaultStylePageState extends State<DefaultStylePage> {
  ValueNotifier<String> text;
  ValueNotifier<String> selectText;

  CalendarController controller;
  bool _open = true;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          color: Colors.white,
          child: PullDragWidget(
            dragHeight: 460,
            parallaxRatio: 0.0,
            thresholdRatio: 0.2,
            header: _calendarContent(),
//            child: Container(
//              height: 10,
//              width: 20,
//              color: Colors.amberAccent,
//            ),
            callback: ((res) {
              if (_open != res) {
                controller.toggleExpandStatus();
              }
              setState(() {
                _open = res;
              });
            }),
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.toggleExpandStatus();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
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
}
