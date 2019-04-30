import 'package:flutter/material.dart';

class SplashyBottomAppBar extends StatefulWidget {
  final Duration animationDuration;
  final Function onTap;
  @required
  final List<BarItem> items;
  final double iconSize;
  final int currentIndex;

  //final BarStyle barStyle;

  SplashyBottomAppBar({
    Key key,
    this.animationDuration = const Duration(milliseconds: 150),
    this.onTap,
    this.items,
    this.iconSize = 36,
    this.currentIndex = 0,
    //this.barStyle = const BarStyle(),
  })  : assert(items != null),
        assert(items.length >= 2),
        assert(0 <= currentIndex && currentIndex < items.length),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SplashyBottomAppBarState();
  }
}

class _SplashyBottomAppBarState extends State<SplashyBottomAppBar> with TickerProviderStateMixin {
  List<BarItem> barItems = [];
  int selectedIndex;
  bool isActive;

  @override
  void initState() {
    selectedIndex = widget.currentIndex;
    barItems = widget.items;
    super.initState();
  }

  _buildItems() {
    List<Widget> itemToDisplay = List();
    for (int i = 0; i < barItems.length; i++) {
      isActive = i == selectedIndex;
      itemToDisplay.add(
        _SplashWithEase(
          color: barItems[i].color,
          onTap: () {
            selectedIndex = i;
            widget.onTap(i);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: isActive ? barItems[i].color.withOpacity(0.15) : Colors.transparent,
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  barItems[i].iconData,
                  size: widget.iconSize,
                  color: isActive ? barItems[i].color : Colors.black,
                ),
                SizedBox(
                  width: 5.0,
                ),
                AnimatedSize(
                  duration: widget.animationDuration,
                  curve: Curves.easeIn,
                  vsync: this,
                  child: Text(
                    isActive ? barItems[i].text : "",
                    style: TextStyle(
                      color: barItems[i].color,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return itemToDisplay;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.1,
      child: Material(
        elevation: 30.0,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: size.height * 0.01,
            top: size.height * 0.01,
            left: size.width * 0.05,
            right: size.width * 0.05,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: _buildItems(),
          ),
        ),
      ),
    );
  }
}

class BarItem {
  String text;
  IconData iconData;
  Color color;

  BarItem({this.text, this.iconData, this.color});
}

class BarStyle {
  final double fontSize;
  final FontWeight fontWeight;

  BarStyle({this.fontSize = 16, this.fontWeight = FontWeight.w600});
}

class SplashPaint extends CustomPainter {
  final double radius;
  final double borderWidth;
  final AnimationStatus status;
  final Offset tapPosition;
  final Paint blackPaint;
  final Color color;

  SplashPaint({@required this.radius, @required this.borderWidth, @required this.status, @required this.tapPosition, @required this.color})
      : blackPaint = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (status == AnimationStatus.forward) {
      canvas.drawCircle(tapPosition, radius, blackPaint);
    }
  }

  @override
  bool shouldRepaint(SplashPaint oldDelegate) {
    if (radius != oldDelegate.radius) {
      return true;
    } else {
      return false;
    }
  }
}

class _SplashWithEase extends StatefulWidget {
  final Widget child;
  final GestureTapCallback onTap;
  final Color color;

  const _SplashWithEase({Key key, this.onTap, this.child, this.color}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SplashStateWithEase();
  }
}

class _SplashStateWithEase extends State<_SplashWithEase> with SingleTickerProviderStateMixin {
  static const double minRadius = 80;
  static const double maxRadius = 80;

  AnimationController controller;
  Tween<double> radiusTween;
  Tween<double> borderWidthTween;
  Animation<double> radiusAnimation;
  Animation<double> borderWidthAnimation;
  AnimationStatus status;
  Offset _tapPosition;
  RenderBox renderBox;

  @override
  void initState() {
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 350))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((listener) {
        status = listener;
      });
    radiusTween = Tween<double>(begin: 0, end: 50);
    radiusAnimation = radiusTween.animate(CurvedAnimation(curve: Curves.ease, parent: controller));
    borderWidthTween = Tween<double>(begin: 25, end: 1);
    borderWidthAnimation = borderWidthTween.animate(CurvedAnimation(curve: Curves.fastOutSlowIn, parent: controller));

    super.initState();
  }

  void _animate() {
    controller.forward(from: 0);
  }

  void _handleTap(TapUpDetails tapDetails) {
    RenderBox renderBox = context.findRenderObject();
    _tapPosition = renderBox.globalToLocal(tapDetails.globalPosition);
    double radius = (renderBox.size.width > renderBox.size.height) ? renderBox.size.width : renderBox.size.height;
    double constraintRadius;
    if (radius > maxRadius) {
      constraintRadius = maxRadius;
    } else if (radius < minRadius) {
      constraintRadius = minRadius;
    } else {
      constraintRadius = radius;
    }

    radiusTween.end = constraintRadius * 0.6;
    borderWidthTween.begin = radiusTween.end / 2;
    borderWidthTween.end = radiusTween.end * 0.01;
    _animate();

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: SplashPaint(
        radius: radiusAnimation.value,
        borderWidth: borderWidthAnimation.value,
        status: status,
        tapPosition: _tapPosition,
        color: widget.color.withOpacity(0.7),
      ),
      child: GestureDetector(
        child: widget.child,
        onTapUp: _handleTap,
      ),
    );
  }
}
