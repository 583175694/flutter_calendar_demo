import 'dart:math';

import 'package:example1/pullDrag/eventbus.dart';
import 'package:example1/pullDrag/orntdrag.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PullDragWidget extends StatefulWidget {
  final Widget header;
  final Widget child;
  final double dragHeight;
  final double dragRatio;
  final double parallaxRatio;
  final double thresholdRatio;
  final callback;

  const PullDragWidget(
      {Key key,
      this.header,
      this.child,
      this.dragHeight,
      this.dragRatio = 0.4,
      this.parallaxRatio = 0.2,
      this.thresholdRatio = 0.2,
      this.callback})
      : assert(dragHeight > 0),
        assert(dragRatio > 0 && dragRatio <= 1.0),
        assert(parallaxRatio >= 0 && parallaxRatio <= 1.0),
        assert(thresholdRatio > 0 && thresholdRatio < 1.0),
        super(key: key);

  @override
  _PullDragWidgetState createState() => _PullDragWidgetState();
}

class _PullDragWidgetState extends State<PullDragWidget>
    with SingleTickerProviderStateMixin {
  double _offsetY;

  AnimationController _animationController;

  bool _opened = true;

  Map<Type, GestureRecognizerFactory> _contentGestures;

  @override
  void initState() {
    _offsetY = widget.dragHeight;
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animationController.addListener(() {
      var value = _animationController.value * widget.dragHeight;
      _offsetY = value;
      _offsetY = max(100, min(widget.dragHeight, _offsetY));
      setState(() {});
    });
    _animationController.addStatusListener((AnimationStatus status) {
      if (_offsetY == 100) {
        _opened = false;
      } else if (_offsetY == widget.dragHeight) {
        _opened = true;
      }
      widget.callback(_opened);
      setState(() {});
    });
    _contentGestures = {
      DirectionGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<DirectionGestureRecognizer>(
              () => DirectionGestureRecognizer(DirectionGestureRecognizer.down),
              (instance) {
        instance.onDown = _onDragDown;
        instance.onStart = _onDragStart;
        instance.onUpdate = _onDragUpdate;
        instance.onCancel = _onDragCancel;
        instance.onEnd = _onDragEnd;
      }),
      TapGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              () => TapGestureRecognizer(), (instance) {
        instance.onTap = _onContentTap;
      })
    };
    bus.on("openCard", openCard);
    super.initState();
  }

  _onContentTap() {
    if (_opened) {
      _smoothClose();
    }
  }

  void openCard(open) {
    if (open) {
      if (!_opened) _smoothOpen();
    } else {
      _smoothClose();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
    bus.off("openCard", openCard);
  }

  Widget _headerWidget() {
    return Transform.translate(
      offset: Offset(0, _offsetY * widget.parallaxRatio),
      child: widget.header,
    );
  }

  _onDragStart(DragStartDetails details) {}

  _onDragDown(DragDownDetails details) {
    setState(() {});
  }

  _onDragUpdate(DragUpdateDetails details) {
    _offsetY += widget.dragRatio * details.delta.dy;
    _offsetY = max(0, min(widget.dragHeight, _offsetY));
    setState(() {});
  }

  _onDragEnd(DragEndDetails details) {
    _onTouchRelease();
  }

  _onDragCancel() {
    // _onTouchRelease();
  }

  _onTouchRelease() {
    if (_offsetY == 100) {
      if (_opened) {
        _opened = false;
      }
      setState(() {});
      return;
    }
    if (_offsetY == widget.dragHeight) {
      if (!_opened) {
        _opened = true;
      }
      setState(() {});
      return;
    }

    if (!_opened) {
      if (_offsetY.abs() > widget.dragHeight * widget.thresholdRatio) {
        _smoothOpen();
      } else {
        _smoothClose();
      }
    } else {
      if (_offsetY.abs() < widget.dragHeight - kTouchSlop) {
        _smoothClose();
      } else {
        _smoothOpen();
      }
    }
  }

  _smoothOpen() {
    if (_offsetY == widget.dragHeight) {
      return;
    }
    _animationController.value = _offsetY / widget.dragHeight;
    _animationController?.forward();
  }

  _smoothClose() {
    if (_offsetY == 100) {
      return;
    }
    _animationController.value = _offsetY / widget.dragHeight;
    _animationController?.reverse();
  }

  @override
  Widget build(BuildContext context) {

    return RawGestureDetector(
        behavior: HitTestBehavior.translucent,
        gestures: _contentGestures,
        child: Stack(
          children: <Widget>[
            Positioned(
                top: _offsetY,
                bottom: -_offsetY,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: _opened,
                  child: widget.child,
                )),
            Positioned(
                top: -widget.dragHeight + _offsetY,
                bottom: null,
                left: 0,
                right: 0,
                height: widget.dragHeight,
                child: _headerWidget()),
          ],
        ));
  }
}
