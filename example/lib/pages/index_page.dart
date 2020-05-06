/**
 * @ClassName template
 * @Author wushaohang
 * @Date 2020/4/10
 **/
import 'package:flutter/material.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('template'),
        elevation: 0
      ),
      body: Container()// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
