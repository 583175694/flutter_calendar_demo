/**
 * @ClassName template
 * @Author wushaohang
 * @Date 2020/4/10
 **/
import 'package:flutter/material.dart';

class CalendarComponent extends StatefulWidget {
  @override
  _CalendarComponentState createState() => _CalendarComponentState();
}

class _CalendarComponentState extends State<CalendarComponent> {
  Map prov;
  Map next;

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

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, item) {
          return buildListData(context, titleItems[item], iconItems[item], subTitleItems[item], item);
        },
        separatorBuilder: (BuildContext context, int index) => new Divider(),
        itemCount: iconItems.length
      )
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
}
